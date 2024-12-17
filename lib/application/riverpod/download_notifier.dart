import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadState {
  final Map<String, bool> downloadedFiles;
  final Map<String, bool> downloadingFiles;
  final Map<String, String> downloadIPs;

  const DownloadState({
    required this.downloadedFiles,
    required this.downloadingFiles,
    required this.downloadIPs,
  });

  factory DownloadState.initial() {
    return const DownloadState(
      downloadedFiles: {},
      downloadingFiles: {},
      downloadIPs: {},
    );
  }

  DownloadState copyWith({
    Map<String, bool>? downloadedFiles,
    Map<String, bool>? downloadingFiles,
    Map<String, String>? downloadIPs,
  }) {
    return DownloadState(
      downloadedFiles: downloadedFiles ?? this.downloadedFiles,
      downloadingFiles: downloadingFiles ?? this.downloadingFiles,
      downloadIPs: downloadIPs ?? this.downloadIPs,
    );
  }

  bool isDownloading(String filePath) => downloadingFiles[filePath] ?? false;
  bool isDownloaded(String filePath) => downloadedFiles[filePath] ?? false;
  String? getDownloadIP(String filePath) => downloadIPs[filePath];
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  DownloadNotifier() : super(DownloadState.initial());

  Future<void> downloadFile(String filePath, String ip) async {
    if (state.isDownloading(filePath) || state.isDownloaded(filePath)) return;

    state = state.copyWith(
      downloadingFiles: {...state.downloadingFiles, filePath: true},
      downloadIPs: {...state.downloadIPs, filePath: ip},
    );

    await Future.delayed(Duration(seconds: Random().nextInt(4) + 3));

    state = state.copyWith(
      downloadingFiles: {...state.downloadingFiles}..remove(filePath),
      downloadedFiles: {...state.downloadedFiles, filePath: true},
    );
  }
}

final downloadNotifierProvider = StateNotifierProvider<DownloadNotifier, DownloadState>((ref) {
  return DownloadNotifier();
});
