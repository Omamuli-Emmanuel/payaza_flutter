import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'User.dart';

class AccountNumber extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;
  final String vendor;
  final String payable;
  final String fee;
  final String account;
  final String bankName;
  final String unicode;
  final String connectionMode;
  final String transactionRef;
  final String SuccessRoute;
  final String Checkout;

  const AccountNumber({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.vendor,
    required this.avatar,
    required this.payable,
    required this.fee,
    required this.bankName,
    required this.account,
    required this.connectionMode,
    required this.unicode,
    required this.transactionRef,
    required this.SuccessRoute,
    required this.Checkout
  }) : super(key: key);

  @override
  accountNumber createState() => accountNumber();

}

class accountNumber extends State<AccountNumber> {
  late IO.Socket sockect;

  //boolean state for i have sent the money
  bool sent = true;
  bool respose = false;

  String payable = "";
  String fee = "";
  String acc = "";
  String bankName = "";
  late final String connection = widget.connectionMode;

  //final uri = Uri.http('https://socket-dev.payaza.africa', '/checkout/payloadhandler');
  String url = "https://socket-dev.payaza.africa/checkout/payloadhandler";

  Timer? countdownTimer;
  Duration myDuration = Duration(minutes: 30);
  late Map response;
  late String status = "";

  @override
  void initState() {
    super.initState();
    startTimer();
    initSocket();
  }
  int _value = 0;
  String transaction = "";
  String finalResponse = "";

