import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:project_new/ReportPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Counter.dart';
import 'myPlanPage.dart';

class ViewPlan extends StatefulWidget {
  @override
  ViewPlanM createState() => ViewPlanM();
}

class ViewPlanM extends State<ViewPlan> {
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    CounterApi();
    getStripeKey();
    checkPlanValidity();

  }

  List<Counter> counters = [];

  Future<void> CounterApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/subscription-plans/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('counter ${response.body}');
        //counters = json.decode(response.body);
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Convert the dynamic list to a List<Counter> using the Counter.fromJson factory method
        counters = jsonResponse.map((item) => Counter.fromJson(item)).toList();
        print("gettitle$counters");
        setState(() {
          counters;
        });

// If the call to the server was successful, parse the JSON
      } else {
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
  String plan_price = '';
  int selectedSubscriptionIndex = -1; // Initialize with -1 for no selection

  @override
  Widget build(BuildContext context) {
    return   WillPopScope(
        onWillPop: () async {

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyPlan()),
            // (route) => route.isFirst, // Remove until the first route (Screen 1)
          );
          return false;
        },child:Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/productsc.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 220.0),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: counters.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Radio(
                              value: index,
                              groupValue: selectedSubscriptionIndex,
                              onChanged: (int? value) {
                                setState(() {
                                  selectedSubscriptionIndex = value!;
                                  subscriptionId = counters[index].id;
                                  plan_price =
                                      calculateAmount(counters[index].price.toString());
                                  // plan_price=counters[index].price;

                                });
                              },
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(counters[index].title),
                                subtitle: Text(counters[index].description),
                                onTap: () {
                                  subscriptionId = counters[index].id;
                                  String price =
                                  calculateAmount(counters[index].price.toString());
                                  print("price" + price);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlanDetailPage(
                                          planId: subscriptionId),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0), // Add some space between the list and the button
                ElevatedButton(
                  onPressed: () {
                    if (selectedSubscriptionIndex != -1) {
                      // Button action when a subscription is selected
                      print("Selected Subscription ID: $subscriptionId");
                      makePayment(plan_price);
                    } else {
                     /* CustomAlertDialog.attractivepopup(
                        context,
                        'No subscription selected',
                      );*/

                      // Handle the case when no subscription is selected
                      print("No subscription selected");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,

                    primary: Colors.indigo,
                    // Background color
                    // Text color
                    padding: EdgeInsets.all(16),
                    minimumSize: Size(300, 40),
                    // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      // Button border radius
                    ),
                  ),
                  child: Text('PROCEED'),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    )  );
  }
  late String stripePublicKey;
  late String SecretKey;
  String  CustomerId="";
  String  merchantName="";

  late String paymentIntentId;
  String subscriptionId="";
  bool recordValue=false;
  Future<void> getStripeKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/get-stripe-detail/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('strieppe ${response.body}');
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        stripePublicKey = jsonMap['stripe_public_key'];
        SecretKey = jsonMap['secret_key'];
        CustomerId=jsonMap['stripe_customer_id'];
        merchantName=jsonMap['merchant_name'];

        print('Stripe Public Key: $stripePublicKey');
        print('Secret Key: $SecretKey');
        setState(() {});

