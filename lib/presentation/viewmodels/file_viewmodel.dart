// lib/presentation/viewmodels/file_viewmodel.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/domain/usecases/upload_file_usecase.dart';
import 'package:filenori_client/application/riverpod/upload_notifier.dart';
import 'package:filenori_client/application/riverpod/providers.dart';
// 뷰모델 상태로 사용할 파일 정보
class FileInfoState {
  final String fileName;
  final String filePath;
  final double fileSize; // bytes, MB 등

  FileInfoState({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
  });
}

class FileViewModel extends StateNotifier<List<FileInfoState>> {
  final UploadFileUseCase uploadFileUseCase; 
  final UploadNotifier uploadNotifier; // 업로드 진행 상황을 따로 관리하는 Notifier

  FileViewModel(this.uploadFileUseCase, this.uploadNotifier) : super([]);

  // 파일 업로드 메서드
  Future<void> uploadFile(String filePath) async {
    // 1. UseCase를 통해 파일 업로드 진행
    // 2. 업로드가 완료되면 state에 반영(파일 목록을 업데이트)

    // 예: 파일명, 크기 추출(대략적)
    final file = File(filePath);

    // FileEntity 생성

    // Riverpod Notifier를 통해 실제 업로드 진행
    await uploadNotifier.uploadFile(file);

    // 업로드가 완료됐다고 가정하면, 파일 목록에 추가
    final newFile = FileInfoState(
      fileName: filePath.split('/').last,
      filePath: filePath,
      fileSize: file.readAsBytesSync().lengthInBytes / 1024 * 1024,
    );
    // state is List<FileInfoState>
    state = [...state, newFile];
  }

  void deleteFile(String filePath) {
    state = state.where((f) => f.filePath != filePath).toList();
  }


}

// Provider
final fileViewModelProvider = StateNotifierProvider<FileViewModel, List<FileInfoState>>((ref) {
  final uploadUseCase = ref.watch(uploadFileUseCaseProvider);
  final uploadNotifier = ref.watch(uploadNotifierProvider.notifier);
  return FileViewModel(uploadUseCase, uploadNotifier);
});