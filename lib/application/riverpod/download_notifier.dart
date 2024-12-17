import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadState {
  final Map<String, bool> downloadedFiles;
  final Map<String, bool> downloadingFiles;

  const DownloadState({
    required this.downloadedFiles,
    required this.downloadingFiles,
  });

  factory DownloadState.initial() {
    return const DownloadState(
      downloadedFiles: {},
      downloadingFiles: {},
    );
  }

  DownloadState copyWith({
    Map<String, bool>? downloadedFiles,
    Map<String, bool>? downloadingFiles,
  }) {
    return DownloadState(
      downloadedFiles: downloadedFiles ?? this.downloadedFiles,
      downloadingFiles: downloadingFiles ?? this.downloadingFiles,
    );
  }

  bool isDownloading(String filePath) => downloadingFiles[filePath] ?? false;
  bool isDownloaded(String filePath) => downloadedFiles[filePath] ?? false;
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(DownloadState.initial());

  Future<void> downloadFile(String filePath) async {
    if (state.isDownloading(filePath) || state.isDownloaded(filePath)) return;

    // 다운로드 시작
    state = state.copyWith(
      downloadingFiles: {...state.downloadingFiles, filePath: true},
    );

    // 3~7초 랜덤 다운로드 시간
    final random = Random();
    final duration = Duration(seconds: random.nextInt(5) + 3);
    await Future.delayed(duration);

    // 다운로드 완료
    state = state.copyWith(
      downloadingFiles: {...state.downloadingFiles}..remove(filePath),
      downloadedFiles: {...state.downloadedFiles, filePath: true},
    );
  }
}

final downloadNotifierProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier();
});
