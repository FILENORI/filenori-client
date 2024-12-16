// lib/application/riverpod/upload_notifier.dart
import 'dart:io';
import 'dart:math';
import 'package:filenori_client/application/riverpod/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/domain/usecases/upload_file_usecase.dart';

class UploadState {
  final bool isUploading;
  final double progress;

  const UploadState({
    required this.isUploading,
    required this.progress,
  });

  factory UploadState.initial() {
    return const UploadState(
      isUploading: false,
      progress: 0.0,
    );
  }

  UploadState copyWith({
    bool? isUploading,
    double? progress,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      progress: progress ?? this.progress,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final UploadFileUseCase uploadFileUseCase;

  UploadNotifier(this.uploadFileUseCase) : super(UploadState.initial());

  Future<void> uploadFile(File file) async {
    // 3~7초 사이의 랜덤 시간 선택
    final random = Random();
    final duration = Duration(seconds: random.nextInt(5) + 3); // 3 to 7 seconds
    final totalMilliseconds = duration.inMilliseconds;
    
    // 업로드 시작
    state = state.copyWith(isUploading: true, progress: 0.0);
    
    // 100ms마다 프로그레스 업데이트
    const updateInterval = Duration(milliseconds: 100);
    var elapsed = 0;
    
    while (elapsed < totalMilliseconds) {
      await Future.delayed(updateInterval);
      elapsed += updateInterval.inMilliseconds;
      
      // 부드러운 진행을 위해 Sine 함수 사용
      final progress = sin((elapsed / totalMilliseconds) * (pi / 2));
      state = state.copyWith(progress: progress);
    }
    
    // 업로드 완료
    state = state.copyWith(progress: 1.0);
    await Future.delayed(const Duration(milliseconds: 500));
    state = UploadState.initial();

    // 실제 파일 업로드 실행
    await uploadFileUseCase(file);
  }

  void initUpload(File file) {
    state = state.copyWith(isUploading: true, progress: 0.0);
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void completeUpload() {
    state = UploadState.initial();
  }
}

// Provider
final uploadNotifierProvider = StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final useCase = ref.watch(uploadFileUseCaseProvider);
  return UploadNotifier(useCase);
});