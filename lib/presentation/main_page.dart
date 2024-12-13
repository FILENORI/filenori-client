import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filenori_client/application/riverpod/upload_notifier.dart';
import 'package:filenori_client/presentation/viewmodels/file_viewmodel.dart';


import 'package:file_picker/file_picker.dart';

class MainPage extends ConsumerWidget {

  const MainPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final files = ref.watch(fileViewModelProvider);
    final uploadState = ref.watch(uploadNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FileNori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상단 버튼들 (업로드, 다운로드)
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      final selectedFilePath = result.files.single.path;
                      if (selectedFilePath != null) {
                        print(selectedFilePath);
                        // 2. ViewModel 통해 업로드
                        ref.read(fileViewModelProvider.notifier).uploadFile(selectedFilePath);
                      }
                    }
                  },
                  child: const Text('파일 업로드'),
                ),
                const SizedBox(width: 16),
                if (uploadState.isUploading)
                  Expanded(
                    child: LinearProgressIndicator(
                      value: uploadState.progress,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 파일 목록
            Expanded(
              child: files.isEmpty
                  ? const Center(child: Text('서버에 등록된 파일이 없습니다.'))
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];

                        return ListTile(
                          title: Text(file.fileName),
                          subtitle: Text('${(file.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ref.read(fileViewModelProvider.notifier).deleteFile(file.filePath);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}