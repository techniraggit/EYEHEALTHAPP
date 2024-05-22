class ApiProvider{

  //static const baseUrl = "http://192.168.29.221:8000";
  static const baseUrl = "http://192.168.29.221:8000";

  static const verifyEmailOtp = "/api/verification_otp";//verify email during signup
  static const sendVerifyOtp = "/api/verification_otp";
  static const register = "/api/register";
  static const sendLoginOtp = "/api/send_login_otp";
  static const verifyLoginOtp = "/api/verify_login_otp";
  static const validateReferralCode_ = "/api/validate_referral_code";
  static const getUserProfile = "/api/profile";
  static const updateUserProfile = "/api/profile";
  static const updateProfilepic='/api/profile';
  static const get_notification='/api/user_notification';
  static const update_notification_status='/api/user_notification';
  static const getOffers_detail='/api/offers';
  static const uploadPrescription='/api/prescription';
  static const getaddress='/api/address';








}

// void forgotApi(String email, BuildContext context) async {
//   EasyLoading.show();
//
//   try {
//     Response response = await post(
//       Uri.parse('${ApiProvider.baseUrl}${ApiProvider.forgot}'),
//       body: {
//         'email': email,
//       },
//         headers: {
//           'Authenticate-Realm': 'APP', // Bearer token type
// //'Content-Type': 'application/json',
//         },
//     );
//     print('Response Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');
//     // Close the loading dialog
//     EasyLoading.dismiss();
//     if (response.statusCode == 200) {
//       print("Success Forgot Api");
// // Parse the response body
//       Map<String, dynamic> responseData = json.decode(response.body);
// // Check if the 'status' is true and the 'message' is present
//       if (responseData['status'] == true &&
//           responseData.containsKey('message')) {
//         String message = responseData['message'];
// // Show the toast message
//         Fluttertoast.showToast(msg: message);
//       }
//     } else {
//       Map<String, dynamic> data = json.decode(response.body);
//       print("Login failed");
//
// // Show error message as toast
//       Fluttertoast.showToast(msg: data['message'] ?? "");
//     }
//   } catch (e) {
//     EasyLoading.dismiss();
//     print('Error1111111: $e');
//     if (e is SocketException) {
//       print('No Internet Connection');
// // Show error message as toast
//       Fluttertoast.showToast(msg: "No Internet Connection");
//     }
//     if (e is FormatException) {
//       print('Invalid JSON Format11$e');
//       EasyLoading.dismiss();
//
// // Show error message as toast
//       //  Fluttertoast.showToast(msg: "Invalid JSON Format");
//     }
// // Add more specific error handling based on your needs
//   }
//   Future.delayed(const Duration(seconds: 1), () {
//     Navigator.pop(context);
//   });
//
//   // Navigator.pop(context);
// }