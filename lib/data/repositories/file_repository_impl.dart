import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:filenori_client/domain/entities/file_entity.dart';
import 'package:filenori_client/domain/entities/piece_entity.dart';
import 'package:filenori_client/domain/repositories/file_repository.dart';
import 'package:filenori_client/data/services/local_file_service.dart';
import 'package:filenori_client/data/services/network_service.dart';

class FileRepositoryImpl implements FileRepository {
  final LocalFileService localFileService;
  final NetworkService networkService;

  FileRepositoryImpl({
    required this.localFileService,
    required this.networkService,
  });

  @override
  Future<FileEntity> createFileEntity(File file) {
    return localFileService.createFileEntityFromLocalPath(file);
  }

  @override
  Future<FileEntity> uploadFilePieces(FileEntity fileEntity) async {
    for (final piece in fileEntity.pieces) {
      await networkService.uploadPiece(
        fileName: fileEntity.fileName,
        pieceIndex: piece.index,
        data: piece.data,
      );
    }
    return fileEntity.copyWith(
      pieces: fileEntity.pieces.map((piece) => piece.copyWith(isUploaded: true)).toList(),);
  }
}