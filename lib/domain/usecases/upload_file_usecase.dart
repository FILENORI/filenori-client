import 'dart:io';
import 'package:filenori_client/domain/entities/file_entity.dart';
import 'package:filenori_client/domain/repositories/file_repository.dart';

class UploadFileUseCase {
  final FileRepository fileRepository;

  UploadFileUseCase(this.fileRepository);

  /// filePath -> 조각화 -> 업로드 -> 최종 FileEntify 반환
  Future<void> call(File file) async{
    // 1. filePath -> FileEntify (파일 조각화)
    // final fileEntity = await fileRepository.createFileEntity(file);
    // print('fileEntity: $fileEntity');
    // 2. FileEntify -> 업로드
    await fileRepository.uploadFilePieces(file);

  }
} 