import 'dart:io';
import 'package:filenori_client/domain/entities/piece_entity.dart';

class FileEntity {
  final File file;
  final String filePath;
  final String fileName;
  final int fileSize;     // 바이트 단위
  final int pieceSize;    // 조각 크기
  final List<PieceEntity> pieces;

  FileEntity({
    required this.file,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.pieceSize,
    required this.pieces,
  });

  FileEntity copyWith({
    String? filePath,
    String? fileName,
    int? fileSize,
    int? pieceSize,
    List<PieceEntity>? pieces,
  }) {
    return FileEntity(  
      file: file,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      pieceSize: pieceSize ?? this.pieceSize,
      pieces: pieces ?? this.pieces,
    );
  }
}