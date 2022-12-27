import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/image_upload/helpers/image_picker_helper.dart';
import 'package:instant_gram/state/image_upload/models/file_type.dart';
import 'package:instant_gram/state/post_settings/providers/post_settings_provider.dart';
import 'package:instant_gram/views/create_new_post/create_new_post_view.dart';
import 'package:instant_gram/views/tabs/search/search_view.dart';

import '../../state/auth/providers/auth_state_provider.dart';
import '../components/dialogs/alert_dialog_model.dart';
import '../components/dialogs/logout_dialog_model.dart';
import '../constants/strings.dart';
import '../tabs/user_posts/user_posts_view.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(Strings.appName),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.film),
              onPressed: () async {
                final pickedVideo =
                    await ImagePickerHelper.pickVideoFromGallery();
                if (pickedVideo == null) {
                  return;
                }

                ref.invalidate(postSettingsProvider);

                if (!mounted) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                        file: pickedVideo, fileType: FileType.video),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              onPressed: () async {
                final pickedImage =
                    await ImagePickerHelper.pickImageFromGallery();

                if (pickedImage == null) {
                  return;
                }

                ref.invalidate(postSettingsProvider);

                if (!mounted) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateNewPostView(
                      file: pickedImage,
                      fileType: FileType.image,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await LogoutDialogModel()
                    .present(context)
                    .then((value) => value ?? false);
                if (shouldLogout) {
                  await ref.read(authStateProvider.notifier).logOut();
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.home)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserPostsView(),
            SearchView(),
            UserPostsView(),
          ],
        ),
      ),
    );
  }
}
