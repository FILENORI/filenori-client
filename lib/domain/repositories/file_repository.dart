import 'dart:io';
import 'package:filenori_client/domain/entities/file_entity.dart';

abstract class FileRepository {
  /// 로컬 파일을 조각 단위로 읽어 [FileEntity] 반환
  Future<FileEntity> createFileEntity(File file);

  /// [File]의 조각들을 업로드 후, 업로드 상태를 반영한 새 [File]를 반환
  // Future<FileEntity> uploadFilePieces(FileEntity fileEntity);
  Future<void> uploadFilePieces(File file);
}