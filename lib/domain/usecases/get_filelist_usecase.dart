import 'dart:io';
import 'package:filenori_client/domain/entities/file_entity.dart';
import 'package:filenori_client/domain/repositories/file_repository.dart';

class GetFileListUseCase {
  final FileRepository fileRepository;

  GetFileListUseCase(this.fileRepository);

  Future<List<File>> call() async{
    return await fileRepository.getFileList();
  }
} 