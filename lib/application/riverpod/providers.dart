// lib/application/riverpod/providers.dart
import 'package:filenori_client/domain/usecases/get_filelist_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/data/repositories/file_repository_impl.dart';
import 'package:filenori_client/data/services/local_file_service.dart';
import 'package:filenori_client/data/services/network_service.dart';
import 'package:filenori_client/domain/repositories/file_repository.dart';
import 'package:filenori_client/domain/usecases/upload_file_usecase.dart';
import 'package:filenori_client/domain/usecases/download_file_usecase.dart';

// 1. Service들
final localFileServiceProvider = Provider<LocalFileService>((ref) {
  return LocalFileService();
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

// 2. FileRepository 구현체
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepositoryImpl(
    localFileService: ref.watch(localFileServiceProvider),
    networkService: ref.watch(networkServiceProvider),
  );
});

// 3. UseCase
final uploadFileUseCaseProvider = Provider<UploadFileUseCase>((ref) {
  return UploadFileUseCase(
    ref.watch(fileRepositoryProvider),
  );
});

final getFileListUseCaseProvider = Provider<GetFileListUseCase>((ref) {
  return GetFileListUseCase(
    ref.watch(fileRepositoryProvider),
  );
});

final downloadFileUseCaseProvider = Provider<DownloadFileUseCase>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  return DownloadFileUseCase(repository);
});