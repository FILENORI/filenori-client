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
    required List<int> data,
  }) async {
    try {
      final socket = await _getSocket();

      // JSON 형태로 데이터 준비 (base64 인코딩 사용)
      final jsonData = {
        'action': 'upload',
        'file_name': fileName,
        'piece_index': pieceIndex,
        'file_size': data.length,
        'file_type': fileName.split('.').last.toLowerCase(),  // 파일 확장자 추가
        'content': data
      };

      // JSON 데이터를 문자열로 변환하고 전송
      final jsonString = jsonEncode(jsonData);
      socket.write(jsonString);

      // 서버 응답 대기
      await socket.flush();
      
      // 타임아웃과 함께 응답 대기
      final completer = Completer<String>();
      late StreamSubscription subscription;
      
      subscription = socket.listen(
        (data) {
          final responseStr = utf8.decode(data);
          if (!completer.isCompleted) {
            completer.complete(responseStr);
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        cancelOnError: true
      );

      try {
        final responseStr = await completer.future.timeout(
          Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Server response timeout');
          },
        );
        subscription.cancel();
        
        print('Server response: $responseStr');

        if (responseStr.contains('OK')) {
          return true;
        } else {
          print('Upload failed: $responseStr');
          return false;
        }
      } finally {
        subscription.cancel();
      }
    } catch (e, st) {
      print('Upload error: $e\n$st');
      // 에러 발생시 소켓 재설정
      await dispose();
      return false;
    }
  }
}