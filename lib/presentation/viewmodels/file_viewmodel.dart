// lib/presentation/viewmodels/file_viewmodel.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/domain/usecases/upload_file_usecase.dart';
import 'package:filenori_client/domain/usecases/get_filelist_usecase.dart';
import 'package:filenori_client/domain/usecases/download_file_usecase.dart';
import 'package:filenori_client/application/riverpod/upload_notifier.dart';
import 'package:filenori_client/application/riverpod/download_notifier.dart';
import 'package:filenori_client/application/riverpod/providers.dart';

// 뷰모델 상태로 사용할 파일 정보
class FileInfoState {
  final String fileName;
  final String filePath;
  final double fileSize;

  FileInfoState({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
  });
}

class FileViewModel extends StateNotifier<List<FileInfoState>> {
  final GetFileListUseCase getFileListUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final DownloadFileUseCase downloadFileUseCase;
  final UploadNotifier uploadNotifier;
  final DownloadNotifier downloadNotifier;

  FileViewModel({
    required this.getFileListUseCase,
    required this.uploadFileUseCase,
    required this.downloadFileUseCase,
    required this.uploadNotifier,
    required this.downloadNotifier,
  }) : super([]) {
    refreshFileList(); // 초기 로드
  }

  Future<void> refreshFileList() async {
    try {
      final files = await getFileListUseCase();
      print(files);
      state = files.map((file) => FileInfoState(
        fileName: file.path.split('/').last,
        filePath: file.path,
        fileSize: file.lengthSync() / (1024 * 1024), // Convert to MB
      )).toList();
    } catch (e) {
      print('Error refreshing file list: $e');
      state = [];
    }
  }

  Future<void> uploadFile(String filePath) async {
    final file = File(filePath);
    await uploadNotifier.uploadFile(file);
    await refreshFileList();
  }

  Future<void> downloadFile(String filePath) async {
    final ip = await downloadFileUseCase(filePath);
    await downloadNotifier.downloadFile(filePath, ip);
  }
}

// Provider
final fileViewModelProvider = StateNotifierProvider<FileViewModel, List<FileInfoState>>((ref) {
  final uploadUseCase = ref.watch(uploadFileUseCaseProvider);
  final downloadUseCase = ref.watch(downloadFileUseCaseProvider);
  final getFileListUseCase = ref.watch(getFileListUseCaseProvider);
  final uploadNotifier = ref.watch(uploadNotifierProvider.notifier);
  final downloadNotifier = ref.watch(downloadNotifierProvider.notifier);
  
  return FileViewModel(
    uploadFileUseCase: uploadUseCase,
    downloadFileUseCase: downloadUseCase,
    getFileListUseCase: getFileListUseCase,
    uploadNotifier: uploadNotifier,
    downloadNotifier: downloadNotifier,
  );
});