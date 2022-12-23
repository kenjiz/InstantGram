import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../constants/firebase_collection_name.dart';
import '../../post_settings/models/post_setting.dart';
import '../../posts/models/post_payload.dart';
import '../../posts/typedefs/user_id.dart';
import '../constants/constants.dart';
import '../exceptions/could_not_build_thumbnail_exception.dart';
import '../extensions/get_collection_name_from_file_types.dart';
import '../extensions/get_image_data_aspect_ratio.dart';
import '../models/file_type.dart';
import '../typedefs/is_loading.dart';

class ImageUploadNotifier extends StateNotifier<IsLoading> {
  ImageUploadNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> upload({
    required File file,
    required FileType fileType,
    required String message,
    required Map<PostSetting, bool> postSettings,
    required UserId userId,
  }) async {
    isLoading = true;
    late Uint8List thumbnailUint8List;

    switch (fileType) {
      case FileType.image:
        final fileAsImage = img.decodeImage(file.readAsBytesSync());
        if (fileAsImage == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        }
        // create thumbnail
        final thumbnail = img.copyResize(
          fileAsImage,
          width: Constants.imageThumbnailWidth,
        );

        final thumbnailData = img.encodeJpg(thumbnail);
        thumbnailUint8List = Uint8List.fromList(thumbnailData);
        break;
      case FileType.video:
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: file.path,
          maxHeight: Constants.videoThumbnailMaxHeight,
          quality: Constants.videoThumbnailQuality,
        );
        if (thumbnail == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        }
        thumbnailUint8List = thumbnail;
        break;
    }

    final fileName = const Uuid().v4();

    // calculate the aspect ratio
    final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

    // create reference to the thumbnail and the image itself
    final thumbnailRef = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(FirebaseCollectionName.thumbnails)
        .child(fileName);

    final originalFileRef = FirebaseStorage.instance
        .ref()
        .child(userId)
        .child(fileType.getCollectionName())
        .child(fileName);

    try {
      // upload thumbnail
      final thumbnailUploadTask =
          await thumbnailRef.putData(thumbnailUint8List);

      final thumbnailStorageId = thumbnailUploadTask.ref.name;

      // upload original file
      final originalFileUploadTask = await originalFileRef.putFile(file);
      final originalFileStorageId = originalFileUploadTask.ref.name;

      // upload the post itself
      final postPayload = PostPayload(
        userId: userId,
        message: message,
        thumbnailUrl: await thumbnailRef.getDownloadURL(),
        fileUrl: await originalFileRef.getDownloadURL(),
        fileType: fileType,
        fileName: fileName,
        aspectRatio: thumbnailAspectRatio,
        thumbnailStorageId: thumbnailStorageId,
        originalFileStorageId: originalFileStorageId,
        postSettings: postSettings,
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .add(postPayload);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