// If the call to the server was successful, parse the JSON
      } else {
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(String amount) async {

    try {

      paymentIntentData = await createPaymentIntent(amount, 'USD');
      // print(createPaymentIntent(amount, currency)) //json.decode(response.body);
      // print(c)
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret:
              paymentIntentData!['client_secret'],
              customerId:CustomerId,//'CustomerId',
              // billingDetails: billingDetails,
              //applePay: PaymentSheetApplePay.,
              //googlePay: true,
              //testEnv: true,
              // customFlow: true,
              style: ThemeMode.dark,
              // merchantCountryCode: 'US',
              merchantDisplayName: merchantName))
          .then((value) {});

      ///now finally display payment sheeet
      // Column(
      //   children: [TextFormField()],
      // );

      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
        //       parameters: PresentPaymentSheetParameters(
        // clientSecret: paymentIntentData!['client_secret'],
        // confirmPayment: true,
        // )
      )
          .then((newValue) {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        Future.delayed(Duration(seconds: 2));
        {
          checkPaymentResult();
        }

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }
  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {

        'customer': CustomerId,//"cus_PH6A1LAcfJp8jw",//CustomerId
        'description': 'Software Testing',
        'automatic_payment_methods[enabled]': "true",
        'amount': amount, //calculateAmount(amount),
        'currency': "USD",

        //'payment_method_types[]': 'card',

      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer sk_test_51OHlGxSAmKaVJFiBBSoDqR5IqFAU8gy0DNMbYXKxQNHi1WIWR5kH48Tz9wIvXHgWGzpNlly7DHt2keh7YlgJLRsV00ojdXG8oJ',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      Map<String, dynamic> responseBody = jsonDecode(response.body);
      paymentIntentId = responseBody['id'];

      return responseBody;
    } catch (err) {
      print('Error charging user: $err');
      return {}; // Handle the error as needed
    }
  }

  Future<void> checkPaymentResult() async {
    var apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/stripe-checkout-api/'; // Replace with your API endpoint
    //print("ssss$subscriptionId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';

    try {
      var requestBody = jsonEncode({
        "subscription_id": subscriptionId,
        "payment_intent_id": paymentIntentId
      });

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Request sucxsss with status: ${response.body}');
        final jsonData = json.decode(response.body);
        String status = jsonData['status'];
        if (status == 'payment success') {
          //checkusertest();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String page = prefs.getString('page') ?? '';
          if(page=="myplan"){

            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => MyPlan()),
            );

          }else{
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => ReportPage()),
            );

          }


        }
        // Handle the response data here
      }
      print('Request failed with status: ${response.statusCode}');
      print('Request failed with status: ${response.body}');
      setState(() {});

      // Handle error response
    } catch (e) {
// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }

// Implement other methods here
  Future<void> checkusertest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/checking-user-test/';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('respsss ${response.body}');
        Map<String, dynamic> responseData = jsonDecode(response.body);

        recordValue = responseData['record'] ?? false;

        print('Record value: $recordValue');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String page = prefs.getString('page') ?? '';
        if(page=="myplan"){

          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => MyPlan()),
          );

        }else{
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => ReportPage()),
          );

        }
      } else {

        print('Failed with status code: ${response.statusCode}');
        print('Failed with status code: ${response.body}');

      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }

  Future<void> checkPlanValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/checking-plan-validity/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body
    var requestBody = jsonEncode({
      "subscription_id": subscriptionId,
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        print('sddd ${response.body}');
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

// If the call to the server was successful, parse the JSON
      } else {
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
        print('Failed sddd ${response.body}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
}






class Plan {
  final String id;
  final String title;
  final String description;
  final int price;
  final String startDate;
  final String expiredDate;
  final String subscriptionPlanType;
  final int graceTime;
  final String productId;
  final String priceId;
  final String createdOn;
  final String updatedOn;
  final String createdBy;
  final String? purchaseBy;

  Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.startDate,
    required this.expiredDate,
    required this.subscriptionPlanType,
    required this.graceTime,
    required this.productId,
    required this.priceId,
    required this.createdOn,
    required this.updatedOn,
    required this.createdBy,
    this.purchaseBy,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],//toDouble(),
      startDate: json['start_date'],
      expiredDate: json['expired_date'],
      subscriptionPlanType: json['subscription_plan_type'],
      graceTime: json['grace_time'],
      productId: json['product_id'],
      priceId: json['price_id'],
      createdOn: json['created_on'],
      updatedOn: json['updated_on'],
      createdBy: json['created_by'],
      purchaseBy: json['purchase_by'],
    );
  }
}

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> getPlanDetails(String planId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
    final response =
    await http.get(Uri.parse('$baseUrl/$planId/'), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load plan details');
    }
  }
}

