import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/PaymentRadio.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Helper/Stripe_Service.dart';
import '../Model/Model.dart';
import 'Cart.dart';

class Payment extends StatefulWidget {
  final Function update;
  final String? msg;

  Payment(this.update, this.msg);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

List<Model> timeSlotList = [];
String? allowDay;
bool codAllowed = true;
String? bankName, bankNo, acName, acNo, exDetails;

class StatePayment extends State<Payment> with TickerProviderStateMixin {

  bool _isLoading = true;
  String? startingDate;

  late bool cod,
      paypal,
      razorpay,
      paumoney,
      paystack,
      flutterwave,
      stripe,
      paytm = true,
      gpay = false,
      bankTransfer = true;
  List<RadioModel> timeModel = [];
  List<RadioModel> payModel = [];
  List<RadioModel> timeModelList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<String?> paymentMethodList = [];
  List<String> paymentIconList = [
    Platform.isIOS ? 'assets/images/applepay.svg' : 'assets/images/gpay.svg',
    'assets/images/cod.svg',
    'assets/images/paypal.svg',
    'assets/images/payu.svg',
    'assets/images/rozerpay.svg',
    'assets/images/paystack.svg',
    'assets/images/flutterwave.svg',
    'assets/images/stripe.svg',
    'assets/images/paytm.svg',
    'assets/images/banktransfer.svg',
  ];

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final plugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
    _getdateTime();
    timeSlotList.length = 0;

