// lib/data/services/network_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:filenori_client/domain/entities/piece_entity.dart';

class NetworkService {
  Socket? _socket;
  bool _isSocketClosed = true;
  
  Future<Socket> _getSocket() async {
    if (_socket == null || _isSocketClosed) {
      _socket = await Socket.connect(
        dotenv.get('SERVER_URI', fallback: 'localhost'),
        int.parse(dotenv.get('SERVER_PORT', fallback: '12345')),
        // '0.tcp.jp.ngrok.io',
        // 10431,
      );
      _isSocketClosed = false;
      _socket!.done.then((_) => _isSocketClosed = true);
      print('Connected to: ${_socket!.remoteAddress}:${_socket!.remotePort}');
    }
    return _socket!;
  }

  Future<void> dispose() async {
    if (_socket != null && !_isSocketClosed) {
      await _socket!.close();
      _isSocketClosed = true;
      _socket = null;
    }
  }

  // TODO: List<int> -> PieceEntity
  Future<bool> uploadPiece({
    required String fileName,
    required int pieceIndex,
    required File data,
  }) async {
    try {
      final socket = await _getSocket();

      print("Send start");

      // JSON 형태로 메타데이터 준비
      final metadata = {
        'action': 'upload',
        'file_name': fileName,
        'piece_index': pieceIndex,
        'file_size': data.lengthSync(),
      };

      // 메타데이터 전송
      final metadataJson = jsonEncode(metadata);
      socket.write(metadataJson + "\n");
      await socket.flush();
      print("Metadata sent");

      // 메타데이터 응답 대기
      final metadataResponse = await _waitForResponse(socket);
      // if (!metadataResponse.contains('OK')) {
      //   throw Exception('Metadata upload failed: $metadataResponse');
      // }
      print("Metadata response received: $metadataResponse");

      // 파일 데이터 전송
      final fileStream = data.openRead();
      await for (var chunk in fileStream) {
        socket.add(chunk);
        await socket.flush();
      }
      socket.add(utf8.encode("<END>"));
      await socket.flush();
      print("All data sent to server");

      // 서버 응답 처리
      final completer = Completer<String>();
      late StreamSubscription subscription;

      subscription = socket.listen(
        (response) {
          final responseStr = utf8.decode(response);
          print('Raw response: $responseStr');

          if (responseStr.contains("<END>")) {
            final responseData = responseStr.split('<END>')[0];
            if (!completer.isCompleted) {
              completer.complete(responseData);
            }
          } else {
            if (!completer.isCompleted) {
              completer.complete(responseStr);
            }
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        cancelOnError: true,
      );

      try {
        final responseStr = await completer.future.timeout(
          Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Server response timeout');
          },
        );
        subscription.cancel();

        print("Server response: $responseStr");

        if (responseStr.contains('OK')) {
          print("File $fileName (piece $pieceIndex) uploaded successfully.");
          return true;
        } else {
          print("Upload failed: $responseStr");
          return false;
        }
      } finally {
        subscription.cancel();
      }
    } catch (e, st) {
      print('Upload error: $e\n$st');
      await dispose(); // 소켓을 재설정
      return false;
    }
  }

  Future<List<File>> getFileList() async {
    try {
      final socket = await _getSocket();
      final requestJson = jsonEncode({
        'action': 'list_files',
      });

      socket.write(requestJson + "\n");
      await socket.flush();

      final response = await _waitForResponse(socket);
      final fileList = jsonDecode(response) as List<dynamic>;
      final files = fileList.map((file) => File(file as String)).toList();
      return files;
      } catch (e) {
        print('Error occurred: $e');
      await dispose(); // 소켓을 재설정
      return [];
    }
  }
}

Future<String> _waitForResponse(Socket socket) async {
        final completer = Completer<String>();
        late StreamSubscription subscription;
      
        subscription = socket.listen(
          (response) {
            final responseStr = utf8.decode(response);
            if (responseStr.contains("<END>")) {
              final responseData = responseStr.split('<END>')[0];
              if (!completer.isCompleted) {
                completer.complete(responseData);
              }
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          cancelOnError: true,
        );
      
        try {
          final response = await completer.future.timeout(
            Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Server response timeout');
            },
          );
          return response;
        } finally {
          subscription.cancel();
        }
      }