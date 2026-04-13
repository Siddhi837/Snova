import 'package:flutter/material.dart';
import 'package:snova/screens/utils/dialog_type.dart';

class CommonPopupDialog {
  static void show({
    required BuildContext contxt,
    required String title,
    required String msg,
    required DialogType type,
    VoidCallback? onCompleted,
    int autoCloseSeconds = 3,
  }) {
    final bool isSuccess = type == DialogType.success;

    showDialog(
      context: contxt,
      barrierDismissible: false,
      builder: (dialogContext) {
        if (autoCloseSeconds > 0) {
          Future.delayed(Duration(seconds: autoCloseSeconds), () {
            if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
            if (isSuccess && onCompleted != null) {
              onCompleted();
            }
          });
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.black : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check : Icons.warning,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// Message
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// Loader only for success
                if (isSuccess) const CircularProgressIndicator(),

                /// Button only for error
                if (!isSuccess)
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    },
                    child: const Text(
                      "",
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}