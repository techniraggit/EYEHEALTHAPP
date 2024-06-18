import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart' as htmlParser;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/Rewards/rewards.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/Api.dart';
import '../api/config.dart';
import '../Custom_navbar/customDialog.dart';

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
    checkActivePlan("");
  }

  late String PlanId;
  dynamic selectedPlanId = '';
  bool isActivePlan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Eye Health Premium Plan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Plan>>(
        future: futurePlans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No plans available'));
          } else {
            final plans = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.38,
                ),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];

                  // final features = plan.description.split('.');
                  List<String> _parseHtml(String htmlString) {
                    var document = htmlParser.parse(htmlString);
                    var elements = document.querySelectorAll('li');
                    return elements.map((element) => element.text).toList();
                  }

                  List<String> features = _parseHtml(plan.description);

                  bool isSelected = plan.id == selectedPlanId;
                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      // Corner radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          // Shadow color with opacity
                          spreadRadius: 2,
                          // Spread radius
                          blurRadius: 5,
                          // Blur radius
                          offset: const Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 8.0),
                            child: Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '\₹${plan.price}/${plan.planType}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
    for(int i=0;i<features.length;i++)...{
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
    children: [
    Icon(
    Icons.check,
    color: Colors.blue,
    size: 20,
    ),
    const SizedBox(width: 5),
    Expanded(
    child: Text(
    features[index],
    style: TextStyle(
    fontSize: 16,
    color: Colors.grey.shade700,
    fontStyle: FontStyle.normal,
    ),
    ),
    ),
    ],
    ),
    )},

                          // ...features.map((feature) =>
                          //     Row(
                          //       children: [
                          //         Icon(
                          //           Icons.check,
                          //           color: isSelected
                          //               ? Colors.bluebutton
                          //               : Colors.bluebutton,
                          //           size: 20,
                          //         ),
                          //         const SizedBox(width: 5),
                          //         Expanded(
                          //           child: Text(
                          //             feature,
                          //             style: TextStyle(
                          //               fontSize: 16,
                          //               color: Colors.grey.shade700,
                          //               fontStyle: FontStyle.normal,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     )),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                checkActivePlan(plan.price);
                                PlanId = plan.id;
                                // Add your button onPressed logic here
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                isSelected ? Colors.black : Colors.white,
                                backgroundColor: isSelected
                                    ? Colors.deepPurple.shade100
                                    : Colors.bluebutton,
                                padding: const EdgeInsets.all(10),
                                minimumSize: const Size(100, 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: Text(isSelected ? 'Selected' : 'Buy Plan'),
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

  String CustomerId = '',
      UserId = '';
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment(String price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    CustomerId = prefs.getString('stripe_customer_id') ?? '';
    UserId = prefs.getString('user_id') ?? '';
    print("amounr");
    try {
      paymentIntent = await createPaymentIntent(price, 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
              testEnv: true, currencyCode: "USD", merchantCountryCode: "US"),
          merchantDisplayName: 'Zukti Innovations',
          customerEphemeralKeySecret: paymentIntent!['ephemeralKey'],
          customerId: CustomerId,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paid successfully")),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (_) =>
        const AlertDialog(
          content: Text("Cancelled"),
        ),
      );
    } catch (e) {
      print("Error in displaying");
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': 'Software Testing',
        'customer': CustomerId,
      };
      body.addAll({
        'metadata[plan_id]': PlanId,
        'metadata[user_id]': UserId,
        // Example metadata
      });
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
    final calculatedAmount = (double.parse(amount) * 100).toInt();
    return calculatedAmount.toString();
  }

  void checkActivePlan(String price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('access_token') ?? '';

     try {
    final response = await http.get(
      Uri.parse(ApiProvider.baseUrl + ApiProvider.isActivePlan),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // _progressDialog!.hide();

      final jsonResponse = jsonDecode(response.body);

      // Access the value of is_verified
      isActivePlan = jsonResponse['is_active_plan'];
      selectedPlanId = jsonResponse['plan_id'];

      setState(() {
        if (isActivePlan == false) {
          makePayment(price);
        } else {
          Fluttertoast.showToast(msg: "you already have an active plan !!");
        }
      });

      print("responseviewprofile:${response.body}");

      return json.decode(response.body);
    } else {
      // _progressDialog!.hide();

      print(response.body);
    }
  }
 catch (e) {
      // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');
  }
}

late final jsonResponse;

late List<Plan> plans;

Future<List<Plan>> _getPlanApi(BuildContext context) async {
  // Show ProgressDialog

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
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      return data.map((planJson) => Plan.fromJson(planJson)).toList();
    } else {
      CustomAlertDialog.attractivepopup(
          context, 'Error message here: ${response.statusCode}');
    }
  } catch (e) {
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
