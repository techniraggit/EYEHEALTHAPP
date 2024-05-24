import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/rewards.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Api.dart';
import 'customDialog.dart';

class MyPlan extends StatefulWidget {
  @override
  MyPlanState createState() => MyPlanState();
}

class MyPlanState extends State<MyPlan> {
  late Future<List<Plan>> futurePlans;

  @override
  void initState() {
    super.initState();
    futurePlans = _getPlanApi(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eye Health Premium Plan'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Add your back button functionality here
          },
        ),
      ),
      body: FutureBuilder<List<Plan>>(
        future: futurePlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No plans available'));
          } else {
            final plans = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final features = plan.description.split('.');
                  return Container(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.white : Color(0xFF5900D9),
                      borderRadius: BorderRadius.circular(12.0),
                      // Corner radius
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 1.0, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 8.0),
                            child: Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    index.isEven ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '\$${plan.price}/${plan.planType}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: index.isEven
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...features.map((feature) => Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: index.isEven
                                        ? Color(0xFF5900D9)
                                        : Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: index.isEven
                                            ? Colors.grey.shade700
                                            : Colors.white,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                makePayment();
                                // Add your button onPressed logic here
                              },
                              child: Text('Buy Plan'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    index.isEven ? Colors.white : Colors.black,
                                backgroundColor: index.isEven
                                    ? Color(0xFF5900D9)
                                    : Colors.white,
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(100, 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('720', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              testEnv: true, currencyCode: "USD", merchantCountryCode: "US"),
          merchantDisplayName: 'Zukti Innovations',
          customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
          customerId: 'cus_Q99KA3BxJP2vY7',
          returnURL: 'flutterstripe://redirect',
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      print("exception $e");
      if (kDebugMode) {
        if (e is StripeConfigException) {
          print("Stripe exception ${e.message}");
        } else {
          print("exception $e");
        }
      }
    }
  }

  displayPaymentSheet() async {
    try {
      print("Display payment sheet");
      await Stripe.instance.presentPaymentSheet();
      print("Displayed successfully");
      // showDialog(
      //   context: context,
      //   builder: (_) => const AlertDialog(
      //     content: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Row(
      //           children: [
      //             Icon(Icons.check_circle, color: Colors.green),
      //             Text("Payment Successful"),
      //           ],
      //         ),
      //       ],
      //     ),
      //   ),
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
  }

  // Convert payment method types into separate entries
  List<String> paymentMethodTypes = ['card', 'google_pay', 'apple_pay'];

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
       // 'payment_method_types[]': 'card',
       // 'payment_method_types[]': ['card','Google Pay','Apple Pay'],
        'description': 'Software Testing',
        'customer': 'cus_Q99KA3BxJP2vY7',
        'metadata[plan_id]': 'db85c623-467d-4b16-b2a4-f057d55a526e',
        'metadata[user_id]': '32f7bf9a-42df-4c50-a5ac-30a49232cefd',
      };
      // Add each payment method type to the body
      for (var i = 0; i < paymentMethodTypes.length; i++) {
        body['payment_method_types[$i]'] = paymentMethodTypes[i];
      }
      var secretKey =
          "sk_test_51OJvAESInaGLb0MUtLmhP2IwmJa9JqTztYYFgrMnXbewAzgHKXeJqgKullONr7Oxj268IJt1i9GrwfYiSFuWHLF500ShZtLEZX";
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body: ${response.body.toString()}');
      return jsonDecode(response.body.toString());
    } catch (err) {
      print('Error charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
}

late final jsonResponse;

late List<Plan> plans;

Future<List<Plan>> _getPlanApi(BuildContext context) async {
  ProgressDialog? _progressDialog;

  _progressDialog = ProgressDialog(context); // Initialize ProgressDialog
  _progressDialog.show(); // Show ProgressDialog

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken =
        // "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTM5NDcyLCJpYXQiOjE3MTU4NTMwNzIsImp0aSI6ImU1ZjdmNjc2NzZlOTRkOGNhYjE1MmMyNmZlYjY4Y2Y5IiwidXNlcl9pZCI6IjA5ZTllYTU0LTQ0ZGMtNGVlMC04Y2Y1LTdlMTUwMmVlZTUzZCJ9.GdbpdA91F2TaKhuNC28_FO21F_jT_TxvkgGQ7t2CAVk";
        prefs.getString('access_token') ?? '';
    final response = await http.get(
      Uri.parse('${Api.baseurl}/api/subscription-plans'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      print("gggg${response.body}");
      _progressDialog.hide();
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      return data.map((planJson) => Plan.fromJson(planJson)).toList();
    } else {
      _progressDialog.hide();

      CustomAlertDialog.attractivepopup(
          context, 'Error message here: ${response.statusCode}');
    }
  } catch (e) {
    _progressDialog.hide();

    if (e is SocketException) {
      CustomAlertDialog.attractivepopup(
          context, 'Poor internet connectivity, please try again later!');
    } else {
      CustomAlertDialog.attractivepopup(context, 'Unknown error occurred');
    }
  }

  throw Exception('Failed to fetch data');
}

class Plan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String planType;
  final bool isActive;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.planType,
    required this.isActive,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      planType: json['plan_type'],
      isActive: json['is_active'],
    );
  }
}
