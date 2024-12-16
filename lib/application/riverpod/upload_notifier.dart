// lib/application/riverpod/upload_notifier.dart
import 'dart:io';
import 'package:filenori_client/application/riverpod/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/domain/entities/file_entity.dart';
import 'package:filenori_client/domain/usecases/upload_file_usecase.dart';

class UploadState {
  final bool isUploading;
  final double progress;       // 0.0 ~ 1.0
  final FileEntity? fileEntity;
  final String? errorMessage;

  UploadState({
    this.isUploading = false,
    this.progress = 0.0,
    this.fileEntity,
    this.errorMessage,
  });

  UploadState copyWith({
    bool? isUploading,
    double? progress,
    FileEntity? fileEntity,
    String? errorMessage,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
      fileEntity: fileEntity ?? this.fileEntity,
      errorMessage: errorMessage,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadFileUseCase uploadFileUseCase;

  UploadNotifier(this.uploadFileUseCase) : super(UploadState());

  Future<void> uploadFile(File file) async {
    state = state.copyWith(isUploading: true, progress: 0.0, errorMessage: null);

    const pieceSize = 1024 * 1024; // 1MB 예시

    try {
      // 파일 조각화 & 업로드
      final fileEntity = await uploadFileUseCase(file);

      // // 업로드 완료 후, 조각 중 업로드된 개수를 계산
      // final totalPieces = fileEntity.pieces.length;
      // final uploadedCount = fileEntity.pieces.where((p) => p.isUploaded).length;
      // final progress = (uploadedCount / totalPieces);

      // state = state.copyWith(
      //   isUploading: false,
      //   progress: progress,
      //   fileEntity: fileEntity,
      // );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider for the UploadNotifier
final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final useCase = ref.watch(uploadFileUseCaseProvider);
  return UploadNotifier(useCase);
});