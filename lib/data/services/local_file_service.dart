// lib/data/services/local_file_service.dart
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:filenori_client/domain/entities/file_entity.dart';
import 'package:filenori_client/domain/entities/piece_entity.dart';

class LocalFileService {
  Future<FileEntity> createFileEntityFromLocalPath(File file) async {
    final fileName = p.basename(file.path);
    final fileSize = await file.length();
    const pieceSize = 1024 * 1024;

    final pieces = <PieceEntity>[];
    final raf = file.openSync(mode: FileMode.read);
    try {
      int index = 0;
      int offset = 0;
      while (offset < fileSize) {
        final remaining = fileSize - offset;
        final readSize = (remaining < pieceSize) ? remaining : pieceSize;

        final buffer = raf.readSync(readSize);
        pieces.add(PieceEntity(index: index, data: buffer));
        index++;
        offset += readSize;
      }
    } finally {
      raf.closeSync();
    }

    return FileEntity(
      file: file,
      filePath: file.path,
      fileName: fileName,
      fileSize: fileSize,
      pieceSize: pieceSize,
      pieces: pieces,
    );
  }
}