  @override
  Widget build(BuildContext context) {
    UserData user = UserData();
    user.transactionReff = widget.transactionRef;

    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    // Step 7
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    Map TestResponse = {"reference":"${this.widget.transactionRef}",
      "status":"completed",
      "message":"",
      "time":"${DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) }"};

    String TestFailed = "Oops, it seems your payment didnt go through, please try again..";

    String? _selected;
    var Methods = [
      {"id": '1', "image": "packages/paywithpayazaflutter/assets/Transfer.png", "name": "Pay with Transfer"},
      {"id": '2', "image": "packages/paywithpayazaflutter/assets/Bank.png", "name": "Pay with Bank"},
      {"id": '3', "image": "packages/paywithpayazaflutter/assets/credit-card.png", "name": "Pay with Card"}
    ];

    return Scaffold(
        // appBar: AppBar(
        //   title: Text("Now paying with payaza"),
        // ),
        body: connection == "Test" ?
        Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0, width: double.infinity),
              Row(
                children: [
              Container(
              child: GestureDetector(
              onTap: (){
                     _showMyDialog();
                      },
                    child: Image.asset("packages/paywithpayazaflutter/assets/close.png"),
                  ),
                ),
                  SizedBox(width: 80.0),
                  Expanded(
                    child: DropdownButton(
                      // Initial Value
                      value: 1.toString(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selected = newValue;
                        });
                        print(_selected);
                      },
                      // Down Arrow Icon
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      // Array list of items
                      items: Methods.map((Map map) {
                        return DropdownMenuItem(
                          value: map["id"].toString(),
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                map["image"],
                                width: 25,
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(map["name"])),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.0, width: double.infinity),
                Row(
                children: [
                  //first colum on the row
                  Expanded(
                      child: Row(
                        children: [
                          widget.avatar.isEmpty ?
                          Image.asset("packages/paywithpayazaflutter/assets/payaza.png", width: 30.0, height: 30.0,)
                              :
                          Image.network(
                            widget.avatar,
                            width: 30.0,
                            height: 30.0,
                          ),
                          SizedBox(width: 6.0),
                          Column(
                            children: [
                              Text(
                                "You're paying",
                                style: TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${widget.vendor}",
                                style: TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      )
                  ),
                  Expanded(
                    flex: 1,
                      child: Column(
                        children: [
                          Text(
                            "Billed To : ${widget.firstName + " " + widget.lastName}",
                            style:
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            widget.email, textAlign: TextAlign.start,
                            style:
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
                          )
                        ],
                      ))
                ],
              ),
              Container(
                height: 2.0,
                width: double.infinity,
                color: Colors.deepOrange,
              ),
              SizedBox(
                width: 80,
                child: Container(
                  color: Colors.deepOrange,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(3.0),
                  child: Text("${connection.toString()} Mode", style: TextStyle(
                      color: Colors.white
                  ),),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 10.0,
              ),
              transaction == "success" ?
                  showSuccess()
              : transaction == "failed" ?
                  showFailed()
              :
              respose ?
              Column(
                children: [
                  SizedBox(height: 60.0, width: double.infinity),
                  Text("Select a response", style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700
                  )),
                  SizedBox(height: 15.0, width: double.infinity),
                  Text("This is the response you would recieve when you click on the continue button",
                      textAlign: TextAlign.center),
                  SizedBox(height: 20.0, width: double.infinity),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child:
                    Row(
                      children: [
                        Radio(
                            value : 1,
                            groupValue: _value,
                            onChanged: (value){
                              setState(() {
                                _value = value!;
                                transaction = "success";
                              });
                            }
                        ),
                        SizedBox(width: 30),
                        Column(
                          children: [
                            Text("Success Transaction", textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18
                                )),
                            Text("Your transaction will appear successful", textAlign: TextAlign.center,)
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color : Colors.deepPurple
                        )
                    ),
                  ),
                  SizedBox(height: 15, width : double.infinity),
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Radio(
                            value : 2,
                            groupValue: _value,
                            onChanged: (value){
                              setState(() {
                                _value = value!;
                                transaction = "failed";
                              });
                            }
                        ),
                        SizedBox(width: 30),
                        Column(
                          children: [
                            Text("Failed Transaction",style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18
                            )),
                            Text("Your transaction will appear as failed")
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color : Colors.deepPurple
                        )
                    ),
                  ),
                  SizedBox(height: 15)
                ],
              )
                  :
              noDataFromSocketYet(hours, minutes, seconds),
              SizedBox(
                height: 5.0,
                width: double.infinity,
              ),
              transaction == "" ?
              respose ?
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue[900],
                          minimumSize: Size(double.infinity, 45.0)),
                      onPressed: (){
                        _value == 1 ?
                        transaction == "success"
                            :
                        transaction == "failed";
                      },
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ))
                      :
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          minimumSize: Size(double.infinity, 45.0)),
                      onPressed: (){
                        respose = true;
                      },
                      child: Text(
                        "Simulate transaction response",
                        style: TextStyle(
                            color: Colors.blueAccent, fontWeight: FontWeight.w300),
                      ))
                :
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue[900],
                      minimumSize: Size(double.infinity, 45.0)),
                  onPressed: (){
                    if(transaction == "success"){
                      Navigator.of(context)
                      .pushReplacementNamed(widget.SuccessRoute, arguments: TestResponse.toString());
                    }else if(transaction == "failed"){
                      Navigator.of(context)
                          .pushReplacementNamed(widget.SuccessRoute, arguments: TestFailed.toString());
                    }
                  },
                  child: Text(
                    "Return to merchant",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  )),
              SizedBox(
                height: 10,
                width: double.infinity,
              ),
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
        )
            :
              Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0, width: double.infinity),
              Row(
                children: [
              Container(
              child: GestureDetector(
              onTap: (){
              _showMyDialog();
              },
                child: Image.asset("packages/paywithpayazaflutter/assets/close.png"),
              ),
    ),
                  SizedBox(width: 80.0),
                  Expanded(
                    child: DropdownButton(
                      // Initial Value
                      value: 1.toString(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selected = newValue;
                        });
                        print(_selected);
                      },
                      // Down Arrow Icon
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      // Array list of items
                      items: Methods.map((Map map) {
                        return DropdownMenuItem(
                          value: map["id"].toString(),
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                map["image"],
                                width: 25,
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(map["name"])),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.0, width: double.infinity),
              Row(
                children: [
                  //first colum on the row
                  Expanded(
                      child: Row(
                        children: [
                          widget.avatar.isEmpty ?
                          Image.asset("packages/paywithpayazaflutter/assets/payaza.png", width: 30.0, height: 30.0,)
                              :
                          Image.network(
                            widget.avatar,
                            width: 30.0,
                            height: 30.0,
                          ),
                          SizedBox(width: 6.0),
                          Column(
                            children: [
                              Text(
                                "You're paying",
                                style: TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${widget.vendor}",
                                style: TextStyle(
                                    fontSize: 12.0, fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      )),
                  Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Billed To : ${widget.firstName + " " + widget.lastName}",
                            style:
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            widget.email, textAlign: TextAlign.start,
                            style:
                            TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400),
                          )
                        ],
                      ))
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 10.0,
              ),
              status == "completed"
                  ? showSuccess()
                  : noDataFromSocketYet(hours, minutes, seconds),
              SizedBox(
                height: 5.0,
                width: double.infinity,
              ),
              status == "completed" ?
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: Size(double.infinity, 45.0)),
                  onPressed: (){
                    Navigator.of(context)
                        .pushReplacementNamed(widget.SuccessRoute, arguments: finalResponse.toString());
                  },
                  child: Text(
                    "Return to merchant",
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.w300),
                  ))
                  :
              sent
                  ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: Size(double.infinity, 45.0)),
                  onPressed: () async {
                    sent ? sent = false : sent = true;
                  },
                  child: Text(
                    "I've sent the money",
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.w300),
                  ))
                  : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: Size(double.infinity, 45.0)),
                  onPressed: () async {
                    sent ? sent = false : sent = true;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "packages/paywithpayazaflutter/assets/reload.png",
                        height: 50,
                        width: 50,
                      ),
                      Text(
                        "See Account Details",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w300),
                      )
                    ],
                  )),
              SizedBox(
                height: 10,
                width: double.infinity,
              ),
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
        )
    );
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
    resetTimer();
  }

  void resetTimer() {
    setState(() => myDuration = Duration(minutes: 30));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        stopTimer();
        //show snakbar
        var snackBar = SnackBar(content: Text("Generating new virtual account number"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        getAccountDetails(this.widget.transactionRef, connection);
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  Future<String> getAccountDetails(String ref, String connect) async {

    //second request body
    final Map account = {
      "service_type": "Account",
      "service_payload": {
        "request_application": "Payaza",
        "request_class": "FetchDynamicVirtualAccountRequest",
        "application_module": "USER_MODULE",
        "application_version": "1.0.0",
        "request_channel": "CUSTOMER_PORTAL",
        "connection_mode": connect,
        "transaction_reference": "$ref",
        "device_id": "d520c7a8-421b-4563-b955-f5abc56b97ec",
        "device_name": "Chrome 103",
        "device_os": "Windows 10",
        "request_channel_type": "API_CLIENT"
      }
    };

    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(account)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    String resp = await response.transform(utf8.decoder).join();
    httpClient.close();

    Map<String, dynamic> map = json.decode(resp);
    Map<String, dynamic> accInfo = map["response_content"];
    Map<String, dynamic> currency = map["response_content"]["currency"];

    payable = accInfo["transaction_payable_amount"];
    fee = accInfo["transaction_fee_amount"];
    acc = accInfo["account_number"];
    bankName = accInfo["bank_name"];

    startTimer();
    return resp;
  }

  Widget showSuccess() {
    return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(25.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Center(
            child: Column(children: [
              SizedBox(height: 150, width: double.infinity),
              Image.asset(
                "packages/paywithpayazaflutter/assets/success.png",
                height: 100,
                width: 100,
              ),
              Text(
                "Payment Successful",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 25,
                    color: Color(0xff398352)),
              ),
              Text(
                "This transaction has been processed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              Text(
                "Your reference number is ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              Text(
                "${widget.transactionRef}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ));
  }

  Widget showFailed(){
    return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(25.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Center(
            child: Column(children: [
              SizedBox(height: 150, width: double.infinity),
              Image.asset(
                "packages/paywithpayazaflutter/assets/failed.jpeg",
                height: 100,
                width: 100,
              ),
              SizedBox(height: 10, width: double.infinity),
              Text(
                "Payment Failed",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 25,
                    color: Colors.red),
              ),
              SizedBox(height: 10, width: double.infinity),
              Text(
                "We are sorry we could not process this transaction at the moment",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ]),
          ),
        ));
  }

  Widget noDataFromSocketYet(String Hours, String Minutes, String Seconds) {
    return Container(
        child: sent
            ? Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF1FDFF)),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 100, width: double.infinity),
                        Text("( FEES : ${widget.unicode + "" + widget.fee} )"),
                        SizedBox(
                          height: 7.0,
                          width: double.infinity,
                        ),
                        Text(
                          "TRANSFER ${widget.unicode + "" + widget.payable}",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 50.0,
                          width: double.infinity,
                        ),
                        acc.isEmpty
                            ? Row(
                                children: [
                                  Text(
                                    widget.account,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 45.0),
                                    textAlign: TextAlign.right,
                                  ),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FlutterClipboard.copy(
                                                widget.account.toString())
                                            .then((value) {
                                          return ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Account number copied successfully")));
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFF1FDFF),
                                          elevation: 0,
                                          minimumSize: Size(50, 50)),
                                      child: Image.asset("packages/paywithpayazaflutter/assets/copy.png"))
                                ],
                              )
                            : Row(
                                children: [
                                  Text(acc,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 45.0)),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FlutterClipboard.copy(acc.toString())
                                            .then((value) {
                                          return ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Account number copied successfully")));
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFF1FDFF),
                                          elevation: 0,
                                          minimumSize: Size(50, 50)),
                                      child: Image.asset("packages/paywithpayazaflutter/assets/copy.png"))
                                ],
                              ),
                        Text(
                          widget.bankName,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xff676E7E),
                              fontSize: 14.0),
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                        ),
                        Container(
                          height: 2,
                          width: 280,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("This account is going to expire in "),
                            Text(
                              "$Hours:$Minutes:$Seconds",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                        Text(
                          "Make your payment before it expires.",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ))
            : Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Center(
                    child: Column(children: [
                      SizedBox(height: 150, width: double.infinity),
                      Image.asset(
                        "packages/paywithpayazaflutter/assets/watch.png",
                        height: 100,
                        width: 100,
                      ),
                      Text(
                        "Awaiting Confirmation",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 25,
                            color: Color(0xFF0E2354)),
                      ),
                      Text(
                        "Please wait a couple minutes, while we create an account for this transaction",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      )
                    ]),
                  ),
                )));
  }

  Future<void> initSocket() async {
    try {
      sockect = IO.io(
          "https://socket-dev.payaza.africa/${this.widget.transactionRef}",
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': true,
          });
      sockect.on("message", (data) {
        data == null ? print("No data") : print(data);
        response = data;


        if(response.containsKey("status")){
          status = response["status"];
          finalResponse = response.toString();
        }else{
          status = "no status yet";
          finalResponse = "Transaction failed";
        }

        // response["status"] != null
        //     ? status = response["status"]
        //     : status = "No status yet";
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Transaction'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to cancel this transaction?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('YES, CANCEL'),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(widget.Checkout);
                    },
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
