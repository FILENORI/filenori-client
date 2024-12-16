// lib/data/services/network_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:filenori_client/domain/entities/piece_entity.dart';

class NetworkService {
  Socket? _socket;
  bool _isSocketClosed = true;
  StreamSubscription? _subscription;
  final _responseController = StreamController<String>.broadcast();

  Future<Socket> _getSocket() async {
    if (_socket == null || _isSocketClosed) {
      _socket = await Socket.connect(
        dotenv.get('SERVER_URI', fallback: 'localhost'),
        int.parse(dotenv.get('SERVER_PORT', fallback: '12345')),
      );
      _isSocketClosed = false;
      _socket!.done.then((_) {
        _isSocketClosed = true;
        _subscription?.cancel();
        _subscription = null;
      });
      print('Connected to: ${_socket!.remoteAddress}:${_socket!.remotePort}');

      // 소켓 응답 리스너 설정
      _subscription?.cancel();
      _subscription = _socket!.listen(
        (response) {
          final responseStr = utf8.decode(response);
          print('Raw response: $responseStr');
          if (responseStr.contains("<END>")) {
            final responseData = responseStr.split('<END>')[0];
            _responseController.add(responseData);
          }
        },
        onError: (error) {
          print('Socket error: $error');
          _responseController.addError(error);
        },
        cancelOnError: false,
      );
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

  Future<String> _waitForResponse(Socket socket) async {
    try {
      final response = await _responseController.stream.first.timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Server response timeout');
        },
      );
      return response;
    } catch (e) {
      print('Wait for response error: $e');
      rethrow;
    }
  }

  Future<bool> uploadPiece({
    required String fileName,
    required int pieceIndex,
    required File data,
  }) async {
    try {
      final socket = await _getSocket();

      // JSON 형태로 메타데이터 준비
      final metadata = {
        'action': 'upload',
        'file_name': fileName,
        'piece_index': pieceIndex,
        'file_size': data.lengthSync(),
      };

      // 메타데이터 전송
      final metadataJson = jsonEncode(metadata);
      socket.write(metadataJson);
      await socket.flush();
      print("Metadata sent: $metadataJson");

      // 메타데이터 응답 대기
      final metadataResponse = await _waitForResponse(socket);
      print("Metadata response received: $metadataResponse");

      if (!metadataResponse.contains('OK')) {
        print('Metadata upload failed: $metadataResponse');
        return false;
      }

      final fileStream = data.openRead();
      await for (var chunk in fileStream) {
        socket.add(chunk);
        await socket.flush();
      }
      socket.add(utf8.encode("<END>"));

      // 전송 완료 표시
      socket.write("<END>");
      await socket.flush();
      print("All data sent to server");

      // 파일 전송 응답 대기
      final uploadResponse = await _waitForResponse(socket);
      print("Upload response received: $uploadResponse");

      return uploadResponse.contains('OK');
    } catch (e, st) {
      print('Upload error: $e\n$st');
      await dispose();
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