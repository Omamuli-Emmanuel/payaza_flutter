import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'User.dart';
import 'accountNumber.dart';

class SendRequest extends StatefulWidget{

  final String connectionMode;
  final String merchantKey;
  final int checkOutAmount;
  final String Phone;
  final String firstName;
  final String lastName;
  final String email;
  final String CallbackPage;
  final String CheckoutPage;

  const SendRequest({
    Key ? key,
    required this.connectionMode,
    required this.merchantKey,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.checkOutAmount,
    required this.Phone,
    required this.CallbackPage,
    required this.CheckoutPage
  }) : super(key : key);

  @override
  sendrequest createState() => sendrequest();
}

class sendrequest extends State<SendRequest>{
  late final String connectionMode = widget.connectionMode;
  late final String firstName = widget.firstName;
  late final String lastName = widget.lastName;
  late final int amount = widget.checkOutAmount;
  late final String merchantKey = widget.merchantKey;
  late final String phone = widget.Phone;
  late final String email = widget.email;
  late final String successRoute = widget.CallbackPage;
  late final String checkoutPage = widget.CheckoutPage;

  String avatar = "";
  String vendor = "";
  String payable = "";
  String fee = "";
  String accountNumber = "";
  String bankName = "";
  String unicode = "";

  String url = "https://socket-dev.payaza.africa/checkout/payloadhandler";

  @override void initState() {
    super.initState();
    sendRequest(connectionMode,
        merchantKey, amount, phone,
        firstName, lastName, email, successRoute, checkoutPage);
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("packages/paywithpayazaflutter/assets/payaza.png"),
            SizedBox(height: 8.0, width: double.infinity),
            Text("Loading Checkout Engine", style: TextStyle(
                fontWeight: FontWeight.w500
            ),),
            const SizedBox(height: 10.0, width: double.infinity),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("packages/paywithpayazaflutter/assets/Lock.png"),
                Text("Secured by "),
                Text(
                  "Payaza",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }


  Future<String> sendRequest(String connect,
      String mkey, int amount, String phone,
      String fname, String lname, String email,
      String success, String checkout) async {

    Map jsonData = {
      "service_type": "Transaction",
      "service_payload": {
        "request_application": "Payaza",
        "request_class": "UseCheckoutRequest",
        "application_module": "USER_MODULE",
        "application_version": "1.0.0",
        "request_channel": "CUSTOMER_PORTAL",
        "connection_mode": connect, // Live, Test
        "currency_code": "NGN",
        "merchant_key": mkey,
        "checkout_amount": amount,
        "email_address": email,
        "first_name": fname,
        "last_name": lname,
        "phone_number": phone,
        "transaction_reference": "your_reference",
        "device_id": "d520c7a8-421b-4563-b955-f5abc56b97ec",
        "device_name": "Chrome 103",
        "device_os": "Windows 10",
        "request_channel_type": "API_CLIENT"
      }
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonData)));
    HttpClientResponse response = await request.close();

    // todo - you should check the response.statusCode
    String reply = await response.transform(utf8.decoder).join();

    print(reply.toString());

    httpClient.close();
    Map <String, dynamic> map = json.decode(reply.toString());

    if(map["response_code"] != 200){
      var snackBar = SnackBar(content: Text(map["response_message"].toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    }

    Map <String, dynamic> data = map["response_content"];
    Map <String, dynamic> customer = map["response_content"]["customer"];
    Map <String, dynamic> business = map["response_content"]["business"];

    String transactioRef = data["transaction_reference"];

    //send user info to custom user class
    UserData user = UserData();
    user.setLastName = customer["last_name"];
    user.setFirstName = customer["first_name"];
    user.setEmail = customer["email_address"];

    email = user.getEmail;
    avatar = business["avatar"];
    vendor = business["name"];

    // print(user.getEmail);
    // print(user.getFirstName);
    // print(user.getLastName);

    //second request body
    Map account = {
      "service_type": "Account",
      "service_payload": {
        "request_application": "Payaza",
        "request_class": "FetchDynamicVirtualAccountRequest",
        "application_module": "USER_MODULE",
        "application_version": "1.0.0",
        "request_channel": "CUSTOMER_PORTAL",
        "connection_mode": connect,
        "transaction_reference": "${transactioRef.toString()}",
        "device_id": "d520c7a8-421b-4563-b955-f5abc56b97ec",
        "device_name": "Chrome 103",
        "device_os": "Windows 10",
        "request_channel_type": "API_CLIENT"
      }
    };
    //invoke account number method
    getAccountDetails(transactioRef.toString(),
        account, connect, email, success, checkout);
    // print(data["transaction_reference"]);
    // print(customer["email_address"]);
    return reply;
  }

  Future<String> getAccountDetails(String ref, Map jsonMapTwo,
      String connection, String mail, String successRRoute, String CheckkOut) async{

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMapTwo)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    String resp = await response.transform(utf8.decoder).join();


    httpClient.close();

    Map <String, dynamic> map = json.decode(resp);
    Map <String, dynamic> accInfo = map["response_content"];
    Map <String, dynamic> currency = map["response_content"]["currency"];

    payable = accInfo["transaction_payable_amount"];
    fee = accInfo["transaction_fee_amount"];
    accountNumber = accInfo["account_number"];
    bankName = accInfo["bank_name"];
    unicode = currency["unicode"];



    Navigator.push(context, MaterialPageRoute(builder: (context) => AccountNumber(
      firstName: firstName,
      lastName: lastName, email: email,
      vendor: vendor, avatar: avatar,
      payable: payable, fee: fee,
      bankName: bankName, account: accountNumber,
      connectionMode: connectionMode, unicode: unicode,
      transactionRef: ref,
      SuccessRoute: successRRoute,
      Checkout: checkoutPage,
    )));

    return resp;
  }

}
