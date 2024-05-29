import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class MyProgressDialog {
  static ProgressDialog createProgressDialog(BuildContext context) {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Loading...', // Default message
      progressWidget: CircularProgressIndicator(),
    );
    return progressDialog;
  }

  static ProgressDialog showProgressDialog(BuildContext context, String message) {
    ProgressDialog progressDialog = createProgressDialog(context);
    progressDialog.update(message: message); // Use update instead of setMessage
    progressDialog.show();
    return progressDialog; // Return progressDialog to dismiss it later
  }

  static void dismissProgressDialog(ProgressDialog progressDialog) {
    progressDialog.hide(); // Use hide() to dismiss the dialog
  }
}