class PlanDetailPage extends StatefulWidget {
  final String planId;

  const PlanDetailPage({Key? key, required this.planId}) : super(key: key);

  @override
  _PlanDetailPageState createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  late Future<dynamic> futurePlan;

  @override
  void initState() {
    super.initState();
    getStripeKey();
    final apiService = ApiService(
        'https://testing1.zuktiapp.zuktiinnovations.com/subscription-plans');
    futurePlan = apiService.getPlanDetails(widget.planId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/productsc.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: FutureBuilder<dynamic>(
                  future: futurePlan,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      final plan = Plan.fromJson(snapshot.data);

                      plan_price=calculateAmount(plan.price.toString());//plan.price.toString();
                      subscriptionId=plan.id;
                      print("price$plan_price subscription$subscriptionId");
                      return Container(
                        height: 300,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${plan.title}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Description: ${plan.description}'),
                            SizedBox(height: 8),
                            Text('Subscription Type: ${plan.subscriptionPlanType}'),
                            SizedBox(height: 8),
                            Text('Grace Time: ${plan.graceTime}'),
                            SizedBox(height: 8),
                            Text('Start Time: ${plan.startDate}'),
                            SizedBox(height: 8),
                            Text('expired Time: ${plan.expiredDate}'),
                            SizedBox(height: 8),
                            Text('price: \$${plan.price}'),
                            SizedBox(height: 8),
// Other details Text widgets
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              width: 250,
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  makePayment(plan_price);
                },
                child: Text('Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /**
      @override
      Widget build(BuildContext context) {
      return Scaffold(
      body: Stack(
      children: [
      Container(
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage('assets/productsc.png'),
      fit: BoxFit.cover,
      ),
      ),
      ),
      Center(
      child:  FutureBuilder<dynamic>(
      future: futurePlan,
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
      child: CircularProgressIndicator(),
      );
      } else if (snapshot.hasError) {
      return Center(
      child: Text('Error: ${snapshot.error}'),
      );
      } else {
      final plan = Plan.fromJson(snapshot.data);
      plan_price=calculateAmount(plan.price.toString());

      subscriptionId=plan.id;
      print("price$plan_price subscription$subscriptionId");
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Container(
      padding: EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
      BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 4,
      offset: Offset(0, 2),
      ),
      ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text(
      'Name: ${plan.title}',
      style: TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text('Description: ${plan.description}'),
      SizedBox(height: 8),
      Text('Subscription Type: ${plan.subscriptionPlanType}'),
      SizedBox(height: 8),
      Text('Grace Time: ${plan.graceTime}'),
      SizedBox(height: 8),
      Text('Start Time: ${plan.startDate}'),
      SizedBox(height: 8),
      Text('expired Time: ${plan.expiredDate}'),
      SizedBox(height: 8),
      Text('price: \$${plan.price}'),
      SizedBox(height: 8),
      // Other details Text widgets
      ],
      ),
      ),
      Expanded(child: SizedBox()),
      // Add space to push the button to the bottom
      SizedBox(height: 30),
      Center(
      child:ElevatedButton(
      onPressed: () {

      makePayment(plan_price);


      // Handle the case when no subscription is selected

      },
      style: ElevatedButton.styleFrom(
      onPrimary: Colors.white,

      primary: Colors.indigo,
      // Background color
      // Text color
      padding: EdgeInsets.all(16),
      minimumSize: Size(300, 40),
      // Button padding
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      // Button border radius
      ),
      ),
      child: Text('PROCEED'),
      ),
      // Center the button along the horizontal axis

      ),
      ],

      );
      }
      },
      ),
      ),],
      ),
      );
      }**/
  String plan_price = '';

  Future<void> makePayment(String amount) async {

    try {

      paymentIntentData = await createPaymentIntent(amount, 'USD');
      print(amount.toString()); //json.decode(response.body);
      // print(c)
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret:
              paymentIntentData!['client_secret'],
              customerId:CustomerId,//'CustomerId',
              // billingDetails: billingDetails,
              //applePay: PaymentSheetApplePay.,
              //googlePay: true,
              //testEnv: true,
              // customFlow: true,
              style: ThemeMode.dark,
              // merchantCountryCode: 'US',
              merchantDisplayName: merchantName))
          .then((value) {});

      ///now finally display payment sheeet
      // Column(
      //   children: [TextFormField()],
      // );

      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }
  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
        //       parameters: PresentPaymentSheetParameters(
        // clientSecret: paymentIntentData!['client_secret'],
        // confirmPayment: true,
        // )
      )
          .then((newValue) {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        Future.delayed(Duration(seconds: 2));
        {
          checkPaymentResult();
        }

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }
  Future<void> checkPaymentResult() async {
    var apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/stripe-checkout-api/'; // Replace with your API endpoint
    //print("ssss$subscriptionId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';

    try {
      var requestBody = jsonEncode({
        "subscription_id": subscriptionId,
        "payment_intent_id": paymentIntentId
      });

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Request sucxsss with status: ${response.body}');
        final jsonData = json.decode(response.body);
        String status = jsonData['status'];
        if (status == 'payment success') {
          //checkusertest();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String page = prefs.getString('page') ?? '';
          if(page=="myplan"){

            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => MyPlan()),
            );

          }else{
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => ReportPage()),
            );

          }


        }
        // Handle the response data here
      }
      print('Request failed with status: ${response.statusCode}');
      print('Request failed with status: ${response.body}');
      setState(() {});

      // Handle error response
    } catch (e) {
// If the server returns an error response, throw an exception
      throw Exception('Failed to send data');
    }
  }late String stripePublicKey;
  late String SecretKey;
  String  CustomerId="";
  String  merchantName="";

  late String paymentIntentId;
  String subscriptionId="";
  bool recordValue=false;
  Future<void> getStripeKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access_token = prefs.getString('access') ?? '';
    final String apiUrl =
        'https://testing1.zuktiapp.zuktiinnovations.com/get-stripe-detail/';
