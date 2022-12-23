import 'package:flutter/foundation.dart' show immutable;
import 'package:instant_gram/views/components/constants/strings.dart';
import 'package:instant_gram/views/components/dialogs/alert_dialog_model.dart';

@immutable
class DeleteDialog extends AlertDialogModel<bool> {
  DeleteDialog({
    required String titleOfObjectToDelete,
  }) : super(
          title: '${Strings.delete} $titleOfObjectToDelete',
          message:
              '${Strings.areYouSureYouWantToDeleteThis} $titleOfObjectToDelete',
          buttons: {
            Strings.cancel: false,
            Strings.delete: true,
          },
        );
}
