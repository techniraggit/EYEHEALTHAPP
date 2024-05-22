import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog {
  static void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  static void eyetstcomplete(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: ()  {

                Navigator.of(context).pop();
              },
              child: Text('ok'),
            ),
          ],
        );
      },
    );
  }



  static void attractivepopup2(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(true); // Close the dialog after 3 seconds
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
          ), content: Text(message),


        );
      },
    );
  }




  static void attractivepopupnodelay(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
          ), content: Text(message),


        );
      },
    );
  }


  static void attractivepopupfunc(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true); // Close the dialog after 3 seconds
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0), // Adjust the border radius as needed
          ),  content: Row(
          children: [
            Icon(
              Icons.settings, // Change the icon as needed
              color: Colors.blue, // Change the color as needed
            ),
            SizedBox(width: 2), // Adjust spacing between icon and text
            Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),

        );
      },
    );
  }
  static void attractivepopupcoming(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true); // Close the dialog after 3 seconds
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
          ),  content: Row(
          children: [
            Icon(
              Icons.settings, // Change the icon as needed
              color: Colors.blue, // Change the color as needed
            ),
            SizedBox(width: 8), // Adjust spacing between icon and text
            Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        );
      },
    );
  }




  static void attractivepopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(true); // Close the dialog after 3 seconds
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust the border radius as needed
          ), content: Text(message),


        );
      },
    );
  }



  static void eyetstcompletedsucess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Well Done!'),
          content: Text(message),
          actions: <Widget>[

          ],
        );
      },
    );
  }

  static void showNoDataConnectionPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Data Connection'),
          content: Text('You are not connected to the internet.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}