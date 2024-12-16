import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:filenori_client/application/riverpod/upload_notifier.dart';
import 'package:filenori_client/presentation/viewmodels/file_viewmodel.dart';

import 'package:file_picker/file_picker.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // TODO: getFileList 결과값으로 대체
    final files = ref.watch(fileViewModelProvider);
    final uploadState = ref.watch(uploadNotifierProvider);
    final selectedFiles = useState<Set<String>>({});

    return Scaffold(
      appBar: AppBar(
        title: const Text('FileNori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Divider(color: Colors.grey),
            const SizedBox(height: 16),
            Text('서버에 등록된 파일'),
            Expanded(
              child: files.isEmpty
                  ? const Center(child: Text('서버에 등록된 파일이 없습니다.'))
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final isSelected = selectedFiles.value.contains(file.filePath);

                        return ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == true) {
                                selectedFiles.value = {...selectedFiles.value, file.filePath};
                              } else {
                                selectedFiles.value = {...selectedFiles.value}..remove(file.filePath);
                              }
                            },
                          ),
                          title: Text(file.fileName),
                          subtitle: Text('${(file.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  ref.read(fileViewModelProvider.notifier).downloadFile(file.filePath);
                                },
                              ),
                            ],
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