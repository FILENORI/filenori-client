import 'dart:io';
import 'package:filenori_client/domain/repositories/file_repository.dart';

class DownloadFileUseCase {
  final FileRepository fileRepository;

  DownloadFileUseCase(this.fileRepository);

  Future<String> call(String filePath) async {
    return await fileRepository.downloadFile(filePath);
  }
}