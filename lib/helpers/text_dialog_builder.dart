import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../utilities/app_logger.dart';

Future<String?> textDialogBuilder({
  required String title,
  required BuildContext context,
  required TextEditingController textFieldController,
  String textFieldInitialValue = '',
  bool clearTextFieldOnCancel = true,
}) async {
  textFieldController.text = textFieldInitialValue;
  return showDialog<String?>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: CupertinoTextField(
        autofocus: true,
        controller: textFieldController,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (clearTextFieldOnCancel == true) {
              textFieldController.clear();
            }
            AppLogger().logger.i('Cancelled');
          },
          child: const Text(
            'Cancel',
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(textFieldController.text);
            textFieldController.clear();
          },
          child: const Text(
            'Save',
          ),
        )
      ],
    ),
  );
}
