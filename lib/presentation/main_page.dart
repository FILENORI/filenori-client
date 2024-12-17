import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:filenori_client/application/riverpod/upload_notifier.dart';
import 'package:filenori_client/application/riverpod/download_notifier.dart';
import 'package:filenori_client/presentation/viewmodels/file_viewmodel.dart';

import 'package:file_picker/file_picker.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // TODO: getFileList 결과값으로 대체
    final files = ref.watch(fileViewModelProvider);
    // final files = [
    //   FileInfoState(
    //     fileName: 'test1.txt',
    //     filePath: 'test1.txt',
    //     fileSize: 1.0,
    //   ),
    //   FileInfoState(
    //     fileName: 'test2.txt',
    //     filePath: 'test2.txt',
    //     fileSize: 2.0,
    //   ),
    // ];
    final uploadState = ref.watch(uploadNotifierProvider);
    final downloadState = ref.watch(downloadNotifierProvider);
    final selectedFiles = useState<Set<String>>({});

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'FILENORI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              ref.read(fileViewModelProvider.notifier).refreshFileList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('파일 업로드'),
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final selectedFilePath = result.files.single.path;
                          if (selectedFilePath != null) {
                            print(selectedFilePath);
                            ref.read(fileViewModelProvider.notifier).uploadFile(selectedFilePath);
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    if (uploadState.isUploading)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '업로드 중... ${(uploadState.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: uploadState.progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[700]!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '서버에 등록된 파일',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${files.length}개',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: files.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '서버에 등록된 파일이 없습니다.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: files.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final isSelected = selectedFiles.value.contains(file.filePath);

                          return ListTile(
                            leading: Icon(
                              Icons.insert_drive_file,
                              color: Colors.blue[700],
                            ),
                            title: Text(
                              file.fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${(file.fileSize).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: downloadState.isDownloaded(file.filePath)
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green[600],
                                        )
                                      : downloadState.isDownloading(file.filePath)
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.blue[700]!,
                                                    ),
                                                  ),
                                                  Tooltip(
                                                    message: '다운로드 중...\nIP: ${downloadState.getDownloadIP(file.filePath)}',
                                                    child: const Icon(
                                                      Icons.downloading,
                                                      size: 16,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Icon(
                                              Icons.download,
                                              color: Colors.grey[600],
                                            ),
                                  onPressed: () {
                                    if (!downloadState.isDownloading(file.filePath) &&
                                        !downloadState.isDownloaded(file.filePath)) {
                                      ref.read(fileViewModelProvider.notifier).downloadFile(file.filePath);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}