// Replace these headers with your required headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access_token',
    };
// Replace this with your PUT request body

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
//body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('strieppe ${response.body}');
        Map<String, dynamic> jsonMap = jsonDecode(response.body);

        stripePublicKey = jsonMap['stripe_public_key'];
        SecretKey = jsonMap['secret_key'];
        CustomerId=jsonMap['stripe_customer_id'];
        merchantName=jsonMap['merchant_name'];

        print('Stripe Public Key: $stripePublicKey');
        print('Secret Key: $SecretKey');
        setState(() {});

// If the call to the server was successful, parse the JSON
      } else {
// If the server did not return a 200 OK response,
// handle the error here (display error message or take appropriate action)
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
// Handle exceptions here (e.g., network errors)
      print('Exception: $e');
    }
  }
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
  Map<String, dynamic>? paymentIntentData;
  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {

        'customer': CustomerId,//"cus_PH6A1LAcfJp8jw",//CustomerId
        'description': 'Software Testing',
        'automatic_payment_methods[enabled]': "true",
        'amount': amount, //calculateAmount(amount),
        'currency': "USD",

        //'payment_method_types[]': 'card',

      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer sk_test_51OHlGxSAmKaVJFiBBSoDqR5IqFAU8gy0DNMbYXKxQNHi1WIWR5kH48Tz9wIvXHgWGzpNlly7DHt2keh7YlgJLRsV00ojdXG8oJ',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      Map<String, dynamic> responseBody = jsonDecode(response.body);
      paymentIntentId = responseBody['id'];

      return responseBody;
    } catch (err) {
      print('Error charging user: $err');
      return {}; // Handle the error as needed
    }
  }

}