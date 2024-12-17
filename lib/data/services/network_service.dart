// lib/data/services/network_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:filenori_client/domain/entities/piece_entity.dart';

class NetworkService {
  Socket? _socket;
  final _socketCompleter = Completer<Socket>();
  bool _isConnecting = false;
  bool _isSocketClosed = true;
  StreamSubscription? _subscription;
  final _responseController = StreamController<String>.broadcast();

  Future<void> dispose() async {
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
      _isSocketClosed = true;
    }
  }

  Future<Socket> _getSocket() async {
    if (_socket != null && !_isSocketClosed) {
      return _socket!;
    }

    if (_isConnecting) {
      return _socketCompleter.future;
    }

    try {
      _isConnecting = true;
      _socket = await Socket.connect(
        dotenv.get('SERVER_URI', fallback: 'localhost'),
        int.parse(dotenv.get('SERVER_PORT', fallback: '12345')),
      );
      
      if (!_socketCompleter.isCompleted) {
        _socketCompleter.complete(_socket);
      }
      
      _isSocketClosed = false;
      _isConnecting = false;
      
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
      return _socket!;
    } catch (e) {
      _isConnecting = false;
      _isSocketClosed = true;
      if (!_socketCompleter.isCompleted) {
        _socketCompleter.completeError(e);
      }
      rethrow;
    }
  }
      Future<String> _waitForResponse(Socket socket) async {
    try {
      final response = await _responseController.stream.first.timeout(
        Duration(seconds: 30),
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

// Future<String> _waitForResponse(Socket socket) async {
//   try {
//     final completer = Completer<String>();
//     final subscription = socket
//         .transform(StreamTransformer<Uint8List, String>.fromHandlers(
//           handleData: (data, sink) {
//             sink.add(utf8.decode(data));
//           },
//         ))
//         .transform(const LineSplitter())
//         .listen(
//           (data) {
//             if (!completer.isCompleted) {
//               completer.complete(data);
//             }
//           },
//           onError: (error) {
//             if (!completer.isCompleted) {
//               completer.completeError(error);
//             }
//           },
//         );

//     final response = await completer.future;
//     await subscription.cancel();
//     return response;
//   } catch (e) {
//     print('Error waiting for response: $e');
//     rethrow;
//   }
// }

  Future<bool> uploadPiece({
    required String fileName,
    required int pieceIndex,
    required File data,
  }) async {
    try {
      final socket = await _getSocket();

      // 파일 데이터를 한 번에 읽기
      final bytes = await data.readAsBytes();

      // JSON 형태로 메타데이터 준비
      final metadata = {
        'action': 'upload',
        'file_name': fileName,
        'piece_index': pieceIndex,
        'file_size': bytes.length,
      };

      // 메타데이터 전송
      final metadataJson = jsonEncode(metadata);
      socket.write(metadataJson);
      await socket.flush();
      print("Metadata sent: $metadataJson");

      // // 메타데이터 응답 대기
      final metadataResponse = await _waitForResponse(socket);
      print("Metadata response received: $metadataResponse");

      if (!metadataResponse.contains('OK')) {
        print('Metadata upload failed: $metadataResponse');
        return false;
      }

      // 파일 데이터 한 번에 전송
      socket.add(bytes);
      await socket.flush();
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
      print('File list response: $response');
      
      final Map<String, dynamic> responseData = jsonDecode(response);
      if (responseData['status'] == 'success' && responseData['files'] is List) {
        final fileList = responseData['files'] as List<dynamic>;
        return fileList.map((filePath) => File(filePath['name'] as String)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error getting file list: $e');
      await dispose();
      return [];
    }
  }

  Future<String> downloadFile(String filePath) async {
    try {
      final socket = await _getSocket();
      final requestJson = jsonEncode({
        'action': 'download',
        'file_path': filePath,
      });
      socket.write(requestJson + "\n");
      await socket.flush();

      final response = await _waitForResponse(socket);
      print('Download response: $response');
      
      final responseData = jsonDecode(response);
      if (responseData['status'] == 'success' && responseData['ip'] != null) {
        return responseData['ip'] as String;
      }
      return '';
    } catch (e) {
      print('Error downloading file: $e');
      await dispose();
      return '';
    }
  }
}