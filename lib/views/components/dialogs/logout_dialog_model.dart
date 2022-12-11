import 'package:instant_gram/views/components/dialogs/alert_dialog_model.dart';

import '../constants/strings.dart';

class LogoutDialogModel extends AlertDialogModel<bool> {
  LogoutDialogModel()
      : super(
          title: Strings.logOut,
          message: Strings.areYouSureThatYouWantToLogOutOfTheApp,
          buttons: {
            Strings.cancel: false,
            Strings.logOut: true,
          },
        );
}
