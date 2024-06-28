
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayIntegration{
final Razorpay _razorpay = Razorpay();
initiateRazorPay() {
// To handle different event with previous functions
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
}

void _handlePaymentSuccess(PaymentSuccessResponse response) {
// Do something when payment succeeds
}

void _handlePaymentError(PaymentFailureResponse response) {
// Do something when payment fails
}

void _handleExternalWallet(ExternalWalletResponse response) {
// Do something when an external wallet is selected
}
OpenSession(num amount){
// to get orderid by creating new order everytime
// you try to open razorpay checkout page
  createOrder(amount: amount).then((orderId) {
  print(orderId);
  if (orderId.toString().isNotEmpty) {
  var options = {
  // Razorpay API Key
  'key': razorPayKey,
  // in the smallest
  // currency sub-unit.
  'amount': amount,
  'name': 'Company Name.',
  // Generate order_id
  // using Orders API
  'order_id': orderId,
  // Order Description to be
  // shown in razor pay page
  'description':
  'Description for order',
  // in seconds
  'timeout': 60,
  'prefill': {
  'contact': '9123456789',
  'email': 'flutterwings304@gmail.com'
  } // contact number and email id of user
  };

  } else {}
  });
  _razorpay.open(options);

}

}