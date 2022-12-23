import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/auth/providers/user_id_provider.dart';
import 'package:instant_gram/state/image_upload/models/thumbnail_request.dart';
import 'package:instant_gram/state/image_upload/providers/image_uploader_provider.dart';
import 'package:instant_gram/state/post_settings/providers/post_settings_provider.dart';
import 'package:instant_gram/views/components/file_thumbnail_view.dart';

import '../../state/image_upload/models/file_type.dart';
import '../../state/post_settings/models/post_setting.dart';
import '../constants/strings.dart';

class CreateNewPostView extends StatefulHookConsumerWidget {
  final File file;
  final FileType fileType;
  const CreateNewPostView({
    super.key,
    required this.file,
    required this.fileType,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewPostViewState();
}

class _CreateNewPostViewState extends ConsumerState<CreateNewPostView> {
  @override
  Widget build(BuildContext context) {
    final thumbnailRequest = ThumbnailRequest(
      file: widget.file,
      fileType: widget.fileType,
    );

    final postSettings = ref.watch(postSettingsProvider);
    final postController = useTextEditingController();
    final isButtonEnabled = useState(false);

    useEffect(() {
      void listener() {
        isButtonEnabled.value = postController.text.isNotEmpty;
      }

      postController.addListener(listener);
      return () {
        postController.removeListener(listener);
      };
    }, [
      postController,
    ]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          Strings.createNewPost,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: isButtonEnabled.value
                ? () async {
                    final userId = ref.read(userIdProvider);
                    if (userId == null) {
                      return;
                    }
                    final message = postController.text;
                    final isUploaded =
                        await ref.read(imageUploadProvider.notifier).upload(
                              file: widget.file,
                              fileType: widget.fileType,
                              message: message,
                              postSettings: postSettings,
                              userId: userId,
                            );
                    if (isUploaded && mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FileThumbnailView(
              thumbnailRequest: thumbnailRequest,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: postController,
                decoration: const InputDecoration(
                  labelText: Strings.pleaseWriteYourMessageHere,
                ),
                maxLines: null,
                autofocus: true,
              ),
            ),
            ...PostSetting.values.map(
              (postSetting) => ListTile(
                title: Text(postSetting.title),
                subtitle: Text(postSetting.description),
                trailing: Switch(
                  value: postSettings[postSetting] ?? false,
                  onChanged: (isOn) {
                    ref
                        .read(postSettingsProvider.notifier)
                        .setSetting(postSetting, isOn);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