    new Future.delayed(Duration.zero, () {
      paymentMethodList = [
        Platform.isIOS
            ? getTranslated(context, 'APPLEPAY')
            : getTranslated(context, 'GPAY'),
        getTranslated(context, 'COD_LBL'),
        getTranslated(context, 'PAYPAL_LBL'),
        getTranslated(context, 'PAYUMONEY_LBL'),
        getTranslated(context, 'RAZORPAY_LBL'),
        getTranslated(context, 'PAYSTACK_LBL'),
        getTranslated(context, 'FLUTTERWAVE_LBL'),
        getTranslated(context, 'STRIPE_LBL'),
        getTranslated(context, 'PAYTM_LBL'),
        getTranslated(context, 'BANKTRAN'),
      ];
    });
    if (widget.msg != '')
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => setSnackbar(widget.msg!));
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  _getdateTime();
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'PAYMENT_METHOD_LBL')!,
          context), // getAppBar(getTranslated(context, 'PAYMENT_METHOD_LBL')!, context),
      body: _isNetworkAvail
          ? _isLoading
              ? getProgress()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer<UserProvider>(
                                  builder: (context, userProvider, _) {
                                return Card(
                                  elevation: 0,
                                  child: userProvider.curBalance != "0" &&
                                          userProvider.curBalance.isNotEmpty &&
                                          userProvider.curBalance != ""
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: CheckboxListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.all(0),
                                            value: isUseWallet,
                                            onChanged: (bool? value) {
                                              if (mounted)
                                                setState(() {
                                                  isUseWallet = value;
                                                  if (value!) {
                                                    if (totalPrice <=
                                                        double.parse(
                                                            userProvider
                                                                .curBalance)) {
                                                      remWalBal = (double.parse(
                                                              userProvider
                                                                  .curBalance) -
                                                          totalPrice);
                                                      usedBal = totalPrice;
                                                      payMethod = "Wallet";

                                                      isPayLayShow = false;
                                                    } else {
                                                      remWalBal = 0;
                                                      usedBal = double.parse(
                                                          userProvider
                                                              .curBalance);
                                                      isPayLayShow = true;
                                                    }

                                                    totalPrice =
                                                        totalPrice - usedBal;
                                                  } else {
                                                    totalPrice =
                                                        totalPrice + usedBal;
                                                    remWalBal = double.parse(
                                                        userProvider
                                                            .curBalance);
                                                    payMethod = null;
                                                    selectedMethod = null;
                                                    usedBal = 0;
                                                    isPayLayShow = true;
                                                  }

                                                  widget.update();
                                                });
                                            },
                                            title: Text(
                                              getTranslated(
                                                  context, 'USE_WALLET')!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                            subtitle: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                isUseWallet!
                                                    ? getTranslated(context,
                                                            'REMAIN_BAL')! +
                                                        " : " +
                                                        CUR_CURRENCY! +
                                                        " " +
                                                        remWalBal
                                                            .toStringAsFixed(2)
                                                    : getTranslated(context,
                                                            'TOTAL_BAL')! +
                                                        " : " +
                                                        CUR_CURRENCY! +
                                                        " " +
                                                        double.parse(
                                                                userProvider
                                                                    .curBalance)
                                                            .toStringAsFixed(2),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .black),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                );
                              }),
                              isTimeSlot!
                                  ? Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'PREFERED_TIME')!,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Divider(),
                                          Container(
                                            height: 90,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: int.parse(allowDay!),
                                                itemBuilder: (context, index) {
                                                  return dateCell(index);
                                                }),
                                          ),
                                          Divider(),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount: timeModel.length,
                                              itemBuilder: (context, index) {
                                                return timeSlotItem(index);
                                              })
                                        ],
                                      ),
                                    )
                                  : Container(),
                              isPayLayShow!
                                  ? Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'SELECT_PAYMENT')!,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Divider(),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  paymentMethodList.length,
                                              itemBuilder: (context, index) {
                                                if (index == 1 && cod)
                                                  return paymentItem(index);
                                                else if (index == 2 && paypal)
                                                  return paymentItem(index);
                                                else if (index == 3 && paumoney)
                                                  return paymentItem(index);
                                                else if (index == 4 && razorpay)
                                                  return paymentItem(index);
                                                else if (index == 5 && paystack)
                                                  return paymentItem(index);
                                                else if (index == 6 &&
                                                    flutterwave)
                                                  return paymentItem(index);
                                                else if (index == 7 && stripe)
                                                  return paymentItem(index);
                                                else if (index == 8 && paytm)
                                                  return paymentItem(index);
                                                else if (index == 0 && gpay)
                                                  return paymentItem(index);
                                                else if (index == 9 &&
                                                    bankTransfer)
                                                  return paymentItem(index);
                                                else
                                                  return Container();
                                              }),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                      SimBtn(
                        size: 0.8,
                        title: getTranslated(context, 'DONE'),
                        onBtnSelected: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                )
          : noInternet(context),
    );
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  dateCell(int index) {
    DateTime today = DateTime.parse(startingDate!);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selectedDate == index ? colors.primary : null),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(today.add(Duration(days: index))),
              style: TextStyle(
                  color: selectedDate == index
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightBlack2),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(today.add(Duration(days: index))),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedDate == index
                        ? Theme.of(context).colorScheme.white
                        : Theme.of(context).colorScheme.lightBlack2),
              ),
            ),
            Text(
              DateFormat('MMM').format(today.add(Duration(days: index))),
              style: TextStyle(
                  color: selectedDate == index
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightBlack2),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        if (mounted) selectedDate = index;
        selectedTime = null;
        selTime = null;
        selDate = DateFormat('yyyy-MM-dd').format(date);
        timeModel.clear();
        DateTime cur = DateTime.now();
        DateTime tdDate = DateTime(cur.year, cur.month, cur.day);
        if (date == tdDate) {
          if (timeSlotList.length > 0) {
            for (int i = 0; i < timeSlotList.length; i++) {
              DateTime cur = DateTime.now();
              String time = timeSlotList[i].lastTime!;
              DateTime last = DateTime(
                  cur.year,
                  cur.month,
                  cur.day,
                  int.parse(time.split(':')[0]),
                  int.parse(time.split(':')[1]),
                  int.parse(time.split(':')[2]));

              if (cur.isBefore(last)) {
                timeModel.add(new RadioModel(
                    isSelected: i == selectedTime ? true : false,
                    name: timeSlotList[i].name,
                    img: ''));
              }
            }
          }
        } else {
          if (timeSlotList.length > 0) {
            for (int i = 0; i < timeSlotList.length; i++) {
              timeModel.add(new RadioModel(
                  isSelected: i == selectedTime ? true : false,
                  name: timeSlotList[i].name,
                  img: ''));
            }
          }
        }
        setState(() {});
      },
    );
  }

  Future<void> _getdateTime() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      timeSlotList.clear();
      try {
        var parameter = {TYPE: PAYMENT_METHOD, USER_ID: CUR_USERID};
        Response response =
            await post(getSettingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));
         print("Api Working ${getSettingApi.toString()}");
         print(parameter.toString());

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            var time_slot = data["time_slot_config"];
            allowDay = time_slot["allowed_days"];
            isTimeSlot =
                time_slot["is_time_slots_enabled"] == "1" ? true : false;
            startingDate = time_slot["starting_date"];
            codAllowed = data["is_cod_allowed"] == 1 ? true : false;

            var timeSlots = data["time_slots"];
            timeSlotList = (timeSlots as List)
                .map((timeSlots) => new Model.fromTimeSlot(timeSlots))
                .toList();

            if (timeSlotList.length > 0) {
              for (int i = 0; i < timeSlotList.length; i++) {
                if (selectedDate != null) {
                  DateTime today = DateTime.parse(startingDate!);

                  DateTime date = today.add(Duration(days: selectedDate!));

                  DateTime cur = DateTime.now();
                  DateTime tdDate = DateTime(cur.year, cur.month, cur.day);

                  if (date == tdDate) {
                    DateTime cur = DateTime.now();
                    String time = timeSlotList[i].lastTime!;
                    DateTime last = DateTime(
                        cur.year,
                        cur.month,
                        cur.day,
                        int.parse(time.split(':')[0]),
                        int.parse(time.split(':')[1]),
                        int.parse(time.split(':')[2]));

                    if (cur.isBefore(last)) {
                      timeModel.add(new RadioModel(
                          isSelected: i == selectedTime ? true : false,
                          name: timeSlotList[i].name,
                          img: ''));
                    }
                  } else {
                    timeModel.add(new RadioModel(
                        isSelected: i == selectedTime ? true : false,
                        name: timeSlotList[i].name,
                        img: ''));
                  }
                } else {
                  timeModel.add(new RadioModel(
                      isSelected: i == selectedTime ? true : false,
                      name: timeSlotList[i].name,
                      img: ''));
                }
              }
            }

            var payment = data["payment_method"];

            cod = codAllowed
                ? payment["cod_method"] == "1"
                    ? true
                    : false
                : false;
            paypal = payment["paypal_payment_method"] == "1" ? true : false;
            paumoney =
                payment["payumoney_payment_method"] == "1" ? true : false;
            flutterwave =
                payment["flutterwave_payment_method"] == "1" ? true : false;
            razorpay = payment["razorpay_payment_method"] == "1" ? true : false;
            paystack = payment["paystack_payment_method"] == "1" ? true : false;
            stripe = payment["stripe_payment_method"] == "1" ? true : false;
            paytm = payment["paytm_payment_method"] == "1" ? true : false;
            bankTransfer =
                payment["direct_bank_transfer"] == "1" ? true : false;

            if (razorpay) razorpayId = payment["razorpay_key_id"];
            if (paystack) {
              paystackId = payment["paystack_key_id"];

              plugin.initialize(publicKey: paystackId!);
            }
            if (stripe) {
              stripeId = payment['stripe_publishable_key'];
              stripeSecret = payment['stripe_secret_key'];
              stripeCurCode = payment['stripe_currency_code'];
              stripeMode = payment['stripe_mode'] ?? 'test';
              StripeService.secret = stripeSecret;
              // StripeService.init(stripeId, stripeMode);
            }
            if (paytm) {
              paytmMerId = payment['paytm_merchant_id'];
              paytmMerKey = payment['paytm_merchant_key'];
              payTesting =
                  payment['paytm_payment_mode'] == 'sandbox' ? true : false;
            }

            if (bankTransfer) {
              bankName = payment['bank_name'];
              bankNo = payment['bank_code'];
              acName = payment['account_name'];
              acNo = payment['account_number'];
              exDetails = payment['notes'];
            }

            for (int i = 0; i < paymentMethodList.length; i++) {
              payModel.add(RadioModel(
                  isSelected: i == selectedMethod ? true : false,
                  name: paymentMethodList[i],
                  img: paymentIconList[i]));
            }
          } else {
            // setSnackbar(msg);
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        //setSnackbar( getTranslated(context,'somethingMSg'));
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Widget timeSlotItem(int index) {
    return new InkWell(
      onTap: () {
        if (mounted)
          setState(() {
            selectedTime = index;
            selTime = timeModel[selectedTime!].name;
            //timeSlotList[selectedTime].name;
            timeModel.forEach((element) => element.isSelected = false);
            timeModel[index].isSelected = true;
          });
      },
      child: new RadioItem(timeModel[index]),
    );
  }

  Widget paymentItem(int index) {
    return new InkWell(
      onTap: () {
        if (mounted)
          setState(() {
            selectedMethod = index;
            payMethod = paymentMethodList[selectedMethod!];

            payModel.forEach((element) => element.isSelected = false);
            payModel[index].isSelected = true;
          });
      },
      child: new RadioItem(payModel[index]),
    );
  }
}
