import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/rewards.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/Api.dart';
import 'api/config.dart';
import 'Custom_navbar/customDialog.dart';

class MyPlan extends StatefulWidget {
  @override
  MyPlanState createState() => MyPlanState();
}

class MyPlanState extends State<MyPlan> {
  late Future<List<Plan>> futurePlans;
bool isActivePlan=false;
  @override
  void initState() {
    super.initState();
    futurePlans = _getPlanApi(context) ;
    checkActivePlan("");
  }
late String PlanId;
  String selectedPlanId='';
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
                  bool isSelected = plan.id == selectedPlanId;
                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(12.0), // Corner radius
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
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            child: Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '\$${plan.price}/${plan.planType}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color:Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...features.map((feature) => Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:  isSelected ? Colors.black : Colors.bluebutton,
                                size: 20,
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:Colors.grey.shade700 ,
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
                             checkActivePlan(plan.price);
                             PlanId= plan.id;
                                // Add your button onPressed logic here
                              },
                              child: Text('Buy Plan'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor:isSelected ? Colors.black : Colors.white,
                                backgroundColor:  isSelected ? Colors.grey.shade300 : Colors.bluebutton,
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
  Future<void> makePayment(String price) async {
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
          customerId:'cus_Q99KA3BxJP2vY7',
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
        builder: (_) => const AlertDialog(
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
        'customer': 'cus_Q99KA3BxJP2vY7',

      };
      body.addAll({
        'metadata[plan_id]': PlanId,
        'metadata[user_id]': 'd431e966-d9bd-4c29-a9ab-48d93fc5f6b9', // Example metadata
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
    final calculatedAmount = (double.parse(amount) * 100).toInt();;
    return calculatedAmount.toString();
  }



  void checkActivePlan(String price) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('access_token') ?? '';

    try {

      final response = await http.get(
        Uri.parse('${ApiProvider.baseUrl+ApiProvider.isActivePlan}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',


        },
      );

      if (response.statusCode == 200) {
        // _progressDialog!.hide();

        final jsonResponse = jsonDecode(response.body);

        // Access the value of is_verified
        isActivePlan = jsonResponse['is_active_plan'];
        selectedPlanId=jsonResponse['plan_id'];

        setState(() {
          if(isActivePlan==false){

            makePayment(price);

          }else{
            Fluttertoast.showToast(msg: "you already have an active plan !!");
          }
        });

        print("responseviewprofile:${response.body}");


        return json.decode(response.body);

      } else {     // _progressDialog!.hide();

        print(response.body);

      }
    }
    catch (e) {     // _progressDialog!.hide();

      print("exception:$e");
    }
    throw Exception('');

  }

}

  late final   jsonResponse ;
  late List<Plan> plans;


  Future<List<Plan>>  _getPlanApi(BuildContext context) async {
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











