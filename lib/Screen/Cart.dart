//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:eshop_multivendor/Helper/Constant.dart';
// import 'package:eshop_multivendor/Helper/Public%20Api/api.dart';
// import 'package:eshop_multivendor/Helper/Session.dart';
// import 'package:eshop_multivendor/Helper/widgets.dart';
// import 'package:eshop_multivendor/Provider/CartProvider.dart';
// import 'package:eshop_multivendor/Provider/SettingProvider.dart';
// import 'package:eshop_multivendor/Provider/UserProvider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart';
// import 'package:paytm/paytm.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../Helper/AppBtn.dart';
// import '../Helper/Color.dart';
// import '../Helper/SimBtn.dart';
// import '../Helper/String.dart';
// import '../Helper/Stripe_Service.dart';
// import '../Model/Model.dart';
// import '../Model/Section_Model.dart';
// import '../Model/User.dart';
// import 'Add_Address.dart';
// import 'Manage_Address.dart';
// import 'Order_Success.dart';
// import 'Payment.dart';
// import 'PaypalWebviewActivity.dart';
//
// class Cart extends StatefulWidget {
//   final bool fromBottom;
//
//   const Cart({Key? key, required this.fromBottom}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => StateCart();
// }
//
// List<User> addressList = [];
// //List<SectionModel> cartList = [];
// List<Promo> promoList = [];
// double totalPrice = 0, oriPrice = 0, delCharge = 0, taxPer = 0;
// int? selectedAddress = 0;
// String? selAddress, payMethod = '', selTime, selDate, promocode;
// bool? isTimeSlot,
//     isPromoValid = false,
//     isUseWallet = false,
//     isPayLayShow = true;
// int? selectedTime, selectedDate, selectedMethod;
//
// double promoAmt = 0;
// double remWalBal = 0, usedBal = 0;
// bool isAvailable = true;
//
// String? razorpayId,
//     paystackId,
//     stripeId,
//     stripeSecret,
//     stripeMode = "test",
//     stripeCurCode,
//     stripePayId,
//     paytmMerId,
//     paytmMerKey;
// bool payTesting = true;
//
// /*String gpayEnv = "TEST",
//     gpayCcode = "US",
//     gpaycur = "USD",
//     gpayMerId = "01234567890123456789",
//     gpayMerName = "Example Merchant Name";*/
//
// class StateCart extends State<Cart> with TickerProviderStateMixin {
//   final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
//   new GlobalKey<ScaffoldMessengerState>();
//
//   final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
//   new GlobalKey<ScaffoldMessengerState>();
//   List<Model> deliverableList = [];
//   bool _isCartLoad = true, _placeOrder = true;
//
//   //HomePage? home;
//   Animation? buttonSqueezeanimation;
//   AnimationController? buttonController;
//   bool _isNetworkAvail = true;
//
//   List<TextEditingController> _controller = [];
//
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//   new GlobalKey<RefreshIndicatorState>();
//   List<SectionModel> saveLaterList = [];
//   String? msg;
//   String? sellerId;
//   bool _isLoading = true;
//   Razorpay? _razorpay;
//   TextEditingController promoC = new TextEditingController();
//   TextEditingController noteC = new TextEditingController();
//   StateSetter? checkoutState;
//   final paystackPlugin = PaystackPlugin();
//   bool deliverable = false;
//   bool saveLater = false, addCart = false;
//   bool isOnOff = false;
//   String? totalamount;
//
//   //List<PaymentItem> _gpaytItems = [];
//   //Pay _gpayClient;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     clearAll();
//
//     _getCart("0");
//     _getSaveLater("1");
//     // _getAddress();
//
//     buttonController = new AnimationController(
//         duration: new Duration(milliseconds: 2000), vsync: this);
//
//     buttonSqueezeanimation = new Tween(
//       begin: deviceWidth! * 0.7,
//       end: 50.0,
//     ).animate(new CurvedAnimation(
//       parent: buttonController!,
//       curve: new Interval(
//         0.0,
//         0.150,
//       ),
//     ));
//   }
//
//   Future<Null> _refresh() {
//     if (mounted)
//       setState(() {
//         _isCartLoad = true;
//       });
//     clearAll();
//
//     _getCart("0");
//     return _getSaveLater("1");
//   }
//
//   clearAll() {
//     totalPrice = 0;
//     oriPrice = 0;
//
//     taxPer = 0;
//     delCharge = 0;
//     addressList.clear();
//     // cartList.clear();
//     WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
//       context.read<CartProvider>().setCartlist([]);
//       context.read<CartProvider>().setProgress(false);
//     });
//
//     promoAmt = 0;
//     remWalBal = 0;
//     usedBal = 0;
//     payMethod = '';
//     isPromoValid = false;
//     isUseWallet = false;
//     isPayLayShow = true;
//     selectedMethod = null;
//   }
//
//   @override
//   void dispose() {
//     buttonController!.dispose();
//     for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
//
//     if (_razorpay != null) _razorpay!.clear();
//     super.dispose();
//   }
//
//   Future<Null> _playAnimation() async {
//     try {
//       await buttonController!.forward();
//     } on TickerCanceled {}
//   }
//
//   Widget noInternet(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           noIntImage(),
//           noIntText(context),
//           noIntDec(context),
//           AppBtn(
//             title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
//             btnAnim: buttonSqueezeanimation,
//             btnCntrl: buttonController,
//             onBtnSelected: () async {
//               _playAnimation();
//
//               Future.delayed(Duration(seconds: 2)).then((_) async {
//                 _isNetworkAvail = await isNetworkAvailable();
//                 if (_isNetworkAvail) {
//                   Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (BuildContext context) => super.widget));
//                 } else {
//                   await buttonController!.reverse();
//                   if (mounted) setState(() {});
//                 }
//               });
//             },
//           )
//         ]),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     deviceHeight = MediaQuery.of(context).size.height;
//     deviceWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//         appBar: widget.fromBottom
//             ? null
//             : getSimpleAppBar(getTranslated(context, 'CART')!, context),
//         body: _isNetworkAvail
//             ? Stack(
//           children: <Widget>[
//             _showContent(context),
//             Selector<CartProvider, bool>(
//               builder: (context, data, child) {
//                 return showCircularProgress(data, colors.primary);
//               },
//               selector: (_, provider) => provider.isProgress,
//             ),
//           ],
//         )
//             : noInternet(context));
//   }
//
//   Widget listItem(int index, List<SectionModel> cartList) {
//     int selectedPos = 0;
//     for (int i = 0;
//     i < cartList[index].productList![0].prVarientList!.length;
//     i++) {
//       if (cartList[index].varientId ==
//           cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
//     }
//     String? offPer;
//     double price = double.parse(
//         cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
//     if (price == 0)
//       price = double.parse(
//           cartList[index].productList![0].prVarientList![selectedPos].price!);
//     else {
//       double off = (double.parse(cartList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .price!)) -
//           price;
//       offPer = (off *
//           100 /
//           double.parse(cartList[index]
//               .productList![0]
//               .prVarientList![selectedPos]
//               .price!))
//           .toStringAsFixed(2);
//     }
//
//     cartList[index].perItemPrice = price.toString();
//     //print("qty************${cartList.contains("qty")}");
//     print("cartList**avail****${cartList[index].productList![0].availability}");
//
//     if (_controller.length < index + 1) {
//       _controller.add(new TextEditingController());
//     }
//     if (cartList[index].productList![0].availability != "0") {
//       cartList[index].perItemTotal =
//           (price * double.parse(cartList[index].qty!)).toString();
//       _controller[index].text = cartList[index].qty!;
//     }
//     List att = [], val = [];
//     if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
//         null) {
//       att = cartList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .attr_name!
//           .split(',');
//       val = cartList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .varient_value!
//           .split(',');
//     }
//
//     if (cartList[index].productList![0].availability == "0") {
//       isAvailable = false;
//     }
//     return Padding(
//         padding: const EdgeInsets.symmetric(
//           vertical: 10.0,
//         ),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Card(
//               elevation: 0.1,
//               child: Row(
//                 children: <Widget>[
//                   Hero(
//                       tag: "$index${cartList[index].productList![0].id}",
//                       child: Stack(
//                         children: [
//                           ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: Stack(children: [
//                                 Card(
//                                   child: Container(
//                                     width: 120,
//                                     height: 100,
//                                     child: FadeInImage(
//                                       image: CachedNetworkImageProvider(
//                                           cartList[index].productList![0].image!),
//                                       height: 125.0,
//                                       width: 110.0,
//                                       fit: BoxFit.contain,
//                                       imageErrorBuilder:
//                                           (context, error, stackTrace) =>
//                                           erroWidget(125),
//                                       placeholder: placeHolder(125),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned.fill(
//                                     child: cartList[index]
//                                         .productList![0]
//                                         .availability ==
//                                         "0"
//                                         ? Container(
//                                       height: 55,
//                                       color: Colors.white70,
//                                       // width: double.maxFinite,
//                                       padding: EdgeInsets.all(2),
//                                       child: Center(
//                                         child: Text(
//                                           getTranslated(context,
//                                               'OUT_OF_STOCK_LBL')!,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .caption!
//                                               .copyWith(
//                                             color: Colors.red,
//                                             fontWeight:
//                                             FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     )
//                                         : Container()),
//                               ])),
//                           offPer != null
//                               ? Container(
//                             decoration: BoxDecoration(
//                                 color: colors.red,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: Text(
//                                 offPer + "%",
//                                 style: TextStyle(
//                                     color: colors.whiteTemp,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 9),
//                               ),
//                             ),
//                             margin: EdgeInsets.all(5),
//                           )
//                               : Container()
//                         ],
//                       )),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsetsDirectional.only(
//                                       top: 5.0),
//                                   child: Text(
//                                     cartList[index].productList![0].name!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle1!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 child: Padding(
//                                   padding: const EdgeInsetsDirectional.only(
//                                       start: 8.0, end: 8, bottom: 8),
//                                   child: Icon(
//                                     Icons.clear,
//                                     size: 20,
//                                     color:
//                                     Theme.of(context).colorScheme.fontColor,
//                                   ),
//                                 ),
//                                 onTap: () {
//                                   print(index);
//                                   print(cartList);
//                                   print(selectedPos);
//                                   if (context.read<CartProvider>().isProgress ==
//                                       false)
//                                     removeFromCart(index, true, cartList, false,
//                                         selectedPos);
//                                 },
//                               )
//                             ],
//                           ),
//                           cartList[index]
//                               .productList![0]
//                               .prVarientList![selectedPos]
//                               .attr_name !=
//                               null &&
//                               cartList[index]
//                                   .productList![0]
//                                   .prVarientList![selectedPos]
//                                   .attr_name!
//                                   .isNotEmpty
//                               ? ListView.builder(
//                               physics: NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               itemCount: att.length,
//                               itemBuilder: (context, index) {
//                                 return Row(children: [
//                                   Flexible(
//                                     child: Text(
//                                       att[index].trim() + ":",
//                                       overflow: TextOverflow.ellipsis,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .subtitle2!
//                                           .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsetsDirectional.only(
//                                         start: 5.0),
//                                     child: Text(
//                                       val[index],
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .subtitle2!
//                                           .copyWith(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .lightBlack,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   )
//                                 ]);
//                               })
//                               : Container(),
//                           Row(
//                             children: <Widget>[
//                               Text(
//                                 double.parse(cartList[index]
//                                     .productList![0]
//                                     .prVarientList![selectedPos]
//                                     .disPrice!) !=
//                                     0
//                                     ? CUR_CURRENCY! +
//                                     "" +
//                                     cartList[index]
//                                         .productList![0]
//                                         .prVarientList![selectedPos]
//                                         .price!
//                                     : "",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .overline!
//                                     .copyWith(
//                                     decoration: TextDecoration.lineThrough,
//                                     letterSpacing: 0.7),
//                               ),
//                               Text(
//                                 " " + CUR_CURRENCY! + " " + price.toString(),
//                                 style: TextStyle(
//                                     color:
//                                     Theme.of(context).colorScheme.fontColor,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           cartList[index].productList![0].availability == "1" ||
//                               cartList[index].productList![0].stockType ==
//                                   "0"
//                               ? Row(
//                             children: <Widget>[
//                               Row(
//                                 children: <Widget>[
//                                   GestureDetector(
//                                     child: Card(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                         BorderRadius.circular(50),
//                                       ),
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.all(8.0),
//                                         child: Icon(
//                                           Icons.remove,
//                                           size: 15,
//                                         ),
//                                       ),
//                                     ),
//                                     onTap: () {
//                                       if (context
//                                           .read<CartProvider>()
//                                           .isProgress ==
//                                           false)
//                                         removeFromCart(index, false,
//                                             cartList, false, selectedPos);
//                                     },
//                                   ),
//                                   Container(
//                                     width: 26,
//                                     height: 20,
//                                     child: Stack(
//                                       children: [
//                                         TextField(
//                                           textAlign: TextAlign.center,
//                                           readOnly: true,
//                                           style: TextStyle(
//                                               fontSize: 12,
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .fontColor),
//                                           controller: _controller[index],
//                                           decoration: InputDecoration(
//                                             border: InputBorder.none,
//                                           ),
//                                         ),
//                                         // PopupMenuButton<String>(
//                                         //   tooltip: '',
//                                         //   icon: const Icon(
//                                         //     Icons.arrow_drop_down,
//                                         //     size: 1,
//                                         //   ),
//                                         //   onSelected: (String value) {
//                                         //     if (context
//                                         //             .read<CartProvider>()
//                                         //             .isProgress ==
//                                         //         false)
//                                         //       addToCart(
//                                         //           index, value, cartList);
//                                         //   },
//                                         //   itemBuilder:
//                                         //       (BuildContext context) {
//                                         //     return cartList[index]
//                                         //         .productList![0]
//                                         //         .itemsCounter!
//                                         //         .map<
//                                         //                 PopupMenuItem<
//                                         //                     String>>(
//                                         //             (String value) {
//                                         //       return new PopupMenuItem(
//                                         //           child: new Text(value,
//                                         //               style: TextStyle(
//                                         //                   color: Theme.of(
//                                         //                           context)
//                                         //                       .colorScheme
//                                         //                       .fontColor)),
//                                         //           value: value);
//                                         //     }).toList();
//                                         //   },
//                                         // ),
//                                       ],
//                                     ),
//                                   ), // ),
//
//                                   GestureDetector(
//                                     child: Card(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                         BorderRadius.circular(50),
//                                       ),
//                                       child: Padding(
//                                         padding:
//                                         const EdgeInsets.all(8.0),
//                                         child: Icon(
//                                           Icons.add,
//                                           size: 15,
//                                         ),
//                                       ),
//                                     ),
//                                     onTap: () {
//                                       print("New QUUUUUUUUUUUU_______ ${cartList[index]
//                                           .qty!}");
//                                       if (context
//                                           .read<CartProvider>()
//                                           .isProgress ==
//                                           false)
//                                         addToCart(
//                                             index,
//                                             (int.parse(cartList[index]
//                                                 .qty!) +
//                                                 int.parse(cartList[
//                                                 index]
//                                                     .productList![0]
//                                                     .qtyStepSize!))
//                                                 .toString(),
//                                             cartList);
//                                     },
//                                   )
//                                 ],
//                               ),
//                             ],
//                           )
//                               : Container(),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             Positioned.directional(
//                 textDirection: Directionality.of(context),
//                 end: 0,
//                 bottom: -15,
//                 child: Card(
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                   child: InkWell(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Icon(
//                         Icons.archive_rounded,
//                         size: 20,
//                       ),
//                     ),
//                     onTap: !saveLater &&
//                         !context.read<CartProvider>().isProgress
//                         ? () {
//                       setState(() {
//                         saveLater = true;
//                       });
//                       saveForLater(
//                           cartList[index].productList![0].availability ==
//                               "0"
//                               ? cartList[index]
//                               .productList![0]
//                               .prVarientList![selectedPos]
//                               .id!
//                               : cartList[index].varientId,
//                           "1",
//                           cartList[index].productList![0].availability ==
//                               "0"
//                               ? "1"
//                               : cartList[index].qty,
//                           double.parse(cartList[index].perItemTotal!),
//                           cartList[index],
//                           false);
//                     }
//                         : null,
//                   ),
//                 ))
//           ],
//         ));
//   }
//
//   Widget cartItem(int index, List<SectionModel> cartList) {
//     int selectedPos = 0;
//     for (int i = 0;
//     i < cartList[index].productList![0].prVarientList!.length;
//     i++) {
//       if (cartList[index].varientId ==
//           cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
//     }
//
//     double price = double.parse(
//         cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
//     if (price == 0)
//       price = double.parse(
//           cartList[index].productList![0].prVarientList![selectedPos].price!);
//
//     cartList[index].perItemPrice = price.toString();
//     cartList[index].perItemTotal =
//         (price * double.parse(cartList[index].qty!)).toString();
//
//     _controller[index].text = cartList[index].qty!;
//
//     List att = [], val = [];
//     if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
//         null) {
//       att = cartList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .attr_name!
//           .split(',');
//       val = cartList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .varient_value!
//           .split(',');
//     }
//
//     String? id, varId;
//     bool? avail = false;
//     if (deliverableList.length > 0) {
//       id = cartList[index].id;
//       varId = cartList[index].productList![0].prVarientList![selectedPos].id;
//
//       for (int i = 0; i < deliverableList.length; i++) {
//         if (id == deliverableList[i].prodId &&
//             varId == deliverableList[i].varId) {
//           avail = deliverableList[i].isDel;
//
//           break;
//         }
//       }
//     }
//
//     return Card(
//       elevation: 0.1,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: <Widget>[
//                 Hero(
//                     tag: "$index${cartList[index].productList![0].id}",
//                     child: ClipRRect(
//                         borderRadius: BorderRadius.circular(7.0),
//                         child: FadeInImage(
//                           image: CachedNetworkImageProvider(
//                               cartList[index].productList![0].image!),
//                           height: 80.0,
//                           width: 80.0,
//                           fit: BoxFit.cover,
//                           imageErrorBuilder: (context, error, stackTrace) =>
//                               erroWidget(80),
//
//                           // errorWidget: (context, url, e) => placeHolder(60),
//                           placeholder: placeHolder(80),
//                         ))),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsetsDirectional.only(start: 8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding:
//                                 const EdgeInsetsDirectional.only(top: 5.0),
//                                 child: Text(
//                                   cartList[index].productList![0].name!,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .subtitle2!
//                                       .copyWith(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .lightBlack),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ),
//                             // GestureDetector(
//                             //   child: Padding(
//                             //     padding: const EdgeInsetsDirectional.only(
//                             //         start: 8.0, end: 8, bottom: 8),
//                             //     child: Icon(
//                             //       Icons.clear,
//                             //       size: 13,
//                             //       color:
//                             //           Theme.of(context).colorScheme.fontColor,
//                             //     ),
//                             //   ),
//                             //   onTap: () {
//                             //     if (context.read<CartProvider>().isProgress ==
//                             //         false)
//                             //       removeFromCartCheckout(index, true, cartList);
//                             //   },
//                             // )
//                           ],
//                         ),
//                         cartList[index]
//                             .productList![0]
//                             .prVarientList![selectedPos]
//                             .attr_name !=
//                             null &&
//                             cartList[index]
//                                 .productList![0]
//                                 .prVarientList![selectedPos]
//                                 .attr_name!
//                                 .isNotEmpty
//                             ? ListView.builder(
//                             physics: NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: att.length,
//                             itemBuilder: (context, index) {
//                               return Row(children: [
//                                 Flexible(
//                                   child: Text(
//                                     att[index].trim() + ":",
//                                     overflow: TextOverflow.ellipsis,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .lightBlack,
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.only(
//                                       start: 5.0),
//                                   child: Text(
//                                     val[index],
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 )
//                               ]);
//                             })
//                             : Container(),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: <Widget>[
//                                   Flexible(
//                                     child: Text(
//                                       double.parse(cartList[index]
//                                           .productList![0]
//                                           .prVarientList![selectedPos]
//                                           .disPrice!) !=
//                                           0
//                                           ? CUR_CURRENCY! +
//                                           "" +
//                                           cartList[index]
//                                               .productList![0]
//                                               .prVarientList![selectedPos]
//                                               .price!
//                                           : "",
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .overline!
//                                           .copyWith(
//                                           decoration:
//                                           TextDecoration.lineThrough,
//                                           letterSpacing: 0.7),
//                                     ),
//                                   ),
//                                   Text(
//                                     " " +
//                                         CUR_CURRENCY! +
//                                         " " +
//                                         price.toString(),
//                                     style: TextStyle(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             cartList[index].productList![0].availability ==
//                                 "1" ||
//                                 cartList[index].productList![0].stockType ==
//                                     "null"
//                                 ? Row(
//                               children: <Widget>[
//                                 Row(
//                                   children: <Widget>[
//                                     // GestureDetector(
//                                     //   child: Card(
//                                     //     shape: RoundedRectangleBorder(
//                                     //       borderRadius:
//                                     //           BorderRadius.circular(50),
//                                     //     ),
//                                     //     child: Padding(
//                                     //       padding:
//                                     //           const EdgeInsets.all(8.0),
//                                     //       child: Icon(
//                                     //         Icons.remove,
//                                     //         size: 15,
//                                     //       ),
//                                     //     ),
//                                     //   ),
//                                     //   onTap: () {
//                                     //     if (context
//                                     //             .read<CartProvider>()
//                                     //             .isProgress ==
//                                     //         false)
//                                     //       removeFromCartCheckout(
//                                     //           index, false, cartList);
//                                     //   },
//                                     // ),
//                                     Container(
//                                       width: 26,
//                                       height: 20,
//                                       child: Stack(
//                                         children: [
//                                           TextField(
//                                             textAlign: TextAlign.center,
//                                             readOnly: true,
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Theme.of(context)
//                                                     .colorScheme
//                                                     .fontColor),
//                                             controller:
//                                             _controller[index],
//                                             decoration: InputDecoration(
//                                               border: InputBorder.none,
//                                             ),
//                                           ),
//                                           // PopupMenuButton<String>(
//                                           //   tooltip: '',
//                                           //   icon: const Icon(
//                                           //     Icons.arrow_drop_down,
//                                           //     size: 1,
//                                           //   ),
//                                           //   onSelected: (String value) {
//                                           //     addToCartCheckout(
//                                           //         index, value, cartList);
//                                           //   },
//                                           //   itemBuilder:
//                                           //       (BuildContext context) {
//                                           //     return cartList[index]
//                                           //         .productList![0]
//                                           //         .itemsCounter!
//                                           //         .map<
//                                           //                 PopupMenuItem<
//                                           //                     String>>(
//                                           //             (String value) {
//                                           //       return new PopupMenuItem(
//                                           //           child: new Text(
//                                           //             value,
//                                           //             style: TextStyle(
//                                           //                 color: Theme.of(
//                                           //                         context)
//                                           //                     .colorScheme
//                                           //                     .fontColor),
//                                           //           ),
//                                           //           value: value);
//                                           //     }).toList();
//                                           //   },
//                                           // ),
//                                         ],
//                                       ),
//                                     ),
//                                     // GestureDetector(
//                                     //   child: Card(
//                                     //     shape: RoundedRectangleBorder(
//                                     //       borderRadius:
//                                     //           BorderRadius.circular(50),
//                                     //     ),
//                                     //     child: Padding(
//                                     //       padding:
//                                     //           const EdgeInsets.all(8.0),
//                                     //       child: Icon(
//                                     //         Icons.add,
//                                     //         size: 15,
//                                     //       ),
//                                     //     ),
//                                     //   ),
//                                     //   onTap: () {
//                                     //     addToCartCheckout(
//                                     //         index,
//                                     //         (int.parse(cartList[index]
//                                     //                     .qty!) +
//                                     //                 int.parse(cartList[
//                                     //                         index]
//                                     //                     .productList![0]
//                                     //                     .qtyStepSize!))
//                                     //             .toString(),
//                                     //         cartList);
//                                     //   },
//                                     // )
//                                   ],
//                                 ),
//                               ],
//                             )
//                                 : Container(),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   getTranslated(context, 'SUBTOTAL')!,
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 ),
//                 Text(
//                   CUR_CURRENCY! + " " + price.toString(),
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 ),
//                 Text(
//                   CUR_CURRENCY! + " " + cartList[index].perItemTotal!,
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 )
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   getTranslated(context, 'TAXPER')!,
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 ),
//                 Text(
//                   cartList[index].productList![0].tax! + "%",
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   getTranslated(context, 'TOTAL_LBL')!,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.lightBlack2),
//                 ),
//                 !avail! && deliverableList.length > 0
//                     ? Text(
//                   getTranslated(context, 'NOT_DEL')!,
//                   style: TextStyle(color: colors.red),
//                 )
//                     : Container(),
//                 Text(
//                   CUR_CURRENCY! +
//                       " " +
//                       (double.parse(cartList[index].perItemTotal!))
//                           .toStringAsFixed(2)
//                           .toString(),
//                   //+ " "+cartList[index].productList[0].taxrs,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.fontColor),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget saveLaterItem(int index) {
//     int selectedPos = 0;
//     for (int i = 0;
//     i < saveLaterList[index].productList![0].prVarientList!.length;
//     i++) {
//       if (saveLaterList[index].varientId ==
//           saveLaterList[index].productList![0].prVarientList![i].id)
//         selectedPos = i;
//     }
//
//     double price = double.parse(saveLaterList[index]
//         .productList![0]
//         .prVarientList![selectedPos]
//         .disPrice!);
//     if (price == 0) {
//       price = double.parse(saveLaterList[index]
//           .productList![0]
//           .prVarientList![selectedPos]
//           .price!);
//     }
//
//     double off = (double.parse(saveLaterList[index]
//         .productList![0]
//         .prVarientList![selectedPos]
//         .price!) -
//         double.parse(saveLaterList[index]
//             .productList![0]
//             .prVarientList![selectedPos]
//             .disPrice!))
//         .toDouble();
//     off = off *
//         100 /
//         double.parse(saveLaterList[index]
//             .productList![0]
//             .prVarientList![selectedPos]
//             .price!);
//
//     saveLaterList[index].perItemPrice = price.toString();
//     if (saveLaterList[index].productList![0].availability != "0") {
//       saveLaterList[index].perItemTotal =
//           (price * double.parse(saveLaterList[index].qty!)).toString();
//     }
//     return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Card(
//               elevation: 0.1,
//               child: Row(
//                 children: <Widget>[
//                   Hero(
//                       tag: "$index${saveLaterList[index].productList![0].id}",
//                       child: Stack(
//                         children: [
//                           ClipRRect(
//                               borderRadius: BorderRadius.circular(7.0),
//                               child: Stack(children: [
//                                 FadeInImage(
//                                   image: CachedNetworkImageProvider(
//                                       saveLaterList[index]
//                                           .productList![0]
//                                           .image!),
//                                   height: 100.0,
//                                   width: 100.0,
//                                   fit: BoxFit.cover,
//                                   imageErrorBuilder:
//                                       (context, error, stackTrace) =>
//                                       erroWidget(100),
//                                   placeholder: placeHolder(100),
//                                 ),
//                                 Positioned.fill(
//                                     child: saveLaterList[index]
//                                         .productList![0]
//                                         .availability ==
//                                         "0"
//                                         ? Container(
//                                       height: 55,
//                                       color: Colors.white70,
//                                       // width: double.maxFinite,
//                                       padding: EdgeInsets.all(2),
//                                       child: Center(
//                                         child: Text(
//                                           getTranslated(context,
//                                               'OUT_OF_STOCK_LBL')!,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .caption!
//                                               .copyWith(
//                                             color: Colors.red,
//                                             fontWeight:
//                                             FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     )
//                                         : Container()),
//                               ])),
//                           (off != 0 || off != 0.0 || off != 0.00) &&
//                               saveLaterList[index]
//                                   .productList![0]
//                                   .prVarientList![selectedPos]
//                                   .disPrice! !=
//                                   "0"
//                               ? Container(
//                             decoration: BoxDecoration(
//                                 color: colors.red,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: Text(
//                                 off.toStringAsFixed(2) + "%",
//                                 style: TextStyle(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 9),
//                               ),
//                             ),
//                             margin: EdgeInsets.all(5),
//                           )
//                               : Container()
//                         ],
//                       )),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.only(start: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsetsDirectional.only(
//                                       top: 5.0),
//                                   child: Text(
//                                     saveLaterList[index].productList![0].name!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle1!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 child: Padding(
//                                   padding: const EdgeInsetsDirectional.only(
//                                       start: 8.0, end: 8, bottom: 8),
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 20,
//                                     color:
//                                     Theme.of(context).colorScheme.fontColor,
//                                   ),
//                                 ),
//                                 onTap: () {
//                                   if (context.read<CartProvider>().isProgress ==
//                                       false)
//                                     removeFromCart(index, true, saveLaterList,
//                                         true, selectedPos);
//                                 },
//                               )
//                             ],
//                           ),
//                           Row(
//                             children: <Widget>[
//                               Text(
//                                 double.parse(saveLaterList[index]
//                                     .productList![0]
//                                     .prVarientList![selectedPos]
//                                     .disPrice!) !=
//                                     0
//                                     ? CUR_CURRENCY! +
//                                     "" +
//                                     saveLaterList[index]
//                                         .productList![0]
//                                         .prVarientList![selectedPos]
//                                         .price!
//                                     : "",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .overline!
//                                     .copyWith(
//                                     decoration: TextDecoration.lineThrough,
//                                     letterSpacing: 0.7),
//                               ),
//                               Text(
//                                 " " + CUR_CURRENCY! + " " + price.toString(),
//                                 style: TextStyle(
//                                     color:
//                                     Theme.of(context).colorScheme.fontColor,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             saveLaterList[index].productList![0].availability == "1" ||
//                 saveLaterList[index].productList![0].stockType == "null"
//                 ? Positioned(
//                 bottom: -15,
//                 right: 0,
//                 child: Card(
//                   elevation: 1,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                   child: InkWell(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Icon(
//                         Icons.shopping_cart,
//                         size: 20,
//                       ),
//                     ),
//                     onTap:
//                     !addCart && !context.read<CartProvider>().isProgress
//                         ? () {
//                       setState(() {
//                         addCart = true;
//                       });
//                       saveForLater(
//                           saveLaterList[index].varientId,
//                           "0",
//                           saveLaterList[index].qty,
//                           double.parse(
//                               saveLaterList[index].perItemTotal!),
//                           saveLaterList[index],
//                           true);
//                     }
//                         : null,
//                   ),
//                 ))
//                 : Container()
//           ],
//         ));
//   }
//   var dCharge;
//   String? overallAmount;
//   Future<void> _getCart(String save) async {
//     _isNetworkAvail = await isNetworkAvailable();
//
//     if (_isNetworkAvail) {
//       try {
//         var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
//         print(parameter.toString());
//         Response response =
//         await post(getCartApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(getCartApi.toString());
//
//         var getdata = json.decode(response.body);
//         bool error = getdata["error"];
//         String? msg = getdata["message"];
//         if (!error) {
//           var data = getdata["data"];
//           setState(() {
//             print("Cart nEW================> : $totalamount");
//             totalamount = getdata['overall_amount'];
//             print("Cart aMOUBT================> : $totalamount");
//             //sellerId = data[0]["product_details"][0]["seller_id"];
//           });
//           // isOnOff = onOff;
//           // var  onOff = await checkOnOff(sellerId);
//           // setState(() {
//           //   isOnOff = onOff;
//           // });
//           //print("is On off===========> : $onOff");
//           // print("Seller Id-----------> $seller_id");
//           print("Cart Data================> : $data");
//           print("ssssssssssssssssssssssss$getdata['delivery_charge']");
//           oriPrice = double.parse(getdata[SUB_TOTAL]);
//           // delCharge =getdata['delivery_charge'].toString();
//
//           double.parse(getdata['delivery_charge'].toString());
//           dCharge = double.parse(getdata['delivery_charge'].toString());
//
//           print(" charge here ${delCharge}");
//           taxPer = double.parse(getdata[TAX_PER]);
//
//           totalPrice = delCharge + oriPrice;
//           List<SectionModel> cartList = (data as List)
//               .map((data) => new SectionModel.fromCart(data))
//               .toList();
//           context.read<CartProvider>().setCartlist(cartList);
//          // overallAmount = cartList[0].finalTotal.toString();
//
//           if (getdata.containsKey(PROMO_CODES)) {
//             var promo = getdata[PROMO_CODES];
//             promoList =
//                 (promo as List).map((e) => new Promo.fromJson(e)).toList();
//           }
//
//           for (int i = 0; i < cartList.length; i++)
//             _controller.add(new TextEditingController());
//         } else {
//           if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
//         }
//         if (mounted)
//           setState(() {
//             _isCartLoad = false;
//           });
//
//         _getAddress();
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   promoSheet() {
//     showModalBottomSheet<dynamic>(
//         context: context,
//         isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25), topRight: Radius.circular(25))),
//         builder: (builder) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 return Padding(
//                   padding: MediaQuery.of(context).viewInsets,
//                   child: Container(
//                       padding: EdgeInsets.only(left: 10, right: 10, top: 50),
//                       constraints: BoxConstraints(
//                           maxHeight: MediaQuery.of(context).size.height * 0.9),
//                       child: ListView(shrinkWrap: true, children: <Widget>[
//                         Stack(
//                           alignment: Alignment.centerRight,
//                           children: [
//                             Container(
//                                 margin: const EdgeInsetsDirectional.only(end: 20),
//                                 decoration: BoxDecoration(
//                                     color: Theme.of(context).colorScheme.white,
//                                     borderRadius:
//                                     BorderRadiusDirectional.circular(10)),
//                                 child: TextField(
//                                   controller: promoC,
//                                   style: Theme.of(context).textTheme.subtitle2,
//                                   decoration: InputDecoration(
//                                     contentPadding:
//                                     EdgeInsets.symmetric(horizontal: 10),
//                                     border: InputBorder.none,
//                                     //isDense: true,
//                                     hintText:
//                                     getTranslated(context, 'PROMOCODE_LBL'),
//                                   ),
//                                 )),
//                             Positioned.directional(
//                               textDirection: Directionality.of(context),
//                               end: 0,
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   (promoAmt != 0 && isPromoValid!)
//                                       ? Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: InkWell(
//                                       child: Icon(
//                                         Icons.close,
//                                         size: 15,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                       ),
//                                       onTap: () {
//                                         if (promoAmt != 0 && isPromoValid!) {
//                                           if (mounted)
//                                             setState(() {
//                                               totalPrice =
//                                                   totalPrice + promoAmt;
//                                               promoC.text = '';
//                                               isPromoValid = false;
//                                               promoAmt = 0;
//                                               promocode = '';
//                                             });
//                                         }
//                                       },
//                                     ),
//                                   )
//                                       : Container(),
//                                   InkWell(
//                                     child: Container(
//                                         padding: EdgeInsets.all(11),
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: colors.primary,
//                                         ),
//                                         child: Icon(
//                                           Icons.arrow_forward,
//                                           color:
//                                           Theme.of(context).colorScheme.white,
//                                         )),
//                                     onTap: () {
//                                       if (promoC.text.trim().isEmpty)
//                                         setSnackbar(
//                                             getTranslated(context, 'ADD_PROMO')!,
//                                             _checkscaffoldKey);
//                                       else if (!isPromoValid!) {
//                                         validatePromo(false);
//                                         Navigator.pop(context);
//                                       }
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 18.0),
//                           child: Text(
//                             getTranslated(context, 'Choose_PROMO') ?? '',
//                             style: Theme.of(context).textTheme.subtitle1!.copyWith(
//                                 color: Theme.of(context).colorScheme.fontColor),
//                           ),
//                         ),
//                         ListView.builder(
//                             physics: NeverScrollableScrollPhysics(),
//                             shrinkWrap: true,
//                             itemCount: promoList.length,
//                             itemBuilder: (context, index) {
//                               return Card(
//                                 elevation: 0,
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       height: 80,
//                                       width: 80,
//                                       child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(7.0),
//                                           child: Image.network(
//                                             promoList[index].image!,
//                                             height: 80,
//                                             width: 80,
//                                             fit: BoxFit.fill,
//                                             errorBuilder:
//                                                 (context, error, stackTrace) =>
//                                                 erroWidget(
//                                                   80,
//                                                 ),
//                                           )),
//                                     ),
//
//                                     //errorWidget: (context, url, e) => placeHolder(width),
//
//                                     Expanded(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                           children: [
//                                             Text(promoList[index].msg ?? ""),
//                                             Text(promoList[index].promoCode ?? ''),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Text(promoList[index].day ?? ''),
//                                     SimBtn(
//                                       size: 0.3,
//                                       title: getTranslated(context, "APPLY"),
//                                       onBtnSelected: () {
//                                         promoC.text = promoList[index].promoCode!;
//                                         if (!isPromoValid!) validatePromo(false);
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                       ])),
//                 );
//                 //});
//               });
//         });
//   }
//
//   Future<Null> _getSaveLater(String save) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save,};
//         print(parameter.toString());
//         Response response =
//         await post(getCartApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(getCartApi.toString());
//         // print(getCartApi.toString());
//         var getdata = json.decode(response.body);
//         print(getCartApi.toString());
//         print("Surendra============${parameter.toString()}");
//         bool error = getdata["error"];
//         String? msg = getdata["message"];
//         if (!error) {
//           var data = getdata["data"];
//
//           saveLaterList = (data as List)
//               .map((data) => new SectionModel.fromCart(data))
//               .toList();
//
//           List<SectionModel> cartList = context.read<CartProvider>().cartList;
//           for (int i = 0; i < cartList.length; i++)
//             _controller.add(new TextEditingController());
//         } else {
//           if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
//         }
//         if (mounted) setState(() {});
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//
//     return null;
//   }
//
//   Future<void> addToCart(
//       int index, String qty, List<SectionModel> cartList) async {
//     _isNetworkAvail = await isNetworkAvailable();
//
//     //if (int.parse(qty) >= cartList[index].productList[0].minOrderQuntity) {
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//
//         if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
//           qty = cartList[index].productList![0].minOrderQuntity.toString();
//
//           setSnackbar(
//               "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
//         }
//
//         var parameter = {
//           PRODUCT_VARIENT_ID: cartList[index].varientId,
//           USER_ID: CUR_USERID,
//           QTY: qty,
//         };
//         Response response =
//         await post(manageCartApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         print("Manage Cart Api....${manageCartApi.toString()}");
//         print(parameter.toString());
//
//         var getdata = json.decode(response.body);
//
//         bool error = getdata["error"];
//         String? msg = getdata["message"];
//         if (!error) {
//           var data = getdata["data"];
//
//           String qty = data['total_quantity'];
//           //CUR_CART_COUNT = data['cart_count'];
//
//           context.read<UserProvider>().setCartCount(data['cart_count']);
//           cartList[index].qty = qty;
//
//           oriPrice = double.parse(data['sub_total']);
//           delCharge = double.parse(getdata['delivery_charge']);
//           print(" charge here New----- ${delCharge}");
//
//           _controller[index].text = qty;
//           totalPrice = 0;
//
//           var cart = getdata["cart"];
//           List<SectionModel> uptcartList = (cart as List)
//               .map((cart) => new SectionModel.fromCart(cart))
//               .toList();
//           context.read<CartProvider>().setCartlist(uptcartList);
//
//           if (!ISFLAT_DEL) {
//             if (addressList.length == 0) {
//               delCharge = 0;
//             } else {
//               if ((oriPrice) <
//                   double.parse(addressList[selectedAddress!].freeAmt!))
//                 delCharge =
//                     double.parse(addressList[selectedAddress!].deliveryCharge!);
//               else
//                 delCharge = 0;
//             }
//           } else {
//             if (oriPrice < double.parse(MIN_AMT!))
//               delCharge = double.parse(CUR_DEL_CHR!);
//             else
//               delCharge = 0;
//           }
//           totalPrice = delCharge + oriPrice;
//
//           if (isPromoValid!) {
//             validatePromo(false);
//           } else if (isUseWallet!) {
//             context.read<CartProvider>().setProgress(false);
//             if (mounted)
//               setState(() {
//                 remWalBal = 0;
//                 payMethod = null;
//                 usedBal = 0;
//                 isUseWallet = false;
//                 isPayLayShow = true;
//
//                 selectedMethod = null;
//               });
//           } else {
//             setState(() {});
//             context.read<CartProvider>().setProgress(false);
//           }
//         } else {
//           setSnackbar(msg!, _scaffoldKey);
//           context.read<CartProvider>().setProgress(false);
//         }
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
//         context.read<CartProvider>().setProgress(false);
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//     // } else
//     // setSnackbar(
//     //     "Minimum allowed quantity is ${cartList[index].productList[0].minOrderQuntity} ",
//     //     _scaffoldKey);
//   }
//
//   Future<void> addToCartCheckout(
//       int index, String qty, List<SectionModel> cartList) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//
//         if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
//           qty = cartList[index].productList![0].minOrderQuntity.toString();
//
//           setSnackbar(
//               "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
//         }
//
//         var parameter = {
//           PRODUCT_VARIENT_ID: cartList[index].varientId,
//           USER_ID: CUR_USERID,
//           QTY: qty,
//         };
//
//         Response response =
//         await post(manageCartApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(manageCartApi.toString());
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//           String? msg = getdata["message"];
//           if (!error) {
//             var data = getdata["data"];
//
//             String qty = data['total_quantity'];
//             // CUR_CART_COUNT = data['cart_count'];
//
//             context.read<UserProvider>().setCartCount(data['cart_count']);
//             cartList[index].qty = qty;
//
//             oriPrice = double.parse(data['sub_total']);
//             _controller[index].text = qty;
//             totalPrice = 0;
//
//             if (!ISFLAT_DEL) {
//               if ((oriPrice) <
//                   double.parse(addressList[selectedAddress!].freeAmt!))
//                 delCharge =
//                     double.parse(addressList[selectedAddress!].deliveryCharge!);
//               else
//                 delCharge = 0;
//             } else {
//               if ((oriPrice) < double.parse(MIN_AMT!))
//                 delCharge = double.parse(CUR_DEL_CHR!);
//               else
//                 delCharge = 0;
//             }
//             totalPrice = delCharge + oriPrice;
//
//             if (isPromoValid!) {
//               validatePromo(true);
//             } else if (isUseWallet!) {
//               if (mounted)
//                 checkoutState!(() {
//                   remWalBal = 0;
//                   payMethod = null;
//                   usedBal = 0;
//                   isUseWallet = false;
//                   isPayLayShow = true;
//
//                   selectedMethod = null;
//                 });
//               setState(() {});
//             } else {
//               context.read<CartProvider>().setProgress(false);
//               setState(() {});
//               checkoutState!(() {});
//             }
//           } else {
//             setSnackbar(msg!, _checkscaffoldKey);
//             context.read<CartProvider>().setProgress(false);
//           }
//         }
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//         context.read<CartProvider>().setProgress(false);
//       }
//     } else {
//       if (mounted)
//         checkoutState!(() {
//           _isNetworkAvail = false;
//         });
//       setState(() {});
//     }
//   }
//
//   saveForLater(String? id, String save, String? qty, double price,
//       SectionModel curItem, bool fromSave) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//
//         var parameter = {
//           PRODUCT_VARIENT_ID: id,
//           USER_ID: CUR_USERID,
//           QTY: qty,
//           SAVE_LATER: save
//         };
//
//         print("param****save***********$parameter");
//
//         Response response =
//         await post(manageCartApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         var getdata = json.decode(response.body);
//
//         bool error = getdata["error"];
//         String? msg = getdata["message"];
//         if (!error) {
//           var data = getdata["data"];
//           // CUR_CART_COUNT = data['cart_count'];
//           context.read<UserProvider>().setCartCount(data['cart_count']);
//           if (save == "1") {
//             setSnackbar("Saved For Later", _scaffoldKey);
//             saveLaterList.add(curItem);
//             //cartList.removeWhere((item) => item.varientId == id);
//             context.read<CartProvider>().removeCartItem(id!);
//             setState(() {
//               saveLater = false;
//             });
//             oriPrice = oriPrice - price;
//           } else {
//             setSnackbar("Added To Cart", _scaffoldKey);
//             // cartList.add(curItem);
//             context.read<CartProvider>().addCartItem(curItem);
//             saveLaterList.removeWhere((item) => item.varientId == id);
//             setState(() {
//               addCart = false;
//             });
//             oriPrice = oriPrice + price;
//           }
//
//           totalPrice = 0;
//
//           if (!ISFLAT_DEL) {
//             if (addressList.length > 0 &&
//                 (oriPrice) <
//                     double.parse(addressList[selectedAddress!].freeAmt!)) {
//               delCharge =
//                   double.parse(addressList[selectedAddress!].deliveryCharge!);
//             } else {
//               delCharge = 0;
//             }
//           } else {
//             if ((oriPrice) < double.parse(MIN_AMT!)) {
//               delCharge = double.parse(CUR_DEL_CHR!);
//             } else {
//               delCharge = 0;
//             }
//           }
//           totalPrice = delCharge + oriPrice;
//
//           if (isPromoValid!) {
//             validatePromo(false);
//           } else if (isUseWallet!) {
//             context.read<CartProvider>().setProgress(false);
//             if (mounted)
//               setState(() {
//                 remWalBal = 0;
//                 payMethod = null;
//                 usedBal = 0;
//                 isUseWallet = false;
//                 isPayLayShow = true;
//               });
//           } else {
//             context.read<CartProvider>().setProgress(false);
//             setState(() {});
//           }
//         } else {
//           setSnackbar(msg!, _scaffoldKey);
//         }
//
//         context.read<CartProvider>().setProgress(false);
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
//         context.read<CartProvider>().setProgress(false);
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   removeFromCartCheckout(
//       int index, bool remove, List<SectionModel> cartList) async {
//     _isNetworkAvail = await isNetworkAvailable();
//
//     if (!remove &&
//         int.parse(cartList[index].qty!) ==
//             cartList[index].productList![0].minOrderQuntity) {
//       setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
//           _checkscaffoldKey);
//     } else {
//       if (_isNetworkAvail) {
//         try {
//           context.read<CartProvider>().setProgress(true);
//
//           int? qty;
//           if (remove)
//             qty = 0;
//           else {
//             qty = (int.parse(cartList[index].qty!) -
//                 int.parse(cartList[index].productList![0].qtyStepSize!));
//
//             if (qty < cartList[index].productList![0].minOrderQuntity!) {
//               qty = cartList[index].productList![0].minOrderQuntity;
//
//               setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
//                   _checkscaffoldKey);
//             }
//           }
//
//           var parameter = {
//             PRODUCT_VARIENT_ID: cartList[index].varientId,
//             USER_ID: CUR_USERID,
//             QTY: qty.toString()
//           };
//
//           Response response =
//           await post(manageCartApi, body: parameter, headers: headers)
//               .timeout(Duration(seconds: timeOut));
//
//           if (response.statusCode == 200) {
//             var getdata = json.decode(response.body);
//
//             bool error = getdata["error"];
//             String? msg = getdata["message"];
//             if (!error) {
//               var data = getdata["data"];
//
//               String? qty = data['total_quantity'];
//               // CUR_CART_COUNT = data['cart_count'];
//
//               context.read<UserProvider>().setCartCount(data['cart_count']);
//               if (qty == "0") remove = true;
//
//               if (remove) {
//                 // cartList.removeWhere((item) => item.varientId == cartList[index].varientId);
//
//                 context
//                     .read<CartProvider>()
//                     .removeCartItem(cartList[index].varientId!);
//               } else {
//                 cartList[index].qty = qty.toString();
//               }
//
//               oriPrice = double.parse(data[SUB_TOTAL]);
//
//               if (!ISFLAT_DEL) {
//                 if ((oriPrice) <
//                     double.parse(addressList[selectedAddress!].freeAmt!))
//                   delCharge = double.parse(
//                       addressList[selectedAddress!].deliveryCharge!);
//                 else
//                   delCharge = 0;
//               } else {
//                 if ((oriPrice) < double.parse(MIN_AMT!))
//                   delCharge = double.parse(CUR_DEL_CHR!);
//                 else
//                   delCharge = 0;
//               }
//
//               totalPrice = 0;
//
//               totalPrice = delCharge + oriPrice;
//
//               if (isPromoValid!) {
//                 validatePromo(true);
//               } else if (isUseWallet!) {
//                 if (mounted)
//                   checkoutState!(() {
//                     remWalBal = 0;
//                     payMethod = null;
//                     usedBal = 0;
//                     isPayLayShow = true;
//                     isUseWallet = false;
//                   });
//                 context.read<CartProvider>().setProgress(false);
//                 setState(() {});
//               } else {
//                 context.read<CartProvider>().setProgress(false);
//
//                 checkoutState!(() {});
//                 setState(() {});
//               }
//             } else {
//               setSnackbar(msg!, _checkscaffoldKey);
//               context.read<CartProvider>().setProgress(false);
//             }
//           }
//         } on TimeoutException catch (_) {
//           setSnackbar(
//               getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//           context.read<CartProvider>().setProgress(false);
//         }
//       } else {
//         if (mounted)
//           checkoutState!(() {
//             _isNetworkAvail = false;
//           });
//         setState(() {});
//       }
//     }
//   }
//
//   removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
//       int selPos) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (!remove &&
//         int.parse(cartList[index].qty!) ==
//             cartList[index].productList![0].minOrderQuntity) {
//       setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
//           _scaffoldKey);
//     } else {
//       if (_isNetworkAvail) {
//         try {
//           context.read<CartProvider>().setProgress(true);
//
//           int? qty;
//           if (remove)
//             qty = 0;
//           else {
//             qty = (int.parse(cartList[index].qty!) -
//                 int.parse(cartList[index].productList![0].qtyStepSize!));
//
//             if (qty < cartList[index].productList![0].minOrderQuntity!) {
//               qty = cartList[index].productList![0].minOrderQuntity;
//
//               setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
//                   _checkscaffoldKey);
//             }
//           }
//           String varId;
//           if (cartList[index].productList![0].availability == "0") {
//             varId = cartList[index].productList![0].prVarientList![selPos].id!;
//           } else {
//             varId = cartList[index].varientId!;
//           }
//           print("carient**********${cartList[index].varientId}");
//           var parameter = {
//             PRODUCT_VARIENT_ID: varId,
//             USER_ID: CUR_USERID,
//             QTY: qty.toString()
//           };
//
//           Response response =
//           await post(manageCartApi, body: parameter, headers: headers)
//               .timeout(Duration(seconds: timeOut));
//
//           var getdata = json.decode(response.body);
//           print(getdata);
//
//           bool error = getdata["error"];
//           String? msg = getdata["message"];
//           if (!error) {
//             print("msg************$msg");
//             var data = getdata["data"];
//             setSnackbar("Deleted", _scaffoldKey);
//             String? qty = data['total_quantity'];
//             // CUR_CART_COUNT = data['cart_count'];
//
//             context.read<UserProvider>().setCartCount(data['cart_count']);
//             if (move == false) {
//               if (qty == "0") remove = true;
//
//               if (remove) {
//                 cartList.removeWhere(
//                         (item) => item.varientId == cartList[index].varientId);
//               } else {
//                 cartList[index].qty = qty.toString();
//               }
//
//               oriPrice = double.parse(data[SUB_TOTAL]);
//               if (!ISFLAT_DEL) {
//                 try {
//                   if ((oriPrice) <
//                       double.parse(addressList[selectedAddress!].freeAmt!))
//                     delCharge = double.parse(
//                         addressList[selectedAddress!].deliveryCharge!);
//                   else
//                     delCharge = 0;
//                 } catch (e) {
//                   print(e);
//                 }
//               } else {
//                 if ((oriPrice) < double.parse(MIN_AMT!))
//                   delCharge = double.parse(CUR_DEL_CHR!);
//                 else
//                   delCharge = 0;
//               }
//
//               totalPrice = 0;
//
//               totalPrice = delCharge + oriPrice;
//               if (isPromoValid!) {
//                 validatePromo(false);
//               } else if (isUseWallet!) {
//                 context.read<CartProvider>().setProgress(false);
//                 if (mounted)
//                   setState(() {
//                     remWalBal = 0;
//                     payMethod = null;
//                     usedBal = 0;
//                     isPayLayShow = true;
//                     isUseWallet = false;
//                   });
//               } else {
//                 context.read<CartProvider>().setProgress(false);
//                 setState(() {});
//               }
//             } else {
//               if (qty == "0") remove = true;
//
//               if (remove) {
//                 cartList.removeWhere(
//                         (item) => item.varientId == cartList[index].varientId);
//               }
//             }
//           } else {
//             print("msg111************$msg");
//             setSnackbar(msg!, _scaffoldKey);
//           }
//           if (mounted) setState(() {});
//           context.read<CartProvider>().setProgress(false);
//         } on TimeoutException catch (_) {
//           setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
//           context.read<CartProvider>().setProgress(false);
//         }
//       } else {
//         if (mounted)
//           setState(() {
//             _isNetworkAvail = false;
//           });
//       }
//     }
//   }
//
//   setSnackbar(
//       String msg, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
//     ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
//       duration: Duration(seconds: 1),
//       content: new Text(
//         msg,
//         textAlign: TextAlign.center,
//         style: TextStyle(color: Theme.of(context).colorScheme.black),
//       ),
//       backgroundColor: Theme.of(context).colorScheme.white,
//       elevation: 1.0,
//     ));
//   }
//
//   _showContent(BuildContext context) {
//     List<SectionModel> cartList = context.read<CartProvider>().cartList;
//     print("cart list************${cartList.length}");
//     return _isCartLoad
//         ? shimmer(context)
//         : cartList.length == 0 && saveLaterList.length == 0
//         ? cartEmpty()
//         : Column(
//       children: <Widget>[
//         Expanded(
//           child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: RefreshIndicator(
//                   color: colors.primary,
//                   key: _refreshIndicatorKey,
//                   onRefresh: _refresh,
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.max,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: cartList.length,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             return listItem(index, cartList);
//                           },
//                         ),
//                         saveLaterList.length > 0
//                             ? Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             getTranslated(
//                                 context, 'SAVEFORLATER_BTN')!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .subtitle1!
//                                 .copyWith(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .fontColor),
//                           ),
//                         )
//                             : Container(),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: saveLaterList.length,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             return saveLaterItem(index);
//                           },
//                         ),
//                       ],
//                     ),
//                   ))),
//         ),
//         Container(
//           child: Column(mainAxisSize: MainAxisSize.min, children: <
//               Widget>[
//             promoList.length > 0 && oriPrice > 0
//                 ? Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 10.0),
//               child: InkWell(
//                 child: Stack(
//                   alignment: Alignment.centerRight,
//                   children: [
//                     Container(
//                         margin:
//                         const EdgeInsetsDirectional.only(
//                             end: 20),
//                         decoration: BoxDecoration(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .white,
//                             borderRadius:
//                             BorderRadiusDirectional
//                                 .circular(10)),
//                         child: TextField(
//                           textDirection:
//                           Directionality.of(context),
//                           enabled: false,
//                           controller: promoC,
//                           readOnly: true,
//                           style: Theme.of(context)
//                               .textTheme
//                               .subtitle2,
//                           decoration: InputDecoration(
//                             contentPadding:
//                             EdgeInsets.symmetric(
//                                 horizontal: 10),
//                             border: InputBorder.none,
//                             //isDense: true,
//                             hintText: getTranslated(
//                                 context, 'PROMOCODE_LBL') ??
//                                 '',
//                           ),
//                         )),
//                     Positioned.directional(
//                       textDirection: Directionality.of(context),
//                       end: 0,
//                       child: Container(
//                           padding: EdgeInsets.all(11),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Theme.of(context).colorScheme.lightBlack,
//                           ),
//                           child: Icon(
//                             Icons.arrow_forward,
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .white,
//                           )),
//                     ),
//                   ],
//                 ),
//                 onTap: promoSheet,
//               ),
//             )
//                 : Container(),
//             Container(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.white,
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                 ),
//                 margin:
//                 EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 padding:
//                 EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//                 //  width: deviceWidth! * 0.9,
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(getTranslated(context, 'TOTAL_PRICE')!),
//                         Text(
//                           CUR_CURRENCY! +
//                               " ${oriPrice.toStringAsFixed(2)}",
//                           style: Theme.of(context)
//                               .textTheme
//                               .subtitle1!
//                               .copyWith(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .fontColor),
//                         ),
//                       ],
//                     ),
//                     isPromoValid!
//                         ? Row(
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           getTranslated(
//                               context, 'PROMO_CODE_DIS_LBL')!,
//                           style: Theme.of(context)
//                               .textTheme
//                               .caption!
//                               .copyWith(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .lightBlack2),
//                         ),
//                         Text(
//                           CUR_CURRENCY! +
//                               " " +
//                               promoAmt.toString(),
//                           style: Theme.of(context)
//                               .textTheme
//                               .caption!
//                               .copyWith(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .lightBlack2),
//                         )
//                       ],
//                     )
//                         : Container(),
//                   ],
//                 )),
//             SimBtn(
//                 size: 0.9,
//                 title: getTranslated(context, 'PROCEED_CHECKOUT'),
//                 onBtnSelected: () async {
//                   checkout(cartList);
//                   // if(isOnOff == true){
//                   //   if (oriPrice > 0) {
//                   //     FocusScope.of(context).unfocus();
//                   //     if (isAvailable) {
//                   //       checkout(cartList);
//                   //     } else {
//                   //       setSnackbar(
//                   //           getTranslated(
//                   //               context, 'CART_OUT_OF_STOCK_MSG')!,
//                   //           _scaffoldKey);
//                   //     }
//                   //     if (mounted) setState(() {});
//                   //   } else
//                   //     setSnackbar(getTranslated(context, 'ADD_ITEM')!,
//                   //         _scaffoldKey);
//                   // } else {
//                   //   showToast("Currently Store is Off");
//                   // }
//
//                 }),
//           ]),
//         ),
//       ],
//     );
//   }
//
//   cartEmpty() {
//     return Center(
//       child: SingleChildScrollView(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           noCartImage(context),
//           noCartText(context),
//           noCartDec(context),
//           shopNow()
//         ]),
//       ),
//     );
//   }
//
//   getAllPromo() {}
//
//   noCartImage(BuildContext context) {
//     return SvgPicture.asset(
//       'assets/images/empty_cart.svg',
//       fit: BoxFit.contain,
//       color: colors.primary,
//     );
//   }
//
//   noCartText(BuildContext context) {
//     return Container(
//         child: Text(getTranslated(context, 'NO_CART')!,
//             style: Theme.of(context).textTheme.headline5!.copyWith(
//                 color: colors.primary, fontWeight: FontWeight.normal)));
//   }
//
//   noCartDec(BuildContext context) {
//     return Container(
//       padding: EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
//       child: Text(getTranslated(context, 'CART_DESC')!,
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.headline6!.copyWith(
//             color: Theme.of(context).colorScheme.lightBlack2,
//             fontWeight: FontWeight.normal,
//           )),
//     );
//   }
//
//   shopNow() {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(top: 28.0),
//       child: CupertinoButton(
//         child: Container(
//             width: deviceWidth! * 0.7,
//             height: 45,
//             alignment: FractionalOffset.center,
//             decoration: new BoxDecoration(
//               color: colors.primary,
//               // gradient: LinearGradient(
//               //     begin: Alignment.topLeft,
//               //     end: Alignment.bottomRight,
//               //     colors: [colors.grad1Color, colors.grad2Color],
//               //     stops: [0, 1]),
//               borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
//             ),
//             child: Text(getTranslated(context, 'SHOP_NOW')!,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.headline6!.copyWith(
//                     color: Colors.white70))),
//         onPressed: () {
//           Navigator.of(context).pushNamedAndRemoveUntil(
//               '/home', (Route<dynamic> route) => false);
//         },
//       ),
//     );
//   }
//
//   checkout(List<SectionModel> cartList) {
//     print("nnnnnnnnnnnnnnnnnnnnn++++++${totalamount.toString()}");
//     _razorpay = Razorpay();
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     deviceHeight = MediaQuery.of(context).size.height;
//     deviceWidth = MediaQuery.of(context).size.width;
//     return showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10), topRight: Radius.circular(10))),
//         builder: (builder) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 checkoutState = setState;
//                 return Container(
//                     constraints: BoxConstraints(
//                         maxHeight: MediaQuery.of(context).size.height * 0.8),
//                     child: Scaffold(
//                       resizeToAvoidBottomInset: false,
//                       key: _checkscaffoldKey,
//                       body: _isNetworkAvail
//                           ? cartList.length == 0
//                           ? cartEmpty()
//                           : _isLoading
//                           ? shimmer(context)
//                           : Column(
//                         children: [
//                           Expanded(
//                             child: Stack(
//                               children: <Widget>[
//                                 SingleChildScrollView(
//                                   child: Padding(
//                                     padding:
//                                     const EdgeInsets.all(10.0),
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         address(),
//                                         payment(),
//                                         cartItems(cartList),
//                                         // promo(),
//                                         orderSummary(cartList),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Selector<CartProvider, bool>(
//                                   builder: (context, data, child) {
//                                     return showCircularProgress(
//                                         data, colors.primary);
//                                   },
//                                   selector: (_, provider) =>
//                                   provider.isProgress,
//                                 ),
//                                 /*   showCircularProgress(
//                                               _isProgress, colors.primary),*/
//                               ],
//                             ),
//                           ),
//                           Container(
//                             color:
//                             Theme.of(context).colorScheme.white,
//                             child: Row(children: <Widget>[
//                               Padding(
//                                   padding: EdgeInsetsDirectional.only(
//                                       start: 15.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(CUR_CURRENCY! +
//                                           "${totalamount.toString()}" != " " ?
//                                       CUR_CURRENCY! +
//                                           "${totalamount.toString()}":"",
//                                         // CUR_CURRENCY! +
//                                         //     " ${oriPrice.toStringAsFixed(2)}",
//                                         style: TextStyle(
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .fontColor,
//                                             fontWeight:
//                                             FontWeight.bold),
//                                       ),
//
//                                       Text(
//                                           cartList.length.toString() +
//                                               " Items"),
//                                     ],
//                                   )),
//                               Spacer(),
//
//                               SimBtn(
//                                   size: 0.4,
//                                   title: getTranslated(
//                                       context, 'PLACE_ORDER'),
//                                   onBtnSelected: _placeOrder
//                                       ? () {
//                                     checkoutState!(() {
//                                       _placeOrder = false;
//                                     });
//                                     // if(
//                                     // cartList[0].sellerAvailable == false)
//                                       msg = getTranslated(
//                                           context,
//                                           'Seller');
//                                     if (selAddress == null ||
//                                         selAddress!.isEmpty) {
//                                       msg = getTranslated(
//                                           context,
//                                           'addressWarning');
//                                       Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (BuildContext
//                                             context) =>
//                                                 ManageAddress(
//                                                   home: false,
//                                                 ),
//                                           ));
//                                       checkoutState!(() {
//                                         _placeOrder = true;
//                                       });
//                                     } else if (payMethod ==
//                                         null ||
//                                         payMethod!.isEmpty) {
//                                       msg = getTranslated(
//                                           context,
//                                           'payWarning');
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (BuildContext
//                                               context) =>
//                                                   Payment(
//                                                       updateCheckout,
//                                                       msg)));
//                                       checkoutState!(() {
//                                         _placeOrder = true;
//                                       });
//                                     } else if (isTimeSlot! &&
//                                         int.parse(allowDay!) >
//                                             0 &&
//                                         (selDate == null ||
//                                             selDate!.isEmpty)) {
//                                       msg = getTranslated(
//                                           context,
//                                           'dateWarning');
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (BuildContext
//                                               context) =>
//                                                   Payment(
//                                                       updateCheckout,
//                                                       msg)));
//                                       checkoutState!(() {
//                                         _placeOrder = true;
//                                       });
//                                     } else if (isTimeSlot! &&
//                                         timeSlotList.length >
//                                             0 &&
//                                         (selTime == null ||
//                                             selTime!.isEmpty)) {
//                                       msg = getTranslated(
//                                           context,
//                                           'timeWarning');
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (BuildContext
//                                               context) =>
//                                                   Payment(
//                                                       updateCheckout,
//                                                       msg)));
//                                       checkoutState!(() {
//                                         _placeOrder = true;
//                                       });
//                                     } else if (double.parse(
//                                         MIN_ALLOW_CART_AMT!) >
//                                         oriPrice) {
//                                       setSnackbar(
//                                           getTranslated(context,
//                                               'MIN_CART_AMT')!,
//                                           _checkscaffoldKey);
//                                     }
//                                     // else if (!deliverable) {
//                                     //   checkDeliverable();
//                                     // }
//                                     else
//                                       confirmDialog();
//                                   }
//                                       : null)
//                               //}),
//                             ]),
//                           ),
//                         ],
//                       )
//                           : noInternet(context),
//                     ));
//               });
//         });
//   }
//
//   doPayment() {
//     if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
//       placeOrder('');
//     }
//     else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
//       razorpayPayment();
//     else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
//       paystackPayment(context);
//     else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
//       flutterwavePayment();
//     else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
//       stripePayment();
//     else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
//       paytmPayment();
//     /*  else if (payMethod ==
//                                                         getTranslated(
//                                                             context, 'GPAY')) {
//                                                       googlePayment(
//                                                           "google_pay");
//                                                     } else if (payMethod ==
//                                                         getTranslated(context,
//                                                             'APPLEPAY')) {
//                                                       googlePayment(
//                                                           "apple_pay");
//                                                     }*/
//
//     else if (payMethod == getTranslated(context, 'BANKTRAN'))
//       bankTransfer();
//     else
//       placeOrder('');
//   }
//
//   Future<void> _getAddress() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         var parameter = {
//           USER_ID: CUR_USERID,
//         };
//         Response response =
//         await post(getAddressApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//           // String msg = getdata["message"];
//           if (!error) {
//             var data = getdata["data"];
//
//             addressList = (data as List)
//                 .map((data) => new User.fromAddress(data))
//                 .toList();
//
//             if (addressList.length == 1) {
//               selectedAddress = 0;
//               selAddress = addressList[0].id;
//               // if (ISFLAT_DEL) {
//               //   if (totalPrice < double.parse(addressList[0].freeAmt!))
//               //     delCharge = double.parse(addressList[0].deliveryCharge!);
//               //   else
//               //     delCharge = 0;
//               // }
//             } else {
//               for (int i = 0; i < addressList.length; i++) {
//                 if (addressList[i].isDefault == "1") {
//                   selectedAddress = i;
//                   selAddress = addressList[i].id;
//                   // if (!ISFLAT_DEL) {
//                   //   // if (totalPrice < double.parse(addressList[i].freeAmt!))
//                   //     delCharge = double.parse(addressList[i].deliveryCharge!);
//                   //   else
//                   //     delCharge = 0;
//                   // }
//                 }
//               }
//             }
//
//             if (ISFLAT_DEL) {
//               if ((oriPrice) < double.parse(MIN_AMT!))
//                 delCharge = double.parse(CUR_DEL_CHR!);
//               else
//                 delCharge = 0;
//             }
//             totalPrice = totalPrice + delCharge;
//           } else {
//             if (ISFLAT_DEL) {
//               if ((oriPrice) < double.parse(MIN_AMT!))
//                 delCharge = double.parse(CUR_DEL_CHR!);
//               else
//                 delCharge = 0;
//             }
//             totalPrice = totalPrice + delCharge;
//           }
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//             });
//           }
//
//           if (checkoutState != null) checkoutState!(() {});
//         } else {
//           setSnackbar(
//               getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//           if (mounted)
//             setState(() {
//               _isLoading = false;
//             });
//         }
//       } on TimeoutException catch (_) {}
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     placeOrder(response.paymentId);
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     var getdata = json.decode(response.message!);
//     String errorMsg = getdata["error"]["description"];
//     setSnackbar(errorMsg, _checkscaffoldKey);
//
//     if (mounted)
//       checkoutState!(() {
//         _placeOrder = true;
//       });
//     context.read<CartProvider>().setProgress(false);
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {}
//
//   updateCheckout() {
//     if (mounted) checkoutState!(() {});
//   }
//
//   // razorpayPayment() async {
//   //   SettingProvider settingsProvider =
//   //   Provider.of<SettingProvider>(this.context, listen: false);
//   //
//   //   String? contact = settingsProvider.mobile;
//   //   String? email = settingsProvider.email;
//   //
//   //   String amt = ((totalPrice) * 100).toStringAsFixed(2);
//   //
//   //   if (contact != '' && email != '') {
//   //     context.read<CartProvider>().setProgress(true);
//   //
//   //     checkoutState!(() {});
//   //     var options = {
//   //       KEY: razorpayId,
//   //       AMOUNT: amt,
//   //       NAME: settingsProvider.userName,
//   //       'prefill': {CONTACT: contact, EMAIL: email},
//   //     };
//   //
//   //     try {
//   //       _razorpay!.open(options);
//   //     } catch (e) {
//   //       debugPrint(e.toString());
//   //     }
//   //   } else {
//   //     if (email == '')
//   //       setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
//   //     else if (contact == '')
//   //       setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
//   //   }
//   // }
//   razorpayPayment() async {
//
//     SettingProvider settingsProvider =
//     Provider.of<SettingProvider>(this.context, listen: false);
//     print("Payment Email ${settingsProvider.email}");
//     print("Payment Email ${settingsProvider.mobile}");
//
//     String? contact = settingsProvider.mobile;
//     // String? email = settingsProvider.email;
//
//     String amt = ((totalPrice) * 100).toStringAsFixed(2);
//
//     if (contact != '') {
//       context.read<CartProvider>().setProgress(true);
//
//       checkoutState!(() {});
//       var options = {
//         KEY: razorpayId,
//         AMOUNT: amt,
//         NAME: settingsProvider.userName,
//         'prefill': {CONTACT: contact},
//       };
//
//       try {
//         _razorpay!.open(options);
//       } catch (e) {
//         debugPrint(e.toString());
//       }
//     } else {
//       // if (email == '')
//       //   setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
//       if (contact == '')
//         setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
//     }
//   }
//
//   void paytmPayment() async {
//     String? paymentResponse;
//     context.read<CartProvider>().setProgress(true);
//
//     String orderId = DateTime.now().millisecondsSinceEpoch.toString();
//
//     String callBackUrl = (payTesting
//         ? 'https://securegw-stage.paytm.in'
//         : 'https://securegw.paytm.in') +
//         '/theia/paytmCallback?ORDER_ID=' +
//         orderId;
//
//     var parameter = {
//       AMOUNT: totalPrice.toString(),
//       USER_ID: CUR_USERID,
//       ORDER_ID: orderId
//     };
//
//     try {
//       final response = await post(
//         getPytmChecsumkApi,
//         body: parameter,
//         headers: headers,
//       );
//
//       var getdata = json.decode(response.body);
//
//       bool error = getdata["error"];
//
//       if (!error) {
//         String txnToken = getdata["txn_token"];
//
//         setState(() {
//           paymentResponse = txnToken;
//         });
//         // orderId, mId, txnToken, txnAmount, callback
//         print(
//             "para are $paytmMerId # $orderId # $txnToken # ${totalPrice.toString()} # $callBackUrl  $payTesting");
//         var paytmResponse = Paytm.payWithPaytm(
//             callBackUrl: callBackUrl,
//             mId: paytmMerId!,
//             orderId: orderId,
//             txnToken: txnToken,
//             txnAmount: totalPrice.toString(),
//             staging: payTesting);
//         paytmResponse.then((value) {
//           print("valie is $value");
//           value.forEach((key, value) {
//             print("key is $key");
//             print("value is $value");
//           });
//           context.read<CartProvider>().setProgress(false);
//
//           _placeOrder = true;
//           setState(() {});
//           checkoutState!(() {
//             if (value['error']) {
//               paymentResponse = value['errorMessage'];
//
//               if (value['response'] != null)
//                 addTransaction(value['response']['TXNID'], orderId,
//                     value['response']['STATUS'] ?? '', paymentResponse, false);
//             } else {
//               if (value['response'] != null) {
//                 paymentResponse = value['response']['STATUS'];
//                 if (paymentResponse == "TXN_SUCCESS")
//                   placeOrder(value['response']['TXNID']);
//                 else
//                   addTransaction(
//                       value['response']['TXNID'],
//                       orderId,
//                       value['response']['STATUS'],
//                       value['errorMessage'] ?? '',
//                       false);
//               }
//             }
//
//             setSnackbar(paymentResponse!, _checkscaffoldKey);
//           });
//         });
//       } else {
//         checkoutState!(() {
//           _placeOrder = true;
//         });
//
//
//         context.read<CartProvider>().setProgress(false);
//
//         setSnackbar(getdata["message"], _checkscaffoldKey);
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   Future<void> placeOrder(String? tranId) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       context.read<CartProvider>().setProgress(true);
//
//       SettingProvider settingsProvider =
//       Provider.of<SettingProvider>(this.context, listen: false);
//
//       String? mob = settingsProvider.mobile;
//
//       String? varientId, quantity;
//
//       List<SectionModel> cartList = context.read<CartProvider>().cartList;
//       for (SectionModel sec in cartList) {
//         varientId = varientId != null
//             ? varientId + "," + sec.varientId!
//             : sec.varientId;
//         quantity = quantity != null ? quantity + "," + sec.qty! : sec.qty;
//       }
//       String? payVia;
//       if (payMethod == getTranslated(context, 'COD_LBL'))
//         payVia = "COD";
//       else if (payMethod == getTranslated(context, 'PAYPAL_LBL'))
//         payVia = "PayPal";
//       else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL'))
//         payVia = "PayUMoney";
//       else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
//         payVia = "RazorPay";
//       else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
//         payVia = "Paystack";
//       else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
//         payVia = "Flutterwave";
//       else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
//         payVia = "Stripe";
//       else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
//         payVia = "Paytm";
//       else if (payMethod == "Wallet")
//         payVia = "Wallet";
//       else if (payMethod == getTranslated(context, 'BANKTRAN'))
//         payVia = "bank_transfer";
//       try {
//         var parameter = {
//           USER_ID: CUR_USERID,
//           MOBILE: mob,
//           PRODUCT_VARIENT_ID: varientId,
//           QUANTITY: quantity,
//           TOTAL: oriPrice.toString(),
//           FINAL_TOTAL: totalPrice.toString(),
//           DEL_CHARGE: delCharge.toString(),
//           // TAX_AMT: taxAmt.toString(),
//           TAX_PER: taxPer.toString(),
//
//           PAYMENT_METHOD: payVia,
//           ADD_ID: selAddress,
//           ISWALLETBALUSED: isUseWallet! ? "1" : "0",
//           WALLET_BAL_USED: usedBal.toString(),
//           ORDER_NOTE: noteC.text
//         };
//
//         if (isTimeSlot!) {
//           parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
//           parameter[DELIVERY_DATE] = selDate ?? '';
//         }
//         if (isPromoValid!) {
//           parameter[PROMOCODE] = promocode;
//           parameter[PROMO_DIS] = promoAmt.toString();
//         }
//
//         if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
//           parameter[ACTIVE_STATUS] = WAITING;
//         } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
//           if (tranId == "succeeded")
//             parameter[ACTIVE_STATUS] = PLACED;
//           else
//             parameter[ACTIVE_STATUS] = WAITING;
//         } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
//           parameter[ACTIVE_STATUS] = WAITING;
//         }
//         print(parameter.toString());
//         print("PLACE ORDER PARAMETER====" + parameter.toString());
//
//         Response response =
//         await post(placeOrderApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(placeOrderApi.toString());
//         print(parameter.toString());
//         _placeOrder = true;
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//           bool error = getdata["error"];
//           String? msg = getdata["message"];
//           if (!error) {
//             String orderId = getdata["order_id"].toString();
//             if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
//               addTransaction(tranId, orderId, SUCCESS, msg, true);
//             } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
//               paypalPayment(orderId);
//             } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
//               addTransaction(stripePayId, orderId,
//                   tranId == "succeeded" ? PLACED : WAITING, msg, true);
//             } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
//               addTransaction(tranId, orderId, SUCCESS, msg, true);
//             } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
//               addTransaction(tranId, orderId, SUCCESS, msg, true);
//             } else {
//               context.read<UserProvider>().setCartCount("0");
//
//               clearAll();
//
//               Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                       builder: (BuildContext context) => OrderSuccess()),
//                   ModalRoute.withName('/home'));
//             }
//           } else {
//             setSnackbar(msg!, _checkscaffoldKey);
//             context.read<CartProvider>().setProgress(false);
//           }
//         }
//       } on TimeoutException catch (_) {
//         if (mounted)
//           checkoutState!(() {
//             _placeOrder = true;
//           });
//         context.read<CartProvider>().setProgress(false);
//       }
//     } else {
//       if (mounted)
//         checkoutState!(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   Future<void> paypalPayment(String orderId) async {
//     try {
//       var parameter = {
//         USER_ID: CUR_USERID,
//         ORDER_ID: orderId,
//         AMOUNT: totalPrice.toString()
//       };
//       Response response =
//       await post(paypalTransactionApi, body: parameter, headers: headers)
//           .timeout(Duration(seconds: timeOut));
//
//       var getdata = json.decode(response.body);
//
//       bool error = getdata["error"];
//       String? msg = getdata["message"];
//       if (!error) {
//         String? data = getdata["data"];
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (BuildContext context) => PaypalWebview(
//                   url: data,
//                   from: "order",
//                   orderId: orderId,
//                 )));
//       } else {
//         setSnackbar(msg!, _checkscaffoldKey);
//       }
//       context.read<CartProvider>().setProgress(false);
//     } on TimeoutException catch (_) {
//       setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//     }
//   }
//
//   Future<void> addTransaction(String? tranId, String orderID, String? status,
//       String? msg, bool redirect) async {
//     try {
//       var parameter = {
//         USER_ID: CUR_USERID,
//         ORDER_ID: orderID,
//         TYPE: payMethod,
//         TXNID: tranId,
//         AMOUNT: totalPrice.toString(),
//         STATUS: status,
//         MSG: msg
//       };
//       Response response =
//       await post(addTransactionApi, body: parameter, headers: headers)
//           .timeout(Duration(seconds: timeOut));
//
//       var getdata = json.decode(response.body);
//
//       bool error = getdata["error"];
//       String? msg1 = getdata["message"];
//       if (!error) {
//         if (redirect) {
//           // CUR_CART_COUNT = "0";
//
//           context.read<UserProvider>().setCartCount("0");
//           clearAll();
//
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext context) => OrderSuccess()),
//               ModalRoute.withName('/home'));
//         }
//       } else {
//         setSnackbar(msg1!, _checkscaffoldKey);
//       }
//     } on TimeoutException catch (_) {
//       setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//     }
//   }
//
//   paystackPayment(BuildContext context) async {
//     context.read<CartProvider>().setProgress(true);
//
//     String? email = context.read<SettingProvider>().email;
//
//     Charge charge = Charge()
//       ..amount = totalPrice.toInt()
//       ..reference = _getReference()
//       ..email = email;
//
//     try {
//       CheckoutResponse response = await paystackPlugin.checkout(
//         context,
//         method: CheckoutMethod.card,
//         charge: charge,
//       );
//       if (response.status) {
//         placeOrder(response.reference);
//       } else {
//         setSnackbar(response.message, _checkscaffoldKey);
//         if (mounted)
//           setState(() {
//             _placeOrder = true;
//           });
//         context.read<CartProvider>().setProgress(false);
//       }
//     } catch (e) {
//       context.read<CartProvider>().setProgress(false);
//       rethrow;
//     }
//   }
//
//   String _getReference() {
//     String platform;
//     if (Platform.isIOS) {
//       platform = 'iOS';
//     } else {
//       platform = 'Android';
//     }
//
//     return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
//   }
//
//   stripePayment() async {
//     context.read<CartProvider>().setProgress(true);
//
//     var response = await StripeService.payWithNewCard(
//         amount: (totalPrice.toInt() * 100).toString(),
//         currency: stripeCurCode,
//         from: "order",
//         context: context);
//
//     if (response.message == "Transaction successful") {
//       placeOrder(response.status);
//     } else if (response.status == 'pending' || response.status == "captured") {
//       placeOrder(response.status);
//     } else {
//       if (mounted)
//         setState(() {
//           _placeOrder = true;
//         });
//
//       context.read<CartProvider>().setProgress(false);
//     }
//     setSnackbar(response.message!, _checkscaffoldKey);
//   }
//
//   address() {
//     return Card(
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.location_on),
//                 Padding(
//                     padding: const EdgeInsetsDirectional.only(start: 8.0),
//                     child: Text(
//                       getTranslated(context, 'SHIPPING_DETAIL') ?? '',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.fontColor),
//                     )),
//               ],
//             ),
//             Divider(),
//             addressList.length > 0
//                 ? Padding(
//               padding: const EdgeInsetsDirectional.only(start: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                           child:
//                           Text(addressList[selectedAddress!].name!)),
//                       InkWell(
//                         child: Padding(
//                           padding:
//                           const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Text(
//                             getTranslated(context, 'CHANGE')!,
//                             style: TextStyle(
//                               color: colors.primary,
//                             ),
//                           ),
//                         ),
//                         onTap: () async {
//                           await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (BuildContext context) =>
//                                       ManageAddress(
//                                         home: false,
//                                       )));
//
//                           checkoutState!(() {
//                             deliverable = false;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   Text(
//                     addressList[selectedAddress!].address! +
//                         ", " +
//                         // addressList[selectedAddress!].area! +
//                         ", " +
//                         addressList[selectedAddress!].city! +
//                         ", " +
//                         addressList[selectedAddress!].state! +
//                         ", " +
//                         addressList[selectedAddress!].country! +
//                         ", " +
//                         addressList[selectedAddress!].pincode!,
//                     style: Theme.of(context).textTheme.caption!.copyWith(
//                         color: Theme.of(context).colorScheme.lightBlack),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5.0),
//                     child: Row(
//                       children: [
//                         Text(
//                           addressList[selectedAddress!].mobile!,
//                           style: Theme.of(context)
//                               .textTheme
//                               .caption!
//                               .copyWith(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .lightBlack),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             )
//                 : Padding(
//               padding: const EdgeInsetsDirectional.only(start: 8.0),
//               child: GestureDetector(
//                 child: Text(
//                   getTranslated(context, 'ADDADDRESS')!,
//                   style: TextStyle(
//                     color: Theme.of(context).colorScheme.fontColor,
//                   ),
//                 ),
//                 onTap: () async {
//                   ScaffoldMessenger.of(context).removeCurrentSnackBar();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => AddAddress(
//                           update: false,
//                           index: addressList.length,
//                         )),
//                   );
//                   if (mounted) setState(() {});
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   payment() {
//     return Card(
//       elevation: 0,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(4),
//         onTap: () async {
//           ScaffoldMessenger.of(context).removeCurrentSnackBar();
//           msg = '';
//           await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext context) =>
//                       Payment(updateCheckout, msg)));
//           if (mounted) checkoutState!(() {});
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.payment),
//                   Padding(
//                     padding: const EdgeInsetsDirectional.only(start: 8.0),
//                     child: Text(
//                       //SELECT_PAYMENT,
//                       getTranslated(context, 'SELECT_PAYMENT')!,
//                       style: TextStyle(
//                           color: Theme.of(context).colorScheme.fontColor,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   )
//                 ],
//               ),
//               payMethod != null && payMethod != ''
//                   ? Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [Divider(), Text(payMethod!)],
//                 ),
//               )
//                   : Container(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   cartItems(List<SectionModel> cartList) {
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: cartList.length,
//       physics: NeverScrollableScrollPhysics(),
//       itemBuilder: (context, index) {
//         return cartItem(index, cartList);
//       },
//     );
//   }
//
//   orderSummary(List<SectionModel> cartList) {
//     return Card(
//         elevation: 0,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 getTranslated(context, 'ORDER_SUMMARY')! +
//                     " (" +
//                     cartList.length.toString() +
//                     " items)",
//                 style: TextStyle(
//                     color: Theme.of(context).colorScheme.fontColor,
//                     fontWeight: FontWeight.bold),
//               ),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     getTranslated(context, 'SUBTOTAL')!,
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.lightBlack2),
//                   ),
//                   Text(
//                     CUR_CURRENCY! + " " + oriPrice.toStringAsFixed(2),
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.fontColor,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     getTranslated(context, 'DELIVERY_CHARGE')!,
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.lightBlack2),
//                   ),
//                   Text(
//                     CUR_CURRENCY! + " " + dCharge.toStringAsFixed(2),
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.fontColor,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               ),
//               isPromoValid!
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.lightBlack2),
//                   ),
//                   Text(
//                     CUR_CURRENCY! + " " + promoAmt.toStringAsFixed(2),
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.fontColor,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               )
//                   : Container(),
//               isUseWallet!
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     getTranslated(context, 'WALLET_BAL')!,
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.lightBlack2),
//                   ),
//                   Text(
//                     CUR_CURRENCY! + " " + usedBal.toStringAsFixed(2),
//                     style: TextStyle(
//                         color: Theme.of(context).colorScheme.fontColor,
//                         fontWeight: FontWeight.bold),
//                   )
//                 ],
//               )
//                   : Container(),
//             ],
//           ),
//         ));
//   }
//
//   Future<void> validatePromo(bool check) async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//         if (check) {
//           if (this.mounted && checkoutState != null) checkoutState!(() {});
//         }
//         setState(() {});
//         var parameter = {
//           USER_ID: CUR_USERID,
//           PROMOCODE: promoC.text,
//           FINAL_TOTAL: oriPrice.toString()
//         };
//         Response response =
//         await post(validatePromoApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//           String? msg = getdata["message"];
//           if (!error) {
//             var data = getdata["data"][0];
//
//             totalPrice = double.parse(data["final_total"]) + delCharge;
//
//             promoAmt = double.parse(data["final_discount"]);
//             promocode = data["promo_code"];
//             isPromoValid = true;
//             setSnackbar(
//                 getTranslated(context, 'PROMO_SUCCESS')!, _checkscaffoldKey);
//           } else {
//             isPromoValid = false;
//             promoAmt = 0;
//             promocode = null;
//             promoC.clear();
//             var data = getdata["data"];
//
//             totalPrice = double.parse(data["final_total"]) + delCharge;
//
//             setSnackbar(msg!, _checkscaffoldKey);
//           }
//           if (isUseWallet!) {
//             remWalBal = 0;
//             payMethod = null;
//             usedBal = 0;
//             isUseWallet = false;
//             isPayLayShow = true;
//
//             selectedMethod = null;
//             context.read<CartProvider>().setProgress(false);
//             if (mounted && check) checkoutState!(() {});
//             setState(() {});
//           } else {
//             if (mounted && check) checkoutState!(() {});
//             setState(() {});
//             context.read<CartProvider>().setProgress(false);
//           }
//         }
//       } on TimeoutException catch (_) {
//         context.read<CartProvider>().setProgress(false);
//         if (mounted && check) checkoutState!(() {});
//         setState(() {});
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//       }
//     } else {
//       _isNetworkAvail = false;
//       if (mounted && check) checkoutState!(() {});
//       setState(() {});
//     }
//   }
//
//   Future<void> flutterwavePayment() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//
//         var parameter = {
//           AMOUNT: totalPrice.toString(),
//           USER_ID: CUR_USERID,
//         };
//         Response response =
//         await post(flutterwaveApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//
//         if (response.statusCode == 200) {
//           var getdata = json.decode(response.body);
//
//           bool error = getdata["error"];
//           String? msg = getdata["message"];
//           if (!error) {
//             var data = getdata["link"];
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (BuildContext context) => PaypalWebview(
//                       url: data,
//                       from: "order",
//                     )));
//           } else {
//             setSnackbar(msg!, _checkscaffoldKey);
//           }
//
//           context.read<CartProvider>().setProgress(false);
//         }
//       } on TimeoutException catch (_) {
//         context.read<CartProvider>().setProgress(false);
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//       }
//     } else {
//       if (mounted)
//         checkoutState!(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
//
//   void confirmDialog() {
//     showGeneralDialog(
//         barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
//         transitionBuilder: (context, a1, a2, widget) {
//           return Transform.scale(
//             scale: a1.value,
//             child: Opacity(
//                 opacity: a1.value,
//                 child: AlertDialog(
//                   contentPadding: const EdgeInsets.all(0),
//                   elevation: 2.0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5.0))),
//                   content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                             padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
//                             child: Text(
//                               getTranslated(context, 'CONFIRM_ORDER')!,
//                               style: Theme.of(this.context)
//                                   .textTheme
//                                   .subtitle1!
//                                   .copyWith(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .fontColor),
//                             )),
//                         Divider(
//                             color: Theme.of(context).colorScheme.lightBlack),
//                         Padding(
//                           padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     getTranslated(context, 'SUBTOTAL')!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack2),
//                                   ),
//                                   Text(
//                                     CUR_CURRENCY! +
//                                         " " +
//                                         oriPrice.toStringAsFixed(2),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     getTranslated(context, 'DELIVERY_CHARGE')!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack2),
//                                   ),
//                                   Text(
//                                     CUR_CURRENCY! +
//                                         " " +
//                                         dCharge.toStringAsFixed(2),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               ),
//                               isPromoValid!
//                                   ? Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     getTranslated(
//                                         context, 'PROMO_CODE_DIS_LBL')!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack2),
//                                   ),
//                                   Text(CUR_CURRENCY! + " " +
//                                         promoAmt.toStringAsFixed(2),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               )
//                                   : Container(),
//                               isUseWallet!
//                                   ? Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     getTranslated(context, 'WALLET_BAL')!,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .lightBlack2),
//                                   ),
//                                   Text(
//                                     CUR_CURRENCY! +
//                                         " " +
//                                         usedBal.toStringAsFixed(2),
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .subtitle2!
//                                         .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor,
//                                         fontWeight: FontWeight.bold),
//                                   )
//                                 ],
//                               )
//                                   : Container(),
//                               Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       getTranslated(context, 'TOTAL_PRICE')!,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .subtitle2!
//                                           .copyWith(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .lightBlack2),
//                                     ),
//                                     Text(
//                                       "$CUR_CURRENCY ${totalamount.toString()}",
//                                       //   "$CUR_CURRENCY  +${totalPrice.toStringAsFixed(2)}",
//                                       style: TextStyle(
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .fontColor,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                   padding: EdgeInsets.symmetric(vertical: 10),
//                                   /* decoration: BoxDecoration(
//                                     color: colors.primary.withOpacity(0.1),
//                                     borderRadius: BorderRadius.all(
//                                       Radius.circular(10),
//                                     ),
//                                   ),*/
//                                   child: TextField(
//                                     controller: noteC,
//                                     style:
//                                     Theme.of(context).textTheme.subtitle2,
//                                     decoration: InputDecoration(
//                                       contentPadding:
//                                       EdgeInsets.symmetric(horizontal: 10),
//                                       border: InputBorder.none,
//                                       filled: true,
//                                       fillColor:
//                                       colors.primary.withOpacity(0.1),
//                                       //isDense: true,
//                                       hintText: getTranslated(context, 'NOTE'),
//                                     ),
//                                   )),
//                             ],
//                           ),
//                         ),
//                       ]),
//                   actions: <Widget>[
//                     new TextButton(
//                         child: Text(getTranslated(context, 'CANCEL')!,
//                             style: TextStyle(
//                                 color: Theme.of(context).colorScheme.lightBlack,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold)),
//                         onPressed: () {
//                           checkoutState!(() {
//                             _placeOrder = true;
//                           });
//                           Navigator.pop(context);
//                         }),
//                     new TextButton(
//                         child: Text(getTranslated(context, 'DONE')!,
//                             style: TextStyle(
//                                 color: colors.primary,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold)),
//                         onPressed: () {
//                           Navigator.pop(context);
//
//                           doPayment();
//                         })
//                   ],
//                 )),
//           );
//         },
//         transitionDuration: Duration(milliseconds: 200),
//         barrierDismissible: false,
//         barrierLabel: '',
//         context: context,
//         pageBuilder: (context, animation1, animation2) {
//           return Container();
//         });
//   }
//
//   void bankTransfer() {
//     showGeneralDialog(
//         barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
//         transitionBuilder: (context, a1, a2, widget) {
//           return Transform.scale(
//             scale: a1.value,
//             child: Opacity(
//                 opacity: a1.value,
//                 child: AlertDialog(
//                   contentPadding: const EdgeInsets.all(0),
//                   elevation: 2.0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(5.0))),
//                   content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                             padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
//                             child: Text(
//                               getTranslated(context, 'BANKTRAN')!,
//                               style: Theme.of(this.context)
//                                   .textTheme
//                                   .subtitle1!
//                                   .copyWith(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .fontColor),
//                             )),
//                         Divider(
//                             color: Theme.of(context).colorScheme.lightBlack),
//                         Padding(
//                             padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
//                             child: Text(getTranslated(context, 'BANK_INS')!,
//                                 style: Theme.of(context).textTheme.caption)),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 20.0, vertical: 10),
//                           child: Text(
//                             getTranslated(context, 'ACC_DETAIL')!,
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .subtitle2!
//                                 .copyWith(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .fontColor),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           child: Text(
//                             getTranslated(context, 'ACCNAME')! +
//                                 " : " +
//                                 acName!,
//                             style: Theme.of(context).textTheme.subtitle2,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           child: Text(
//                             getTranslated(context, 'ACCNO')! + " : " + acNo!,
//                             style: Theme.of(context).textTheme.subtitle2,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           child: Text(
//                             getTranslated(context, 'BANKNAME')! +
//                                 " : " +
//                                 bankName!,
//                             style: Theme.of(context).textTheme.subtitle2,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           child: Text(
//                             getTranslated(context, 'BANKCODE')! +
//                                 " : " +
//                                 bankNo!,
//                             style: Theme.of(context).textTheme.subtitle2,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           child: Text(
//                             getTranslated(context, 'EXTRADETAIL')! +
//                                 " : " +
//                                 exDetails!,
//                             style: Theme.of(context).textTheme.subtitle2,
//                           ),
//                         )
//                       ]),
//                   actions: <Widget>[
//                     new TextButton(
//                         child: Text(getTranslated(context, 'CANCEL')!,
//                             style: TextStyle(
//                                 color: Theme.of(context).colorScheme.lightBlack,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold)),
//                         onPressed: () {
//                           checkoutState!(() {
//                             _placeOrder = true;
//                           });
//                           Navigator.pop(context);
//                         }),
//                     new TextButton(
//                         child: Text(getTranslated(context, 'DONE')!,
//                             style: TextStyle(
//                                 color: Theme.of(context).colorScheme.fontColor,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold)),
//                         onPressed: () {
//                           Navigator.pop(context);
//
//                           context.read<CartProvider>().setProgress(true);
//
//                           placeOrder('');
//                         })
//                   ],
//                 )),
//           );
//         },
//         transitionDuration: Duration(milliseconds: 200),
//         barrierDismissible: false,
//         barrierLabel: '',
//         context: context,
//         pageBuilder: (context, animation1, animation2) {
//           return Container();
//         });
//   }
//
//   Future<void> checkDeliverable() async {
//     _isNetworkAvail = await isNetworkAvailable();
//     if (_isNetworkAvail) {
//       try {
//         context.read<CartProvider>().setProgress(true);
//
//         var parameter = {
//           USER_ID: CUR_USERID,
//           ADD_ID: selAddress,
//         };
//         print(parameter.toString());
//
//         Response response =
//         await post(checkCartDelApi, body: parameter, headers: headers)
//             .timeout(Duration(seconds: timeOut));
//         print(checkCartDelApi.toString());
//
//         var getdata = json.decode(response.body);
//
//         bool error = getdata["error"];
//         String? msg = getdata["message"];
//         var data = getdata["data"];
//         context.read<CartProvider>().setProgress(false);
//
//         if (error) {
//           deliverableList = (data as List)
//               .map((data) => new Model.checkDeliverable(data))
//               .toList();
//
//           checkoutState!(() {
//             deliverable = false;
//             _placeOrder = true;
//           });
//
//           setSnackbar(msg!, _checkscaffoldKey);
//         } else {
//           deliverableList = (data as List)
//               .map((data) => new Model.checkDeliverable(data))
//               .toList();
//
//           checkoutState!(() {
//             deliverable = true;
//           });
//           confirmDialog();
//         }
//       } on TimeoutException catch (_) {
//         setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
//       }
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//   }
// }
//





import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Public%20Api/api.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/widgets.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:paytm/paytm.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Helper/Stripe_Service.dart';
import '../Model/Model.dart';
import '../Model/Section_Model.dart';
import '../Model/User.dart';
import 'Add_Address.dart';
import 'Manage_Address.dart';
import 'Order_Success.dart';
import 'Payment.dart';
import 'PaypalWebviewActivity.dart';

class Cart extends StatefulWidget {
  final bool fromBottom;

  const Cart({Key? key, required this.fromBottom}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateCart();
}

List<User> addressList = [];
//List<SectionModel> cartList = [];
List<Promo> promoList = [];
double totalPrice = 0, oriPrice = 0, delCharge = 0, taxPer = 0;
int? selectedAddress = 0;
String? selAddress, payMethod = '', selTime, selDate, promocode;
bool? isTimeSlot,
    isPromoValid = false,
    isUseWallet = false,
    isPayLayShow = true;
int? selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal = 0, usedBal = 0;
bool isAvailable = true;

String? razorpayId,
    paystackId,
    stripeId,
    stripeSecret,
    stripeMode = "test",
    stripeCurCode,
    stripePayId,
    paytmMerId,
    paytmMerKey;
bool payTesting = true;

/*String gpayEnv = "TEST",
    gpayCcode = "US",
    gpaycur = "USD",
    gpayMerId = "01234567890123456789",
    gpayMerName = "Example Merchant Name";*/

class StateCart extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
  new GlobalKey<ScaffoldMessengerState>();
  List<Model> deliverableList = [];
  bool _isCartLoad = true, _placeOrder = true;

  //HomePage? home;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  List<TextEditingController> _controller = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  List<SectionModel> saveLaterList = [];
  String? msg;
  String? sellerId;
  bool _isLoading = true;
  Razorpay? _razorpay;
  TextEditingController promoC = new TextEditingController();
  TextEditingController noteC = new TextEditingController();
  StateSetter? checkoutState;
  final paystackPlugin = PaystackPlugin();
  bool deliverable = false;
  bool saveLater = false, addCart = false;
  bool isOnOff = false;
  String? totalamount;

  //List<PaymentItem> _gpaytItems = [];
  //Pay _gpayClient;



  @override
  void initState() {
    super.initState();
    clearAll();

    _getCart("0");
    _getSaveLater("1");
    // _getAddress();

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

  Future<Null> _refresh() {
    if (mounted)
      setState(() {
        _isCartLoad = true;
      });
    clearAll();

    _getCart("0");
    return _getSaveLater("1");
  }

  clearAll() {
    totalPrice = 0;
    oriPrice = 0;

    taxPer = 0;
    delCharge = 0;
    addressList.clear();
    // cartList.clear();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      context.read<CartProvider>().setCartlist([]);
      context.read<CartProvider>().setProgress(false);
    });

    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    payMethod = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();

    if (_razorpay != null) _razorpay!.clear();
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
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
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          appBar: widget.fromBottom
              ? null
              : getSimpleAppBar(getTranslated(context, 'CART')!, context),
          body: _isNetworkAvail
              ? Stack(
            children: <Widget>[
              _showContent(context),
              Selector<CartProvider, bool>(
                builder: (context, data, child) {
                  return showCircularProgress(data, colors.primary);
                },
                selector: (_, provider) => provider.isProgress,
              ),
            ],
          )
              : noInternet(context)),
    );
  }

  Widget listItem(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    for (int i = 0;
    i < cartList[index].productList![0].prVarientList!.length;
    i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }
    String? offPer;
    double price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
    if (price == 0)
      price = double.parse(
          cartList[index].productList![0].prVarientList![selectedPos].price!);
    else {
      double off = (double.parse(cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!)) -
          price;
      offPer = (off *
          100 /
          double.parse(cartList[index]
              .productList![0]
              .prVarientList![selectedPos]
              .price!))
          .toStringAsFixed(2);
    }

    cartList[index].perItemPrice = price.toString();
    //print("qty************${cartList.contains("qty")}");
    print("cartList**avail****${cartList[index].productList![0].availability}");

    if (_controller.length < index + 1) {
      _controller.add(new TextEditingController());
    }
    if (cartList[index].productList![0].availability != "0") {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      _controller[index].text = cartList[index].qty!;
    }
    List att = [], val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    if (cartList[index].productList![0].availability == "0") {
      isAvailable = false;
    }
    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0.1,
              child: Row(
                children: <Widget>[
                  Hero(
                      tag: "$index${cartList[index].productList![0].id}",
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: Stack(children: [
                                Card(
                                  child: Container(
                                    width: 120,
                                    height: 100,
                                    child: FadeInImage(
                                      image: CachedNetworkImageProvider(
                                          cartList[index].productList![0].image!),
                                      height: 125.0,
                                      width: 110.0,
                                      fit: BoxFit.contain,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                          erroWidget(125),
                                      placeholder: placeHolder(125),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                    child: cartList[index]
                                        .productList![0]
                                        .availability ==
                                        "0"
                                        ? Container(
                                      height: 55,
                                      color: Colors.white70,
                                      // width: double.maxFinite,
                                      padding: EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                            color: Colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                        : Container()),
                              ])),
                          offPer != null
                              ? Container(
                            decoration: BoxDecoration(
                                color: colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                offPer + "%",
                                style: TextStyle(
                                    color: colors.whiteTemp,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9),
                              ),
                            ),
                            margin: EdgeInsets.all(5),
                          )
                              : Container()
                        ],
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 5.0),
                                  child: Text(
                                    cartList[index].productList![0].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 8.0, end: 8, bottom: 8),
                                  child: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                  ),
                                ),
                                onTap: () {
                                  print(index);
                                  print(cartList);
                                  print(selectedPos);
                                  if (context.read<CartProvider>().isProgress ==
                                      false)
                                    removeFromCart(index, true, cartList, false,
                                        selectedPos);
                                },
                              )
                            ],
                          ),
                          cartList[index]
                              .productList![0]
                              .prVarientList![selectedPos]
                              .attr_name !=
                              null &&
                              cartList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .attr_name!
                                  .isNotEmpty
                              ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: att.length,
                              itemBuilder: (context, index) {
                                return Row(children: [
                                  Flexible(
                                    child: Text(
                                      att[index].trim() + ":",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: 5.0),
                                    child: Text(
                                      val[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]);
                              })
                              : Container(),
                          Row(
                            children: <Widget>[
                              Text(
                                double.parse(cartList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .disPrice!) !=
                                    0
                                    ? CUR_CURRENCY! +
                                    "" +
                                    cartList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .price!
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0.7),
                              ),
                              Text(
                                " " + CUR_CURRENCY! + " " + price.toString(),
                                style: TextStyle(
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          cartList[index].productList![0].availability == "1" ||
                              cartList[index].productList![0].stockType ==
                                  "0"
                              ? Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.remove,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (context
                                          .read<CartProvider>()
                                          .isProgress ==
                                          false)
                                        removeFromCart(index, false,
                                            cartList, false, selectedPos);
                                    },
                                  ),
                                  Container(
                                    width: 26,
                                    height: 20,
                                    child: Stack(
                                      children: [
                                        TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor),
                                          controller: _controller[index],
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                        // PopupMenuButton<String>(
                                        //   tooltip: '',
                                        //   icon: const Icon(
                                        //     Icons.arrow_drop_down,
                                        //     size: 1,
                                        //   ),
                                        //   onSelected: (String value) {
                                        //     if (context
                                        //             .read<CartProvider>()
                                        //             .isProgress ==
                                        //         false)
                                        //       addToCart(
                                        //           index, value, cartList);
                                        //   },
                                        //   itemBuilder:
                                        //       (BuildContext context) {
                                        //     return cartList[index]
                                        //         .productList![0]
                                        //         .itemsCounter!
                                        //         .map<
                                        //                 PopupMenuItem<
                                        //                     String>>(
                                        //             (String value) {
                                        //       return new PopupMenuItem(
                                        //           child: new Text(value,
                                        //               style: TextStyle(
                                        //                   color: Theme.of(
                                        //                           context)
                                        //                       .colorScheme
                                        //                       .fontColor)),
                                        //           value: value);
                                        //     }).toList();
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  ), // ),

                                  GestureDetector(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.add,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      print("New QUUUUUUUUUUUU_______ ${cartList[index]
                                          .qty!}");
                                      if (context
                                          .read<CartProvider>()
                                          .isProgress ==
                                          false)
                                        addToCart(
                                            index,
                                            (int.parse(cartList[index]
                                                .qty!) +
                                                int.parse(cartList[
                                                index]
                                                    .productList![0]
                                                    .qtyStepSize!))
                                                .toString(),
                                            cartList);
                                    },
                                  )
                                ],
                              ),
                            ],
                          )
                              : Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                end: 0,
                bottom: -15,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.archive_rounded,
                        size: 20,
                      ),
                    ),
                    onTap: !saveLater &&
                        !context.read<CartProvider>().isProgress
                        ? () {
                      setState(() {
                        saveLater = true;
                      });
                      saveForLater(
                          cartList[index].productList![0].availability ==
                              "0"
                              ? cartList[index]
                              .productList![0]
                              .prVarientList![selectedPos]
                              .id!
                              : cartList[index].varientId,
                          "1",
                          cartList[index].productList![0].availability ==
                              "0"
                              ? "1"
                              : cartList[index].qty,
                          double.parse(cartList[index].perItemTotal!),
                          cartList[index],
                          false);
                    }
                        : null,
                  ),
                ))
          ],
        ));
  }

  Widget cartItem(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    for (int i = 0;
    i < cartList[index].productList![0].prVarientList!.length;
    i++) {
      if (cartList[index].varientId ==
          cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    }

    double price = double.parse(
        cartList[index].productList![0].prVarientList![selectedPos].disPrice!);
    if (price == 0)
      price = double.parse(
          cartList[index].productList![0].prVarientList![selectedPos].price!);

    cartList[index].perItemPrice = price.toString();
    cartList[index].perItemTotal =
        (price * double.parse(cartList[index].qty!)).toString();

    _controller[index].text = cartList[index].qty!;

    List att = [], val = [];
    if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
        null) {
      att = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .attr_name!
          .split(',');
      val = cartList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .varient_value!
          .split(',');
    }

    String? id, varId;
    bool? avail = false;
    if (deliverableList.length > 0) {
      id = cartList[index].id;
      varId = cartList[index].productList![0].prVarientList![selectedPos].id;

      for (int i = 0; i < deliverableList.length; i++) {
        if (id == deliverableList[i].prodId &&
            varId == deliverableList[i].varId) {
          avail = deliverableList[i].isDel;

          break;
        }
      }
    }

    return Card(
      elevation: 0.1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Hero(
                    tag: "$index${cartList[index].productList![0].id}",
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: FadeInImage(
                          image: CachedNetworkImageProvider(
                              cartList[index].productList![0].image!),
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(80),

                          // errorWidget: (context, url, e) => placeHolder(60),
                          placeholder: placeHolder(80),
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  cartList[index].productList![0].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   child: Padding(
                            //     padding: const EdgeInsetsDirectional.only(
                            //         start: 8.0, end: 8, bottom: 8),
                            //     child: Icon(
                            //       Icons.clear,
                            //       size: 13,
                            //       color:
                            //           Theme.of(context).colorScheme.fontColor,
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     if (context.read<CartProvider>().isProgress ==
                            //         false)
                            //       removeFromCartCheckout(index, true, cartList);
                            //   },
                            // )
                          ],
                        ),
                        cartList[index]
                            .productList![0]
                            .prVarientList![selectedPos]
                            .attr_name !=
                            null &&
                            cartList[index]
                                .productList![0]
                                .prVarientList![selectedPos]
                                .attr_name!
                                .isNotEmpty
                            ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: att.length,
                            itemBuilder: (context, index) {
                              return Row(children: [
                                Flexible(
                                  child: Text(
                                    att[index].trim() + ":",
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 5.0),
                                  child: Text(
                                    val[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ]);
                            })
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      double.parse(cartList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .disPrice!) !=
                                          0
                                          ? CUR_CURRENCY! +
                                          "" +
                                          cartList[index]
                                              .productList![0]
                                              .prVarientList![selectedPos]
                                              .price!
                                          : "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(
                                          decoration:
                                          TextDecoration.lineThrough,
                                          letterSpacing: 0.7),
                                    ),
                                  ),
                                  Text(
                                    " " +
                                        CUR_CURRENCY! +
                                        " " +
                                        price.toString(),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            cartList[index].productList![0].availability ==
                                "1" ||
                                cartList[index].productList![0].stockType ==
                                    "null"
                                ? Row(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    // GestureDetector(
                                    //   child: Card(
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(50),
                                    //     ),
                                    //     child: Padding(
                                    //       padding:
                                    //           const EdgeInsets.all(8.0),
                                    //       child: Icon(
                                    //         Icons.remove,
                                    //         size: 15,
                                    //       ),
                                    //     ),
                                    //   ),
                                    //   onTap: () {
                                    //     if (context
                                    //             .read<CartProvider>()
                                    //             .isProgress ==
                                    //         false)
                                    //       removeFromCartCheckout(
                                    //           index, false, cartList);
                                    //   },
                                    // ),
                                    Container(
                                      width: 26,
                                      height: 20,
                                      child: Stack(
                                        children: [
                                          TextField(
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor),
                                            controller:
                                            _controller[index],
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                          // PopupMenuButton<String>(
                                          //   tooltip: '',
                                          //   icon: const Icon(
                                          //     Icons.arrow_drop_down,
                                          //     size: 1,
                                          //   ),
                                          //   onSelected: (String value) {
                                          //     addToCartCheckout(
                                          //         index, value, cartList);
                                          //   },
                                          //   itemBuilder:
                                          //       (BuildContext context) {
                                          //     return cartList[index]
                                          //         .productList![0]
                                          //         .itemsCounter!
                                          //         .map<
                                          //                 PopupMenuItem<
                                          //                     String>>(
                                          //             (String value) {
                                          //       return new PopupMenuItem(
                                          //           child: new Text(
                                          //             value,
                                          //             style: TextStyle(
                                          //                 color: Theme.of(
                                          //                         context)
                                          //                     .colorScheme
                                          //                     .fontColor),
                                          //           ),
                                          //           value: value);
                                          //     }).toList();
                                          //   },
                                          // ),
                                        ],
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   child: Card(
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(50),
                                    //     ),
                                    //     child: Padding(
                                    //       padding:
                                    //           const EdgeInsets.all(8.0),
                                    //       child: Icon(
                                    //         Icons.add,
                                    //         size: 15,
                                    //       ),
                                    //     ),
                                    //   ),
                                    //   onTap: () {
                                    //     addToCartCheckout(
                                    //         index,
                                    //         (int.parse(cartList[index]
                                    //                     .qty!) +
                                    //                 int.parse(cartList[
                                    //                         index]
                                    //                     .productList![0]
                                    //                     .qtyStepSize!))
                                    //             .toString(),
                                    //         cartList);
                                    //   },
                                    // )
                                  ],
                                ),
                              ],
                            )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'SUBTOTAL')!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  CUR_CURRENCY! + " " + price.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  CUR_CURRENCY! + " " + cartList[index].perItemTotal!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TAXPER')!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  cartList[index].productList![0].tax! + "%",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TOTAL_LBL')!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                !avail! && deliverableList.length > 0
                    ? Text(
                  getTranslated(context, 'NOT_DEL')!,
                  style: TextStyle(color: colors.red),
                )
                    : Container(),
                Text(
                  CUR_CURRENCY! +
                      " " +
                      (double.parse(cartList[index].perItemTotal!))
                          .toStringAsFixed(2)
                          .toString(),
                  //+ " "+cartList[index].productList[0].taxrs,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontColor),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget saveLaterItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
    i < saveLaterList[index].productList![0].prVarientList!.length;
    i++) {
      if (saveLaterList[index].varientId ==
          saveLaterList[index].productList![0].prVarientList![i].id)
        selectedPos = i;
    }

    double price = double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .disPrice!);
    if (price == 0) {
      price = double.parse(saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!);
    }

    double off = (double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .price!) -
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .disPrice!))
        .toDouble();
    off = off *
        100 /
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .price!);

    saveLaterList[index].perItemPrice = price.toString();
    if (saveLaterList[index].productList![0].availability != "0") {
      saveLaterList[index].perItemTotal =
          (price * double.parse(saveLaterList[index].qty!)).toString();
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0.1,
              child: Row(
                children: <Widget>[
                  Hero(
                      tag: "$index${saveLaterList[index].productList![0].id}",
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: Stack(children: [
                                FadeInImage(
                                  image: CachedNetworkImageProvider(
                                      saveLaterList[index]
                                          .productList![0]
                                          .image!),
                                  height: 100.0,
                                  width: 100.0,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      erroWidget(100),
                                  placeholder: placeHolder(100),
                                ),
                                Positioned.fill(
                                    child: saveLaterList[index]
                                        .productList![0]
                                        .availability ==
                                        "0"
                                        ? Container(
                                      height: 55,
                                      color: Colors.white70,
                                      // width: double.maxFinite,
                                      padding: EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                            color: Colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                        : Container()),
                              ])),
                          (off != 0 || off != 0.0 || off != 0.00) &&
                              saveLaterList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .disPrice! !=
                                  "0"
                              ? Container(
                            decoration: BoxDecoration(
                                color: colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                off.toStringAsFixed(2) + "%",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9),
                              ),
                            ),
                            margin: EdgeInsets.all(5),
                          )
                              : Container()
                        ],
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 5.0),
                                  child: Text(
                                    saveLaterList[index].productList![0].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 8.0, end: 8, bottom: 8),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                  ),
                                ),
                                onTap: () {
                                  if (context.read<CartProvider>().isProgress ==
                                      false)
                                    removeFromCart(index, true, saveLaterList,
                                        true, selectedPos);
                                },
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                double.parse(saveLaterList[index]
                                    .productList![0]
                                    .prVarientList![selectedPos]
                                    .disPrice!) !=
                                    0
                                    ? CUR_CURRENCY! +
                                    "" +
                                    saveLaterList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .price!
                                    : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0.7),
                              ),
                              Text(
                                " " + CUR_CURRENCY! + " " + price.toString(),
                                style: TextStyle(
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            saveLaterList[index].productList![0].availability == "1" ||
                saveLaterList[index].productList![0].stockType == "null"
                ? Positioned(
                bottom: -15,
                right: 0,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shopping_cart,
                        size: 20,
                      ),
                    ),
                    onTap:
                    !addCart && !context.read<CartProvider>().isProgress
                        ? () {
                      setState(() {
                        addCart = true;
                      });
                      saveForLater(
                          saveLaterList[index].varientId,
                          "0",
                          saveLaterList[index].qty,
                          double.parse(
                              saveLaterList[index].perItemTotal!),
                          saveLaterList[index],
                          true);
                    }
                        : null,
                  ),
                ))
                : Container()
          ],
        ));
  }
  var dCharge;
  String? overallAmount;
  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        print(parameter.toString());
        Response response =
        await post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(getCartApi.toString());

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          setState(() {
            print("Cart nEW================> : $totalamount");
            totalamount = getdata['overall_amount'];
            print("Cart aMOUBT================> : $totalamount");
            //sellerId = data[0]["product_details"][0]["seller_id"];
          });
          // isOnOff = onOff;
          // var  onOff = await checkOnOff(sellerId);
          // setState(() {
          //   isOnOff = onOff;
          // });
          //print("is On off===========> : $onOff");
          // print("Seller Id-----------> $seller_id");
          print("Cart Data================> : $data");
          print("ssssssssssssssssssssssss$getdata['delivery_charge']");
          oriPrice = double.parse(getdata[SUB_TOTAL]);
          // delCharge =getdata['delivery_charge'].toString();

          double.parse(getdata['delivery_charge'].toString());
          dCharge = double.parse(getdata['delivery_charge'].toString());

          print(" charge here ${delCharge}");
          taxPer = double.parse(getdata[TAX_PER]);

          totalPrice = delCharge + oriPrice;
          List<SectionModel> cartList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
          // overallAmount = cartList[0].finalTotal;

          if (getdata.containsKey(PROMO_CODES)) {
            var promo = getdata[PROMO_CODES];
            promoList =
                (promo as List).map((e) => new Promo.fromJson(e)).toList();
          }

          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted)
          setState(() {
            _isCartLoad = false;
          });

        _getAddress();
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  promoSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 50),
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9),
                      child: ListView(shrinkWrap: true, children: <Widget>[
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Container(
                                margin: const EdgeInsetsDirectional.only(end: 20),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius:
                                    BorderRadiusDirectional.circular(10)),
                                child: TextField(
                                  controller: promoC,
                                  style: Theme.of(context).textTheme.subtitle2,
                                  decoration: InputDecoration(
                                    contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                    border: InputBorder.none,
                                    //isDense: true,
                                    hintText:
                                    getTranslated(context, 'PROMOCODE_LBL'),
                                  ),
                                )),
                            Positioned.directional(
                              textDirection: Directionality.of(context),
                              end: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (promoAmt != 0 && isPromoValid!)
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                      ),
                                      onTap: () {
                                        if (promoAmt != 0 && isPromoValid!) {
                                          if (mounted)
                                            setState(() {
                                              totalPrice =
                                                  totalPrice + promoAmt;
                                              promoC.text = '';
                                              isPromoValid = false;
                                              promoAmt = 0;
                                              promocode = '';
                                            });
                                        }
                                      },
                                    ),
                                  )
                                      : Container(),
                                  InkWell(
                                    child: Container(
                                        padding: EdgeInsets.all(11),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colors.primary,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color:
                                          Theme.of(context).colorScheme.white,
                                        )),
                                    onTap: () {
                                      if (promoC.text.trim().isEmpty)
                                        setSnackbar(
                                            getTranslated(context, 'ADD_PROMO')!,
                                            _checkscaffoldKey);
                                      else if (!isPromoValid!) {
                                        validatePromo(false);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Text(
                            getTranslated(context, 'Choose_PROMO') ?? '',
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                color: Theme.of(context).colorScheme.fontColor),
                          ),
                        ),
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: promoList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7.0),
                                          child: Image.network(
                                            promoList[index].image!,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.fill,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                erroWidget(
                                                  80,
                                                ),
                                          )),
                                    ),

                                    //errorWidget: (context, url, e) => placeHolder(width),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(promoList[index].msg ?? ""),
                                            Text(promoList[index].promoCode ?? ''),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(promoList[index].day ?? ''),
                                    SimBtn(
                                      size: 0.3,
                                      title: getTranslated(context, "APPLY"),
                                      onBtnSelected: () {
                                        promoC.text = promoList[index].promoCode!;
                                        if (!isPromoValid!) validatePromo(false);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ])),
                );
                //});
              });
        });
  }

  Future<Null> _getSaveLater(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save,};
        print(parameter.toString());
        Response response =
        await post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(getCartApi.toString());
        // print(getCartApi.toString());
        var getdata = json.decode(response.body);
        print(getCartApi.toString());
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          saveLaterList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();

          List<SectionModel> cartList = context.read<CartProvider>().cartList;
          for (int i = 0; i < cartList.length; i++)
            _controller.add(new TextEditingController());
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted) setState(() {});
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }

    return null;
  }

  Future<void> addToCart(
      int index, String qty, List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();

    //if (int.parse(qty) >= cartList[index].productList[0].minOrderQuntity) {
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar(
              "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };
        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          String qty = data['total_quantity'];
          //CUR_CART_COUNT = data['cart_count'];

          context.read<UserProvider>().setCartCount(data['cart_count']);
          cartList[index].qty = qty;

          oriPrice = double.parse(data['sub_total']);
          delCharge = double.parse(getdata['delivery_charge']);
          print(" charge here New----- ${delCharge}");

          _controller[index].text = qty;
          totalPrice = 0;

          var cart = getdata["cart"];
          List<SectionModel> uptcartList = (cart as List)
              .map((cart) => new SectionModel.fromCart(cart))
              .toList();
          context.read<CartProvider>().setCartlist(uptcartList);

          if (!ISFLAT_DEL) {
            if (addressList.length == 0) {
              delCharge = 0;
            } else {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress!].freeAmt!))
                delCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              else
                delCharge = 0;
            }
          } else {
            if (oriPrice < double.parse(MIN_AMT!))
              delCharge = double.parse(CUR_DEL_CHR!);
            else
              delCharge = 0;
          }
          totalPrice = delCharge + oriPrice;

          if (isPromoValid!) {
            validatePromo(false);
          } else if (isUseWallet!) {
            context.read<CartProvider>().setProgress(false);
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;

                selectedMethod = null;
              });
          } else {
            setState(() {});
            context.read<CartProvider>().setProgress(false);
          }
        } else {
          setSnackbar(msg!, _scaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    // } else
    // setSnackbar(
    //     "Minimum allowed quantity is ${cartList[index].productList[0].minOrderQuntity} ",
    //     _scaffoldKey);
  }

  Future<void> addToCartCheckout(
      int index, String qty, List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar(
              "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(manageCartApi.toString());
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            cartList[index].qty = qty;

            oriPrice = double.parse(data['sub_total']);
            _controller[index].text = qty;
            totalPrice = 0;

            if (!ISFLAT_DEL) {
              if ((oriPrice) <
                  double.parse(addressList[selectedAddress!].freeAmt!))
                delCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              else
                delCharge = 0;
            } else {
              if ((oriPrice) < double.parse(MIN_AMT!))
                delCharge = double.parse(CUR_DEL_CHR!);
              else
                delCharge = 0;
            }
            totalPrice = delCharge + oriPrice;

            if (isPromoValid!) {
              validatePromo(true);
            } else if (isUseWallet!) {
              if (mounted)
                checkoutState!(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isUseWallet = false;
                  isPayLayShow = true;

                  selectedMethod = null;
                });
              setState(() {});
            } else {
              context.read<CartProvider>().setProgress(false);
              setState(() {});
              checkoutState!(() {});
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
      setState(() {});
    }
  }

  saveForLater(String? id, String save, String? qty, double price,
      SectionModel curItem, bool fromSave) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save
        };

        print("param****save***********$parameter");

        Response response =
        await post(manageCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          // CUR_CART_COUNT = data['cart_count'];
          context.read<UserProvider>().setCartCount(data['cart_count']);
          if (save == "1") {
            setSnackbar("Saved For Later", _scaffoldKey);
            saveLaterList.add(curItem);
            //cartList.removeWhere((item) => item.varientId == id);
            context.read<CartProvider>().removeCartItem(id!);
            setState(() {
              saveLater = false;
            });
            oriPrice = oriPrice - price;
          } else {
            setSnackbar("Added To Cart", _scaffoldKey);
            // cartList.add(curItem);
            context.read<CartProvider>().addCartItem(curItem);
            saveLaterList.removeWhere((item) => item.varientId == id);
            setState(() {
              addCart = false;
            });
            oriPrice = oriPrice + price;
          }

          totalPrice = 0;

          if (!ISFLAT_DEL) {
            if (addressList.length > 0 &&
                (oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
              delCharge =
                  double.parse(addressList[selectedAddress!].deliveryCharge!);
            } else {
              delCharge = 0;
            }
          } else {
            if ((oriPrice) < double.parse(MIN_AMT!)) {
              delCharge = double.parse(CUR_DEL_CHR!);
            } else {
              delCharge = 0;
            }
          }
          totalPrice = delCharge + oriPrice;

          if (isPromoValid!) {
            validatePromo(false);
          } else if (isUseWallet!) {
            context.read<CartProvider>().setProgress(false);
            if (mounted)
              setState(() {
                remWalBal = 0;
                payMethod = null;
                usedBal = 0;
                isUseWallet = false;
                isPayLayShow = true;
              });
          } else {
            context.read<CartProvider>().setProgress(false);
            setState(() {});
          }
        } else {
          setSnackbar(msg!, _scaffoldKey);
        }

        context.read<CartProvider>().setProgress(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  removeFromCartCheckout(
      int index, bool remove, List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
          _checkscaffoldKey);
    } else {
      if (_isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);

          int? qty;
          if (remove)
            qty = 0;
          else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
                  _checkscaffoldKey);
            }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          Response response =
          await post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          if (response.statusCode == 200) {
            var getdata = json.decode(response.body);

            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String? qty = data['total_quantity'];
              // CUR_CART_COUNT = data['cart_count'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              if (qty == "0") remove = true;

              if (remove) {
                // cartList.removeWhere((item) => item.varientId == cartList[index].varientId);

                context
                    .read<CartProvider>()
                    .removeCartItem(cartList[index].varientId!);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);

              if (!ISFLAT_DEL) {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!))
                  delCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                else
                  delCharge = 0;
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!))
                  delCharge = double.parse(CUR_DEL_CHR!);
                else
                  delCharge = 0;
              }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice;

              if (isPromoValid!) {
                validatePromo(true);
              } else if (isUseWallet!) {
                if (mounted)
                  checkoutState!(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                  });
                context.read<CartProvider>().setProgress(false);
                setState(() {});
              } else {
                context.read<CartProvider>().setProgress(false);

                checkoutState!(() {});
                setState(() {});
              }
            } else {
              setSnackbar(msg!, _checkscaffoldKey);
              context.read<CartProvider>().setProgress(false);
            }
          }
        } on TimeoutException catch (_) {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } else {
        if (mounted)
          checkoutState!(() {
            _isNetworkAvail = false;
          });
        setState(() {});
      }
    }
  }

  removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
      int selPos) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
          _scaffoldKey);
    } else {
      if (_isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);

          int? qty;
          if (remove)
            qty = 0;
          else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
                  _checkscaffoldKey);
            }
          }
          String varId;
          if (cartList[index].productList![0].availability == "0") {
            varId = cartList[index].productList![0].prVarientList![selPos].id!;
          } else {
            varId = cartList[index].varientId!;
          }
          print("carient**********${cartList[index].varientId}");
          var parameter = {
            PRODUCT_VARIENT_ID: varId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          Response response =
          await post(manageCartApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          print(getdata);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            print("msg************$msg");
            var data = getdata["data"];
            setSnackbar("Deleted", _scaffoldKey);
            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            if (move == false) {
              if (qty == "0") remove = true;

              if (remove) {
                cartList.removeWhere(
                        (item) => item.varientId == cartList[index].varientId);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);
              if (!ISFLAT_DEL) {
                try {
                  if ((oriPrice) <
                      double.parse(addressList[selectedAddress!].freeAmt!))
                    delCharge = double.parse(
                        addressList[selectedAddress!].deliveryCharge!);
                  else
                    delCharge = 0;
                } catch (e) {
                  print(e);
                }
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!))
                  delCharge = double.parse(CUR_DEL_CHR!);
                else
                  delCharge = 0;
              }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice;
              if (isPromoValid!) {
                validatePromo(false);
              } else if (isUseWallet!) {
                context.read<CartProvider>().setProgress(false);
                if (mounted)
                  setState(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                  });
              } else {
                context.read<CartProvider>().setProgress(false);
                setState(() {});
              }
            } else {
              if (qty == "0") remove = true;

              if (remove) {
                cartList.removeWhere(
                        (item) => item.varientId == cartList[index].varientId);
              }
            }
          } else {
            print("msg111************$msg");
            setSnackbar(msg!, _scaffoldKey);
          }
          if (mounted) setState(() {});
          context.read<CartProvider>().setProgress(false);
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } else {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  setSnackbar(
      String msg, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      duration: Duration(seconds: 1),
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  _showContent(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;
    print("cart list************${cartList.length}");
    return _isCartLoad
        ? shimmer(context)
        : cartList.length == 0 && saveLaterList.length == 0
        ? cartEmpty()
        : Column(
      children: <Widget>[
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: RefreshIndicator(
                  color: colors.primary,
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: cartList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return listItem(index, cartList);
                          },
                        ),
                        saveLaterList.length > 0
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated(
                                context, 'SAVEFORLATER_BTN')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        )
                            : Container(),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: saveLaterList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return saveLaterItem(index);
                          },
                        ),
                      ],
                    ),
                  ))),
        ),
        Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: <
              Widget>[
            promoList.length > 0 && oriPrice > 0
                ? Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                        margin:
                        const EdgeInsetsDirectional.only(
                            end: 20),
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .white,
                            borderRadius:
                            BorderRadiusDirectional
                                .circular(10)),
                        child: TextField(
                          textDirection:
                          Directionality.of(context),
                          enabled: false,
                          controller: promoC,
                          readOnly: true,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2,
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(
                                horizontal: 10),
                            border: InputBorder.none,
                            //isDense: true,
                            hintText: getTranslated(
                                context, 'PROMOCODE_LBL') ??
                                '',
                          ),
                        )),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      end: 0,
                      child: Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.lightBlack,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context)
                                .colorScheme
                                .white,
                          )),
                    ),
                  ],
                ),
                onTap: promoSheet,
              ),
            )
                : Container(),
            Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                margin:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                //  width: deviceWidth! * 0.9,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslated(context, 'TOTAL_PRICE')!),
                        Text(
                          CUR_CURRENCY! +
                              " ${oriPrice.toStringAsFixed(2)}",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor),
                        ),
                      ],
                    ),
                    isPromoValid!
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(
                              context, 'PROMO_CODE_DIS_LBL')!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack2),
                        ),
                        Text(
                          CUR_CURRENCY! +
                              " " +
                              promoAmt.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack2),
                        )
                      ],
                    )
                        : Container(),
                  ],
                )),
            SimBtn(
                size: 0.9,
                title: getTranslated(context, 'PROCEED_CHECKOUT'),
                onBtnSelected: () async {
                  checkout(cartList);
                  // if(isOnOff == true){
                  //   if (oriPrice > 0) {
                  //     FocusScope.of(context).unfocus();
                  //     if (isAvailable) {
                  //       checkout(cartList);
                  //     } else {
                  //       setSnackbar(
                  //           getTranslated(
                  //               context, 'CART_OUT_OF_STOCK_MSG')!,
                  //           _scaffoldKey);
                  //     }
                  //     if (mounted) setState(() {});
                  //   } else
                  //     setSnackbar(getTranslated(context, 'ADD_ITEM')!,
                  //         _scaffoldKey);
                  // } else {
                  //   showToast("Currently Store is Off");
                  // }

                }),
          ]),
        ),
      ],
    );
  }

  cartEmpty() {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noCartImage(context),
          noCartText(context),
          noCartDec(context),
          shopNow()
        ]),
      ),
    );
  }

  getAllPromo() {}

  noCartImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/empty_cart.svg',
      fit: BoxFit.contain,
      color: colors.primary,
    );
  }

  noCartText(BuildContext context) {
    return Container(
        child: Text(getTranslated(context, 'NO_CART')!,
            style: Theme.of(context).textTheme.headline5!.copyWith(
                color: colors.primary, fontWeight: FontWeight.normal)));
  }

  noCartDec(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(getTranslated(context, 'CART_DESC')!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6!.copyWith(
            color: Theme.of(context).colorScheme.lightBlack2,
            fontWeight: FontWeight.normal,
          )),
    );
  }

  shopNow() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 28.0),
      child: CupertinoButton(
        child: Container(
            width: deviceWidth! * 0.7,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              color: colors.primary,
              // gradient: LinearGradient(
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomRight,
              //     colors: [colors.grad1Color, colors.grad2Color],
              //     stops: [0, 1]),
              borderRadius: new BorderRadius.all(const Radius.circular(50.0)),
            ),
            child: Text(getTranslated(context, 'SHOP_NOW')!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.white70))),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        },
      ),
    );
  }

  checkout(List<SectionModel> cartList) {
    print("nnnnnnnnnnnnnnnnnnnnn++++++${totalamount.toString()}");
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                checkoutState = setState;
                return Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      key: _checkscaffoldKey,
                      body: _isNetworkAvail
                          ? cartList.length == 0
                          ? cartEmpty()
                          : _isLoading
                          ? shimmer(context)
                          : Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        address(),
                                        payment(),
                                        cartItems(cartList),
                                        // promo(),
                                        orderSummary(cartList),
                                      ],
                                    ),
                                  ),
                                ),
                                Selector<CartProvider, bool>(
                                  builder: (context, data, child) {
                                    return showCircularProgress(
                                        data, colors.primary);
                                  },
                                  selector: (_, provider) =>
                                  provider.isProgress,
                                ),
                                /*   showCircularProgress(
                                              _isProgress, colors.primary),*/
                              ],
                            ),
                          ),
                          Container(
                            color:
                            Theme.of(context).colorScheme.white,
                            child: Row(children: <Widget>[
                              Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(CUR_CURRENCY! +
                                          "${totalamount.toString()}" != " " ?
                                      CUR_CURRENCY! +
                                          "${totalamount.toString()}":"",
                                        // CUR_CURRENCY! +
                                        //     " ${oriPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),

                                      Text(
                                          cartList.length.toString() +
                                              " Items"),
                                    ],
                                  )),
                              Spacer(),

                              SimBtn(
                                  size: 0.4,
                                  title: getTranslated(
                                      context, 'PLACE_ORDER'),
                                  onBtnSelected: _placeOrder
                                      ? () {
                                    checkoutState!(() {
                                      _placeOrder = false;
                                    });
                                    // if(
                                    // cartList[0].sellerAvailable == false)
                                      msg = getTranslated(
                                          context,
                                          'Seller');
                                    if (selAddress == null ||
                                        selAddress!.isEmpty) {
                                      msg = getTranslated(
                                          context,
                                          'addressWarning');
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext
                                            context) =>
                                                ManageAddress(
                                                  home: false,
                                                ),
                                          ));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                    } else if (payMethod ==
                                        null ||
                                        payMethod!.isEmpty) {
                                      msg = getTranslated(
                                          context,
                                          'payWarning');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                    } else if (isTimeSlot! &&
                                        int.parse(allowDay!) >
                                            0 &&
                                        (selDate == null ||
                                            selDate!.isEmpty)) {
                                      msg = getTranslated(
                                          context,
                                          'dateWarning');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                    } else if (isTimeSlot! &&
                                        timeSlotList.length >
                                            0 &&
                                        (selTime == null ||
                                            selTime!.isEmpty)) {
                                      msg = getTranslated(
                                          context,
                                          'timeWarning');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                    } else if (double.parse(
                                        MIN_ALLOW_CART_AMT!) >
                                        oriPrice) {
                                      setSnackbar(
                                          getTranslated(context,
                                              'MIN_CART_AMT')!,
                                          _checkscaffoldKey);
                                    }
                                    // else if (!deliverable) {
                                    //   checkDeliverable();
                                    // }
                                    else
                                      confirmDialog();
                                  }
                                      : null)
                              //}),
                            ]),
                          ),
                        ],
                      )
                          : noInternet(context),
                    ));
              });
        });
  }

  doPayment() {
    if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
      placeOrder('');
    }
    else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
      razorpayPayment();
    else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
      paystackPayment(context);
    else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
      flutterwavePayment();
    else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
      razorpayPayment();
      // stripePayment();
    else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
      paytmPayment();
    /*  else if (payMethod ==
                                                        getTranslated(
                                                            context, 'GPAY')) {
                                                      googlePayment(
                                                          "google_pay");
                                                    } else if (payMethod ==
                                                        getTranslated(context,
                                                            'APPLEPAY')) {
                                                      googlePayment(
                                                          "apple_pay");
                                                    }*/

    else if (payMethod == getTranslated(context, 'BANKTRAN'))
      bankTransfer();
    else
      placeOrder('');
  }

  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        Response response =
        await post(getAddressApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            addressList = (data as List)
                .map((data) => new User.fromAddress(data))
                .toList();

            if (addressList.length == 1) {
              selectedAddress = 0;
              selAddress = addressList[0].id;
              // if (ISFLAT_DEL) {
              //   if (totalPrice < double.parse(addressList[0].freeAmt!))
              //     delCharge = double.parse(addressList[0].deliveryCharge!);
              //   else
              //     delCharge = 0;
              // }
            } else {
              for (int i = 0; i < addressList.length; i++) {
                if (addressList[i].isDefault == "1") {
                  selectedAddress = i;
                  selAddress = addressList[i].id;
                  // if (!ISFLAT_DEL) {
                  //   // if (totalPrice < double.parse(addressList[i].freeAmt!))
                  //     delCharge = double.parse(addressList[i].deliveryCharge!);
                  //   else
                  //     delCharge = 0;
                  // }
                }
              }
            }

            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT!))
                delCharge = double.parse(CUR_DEL_CHR!);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          } else {
            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT!))
                delCharge = double.parse(CUR_DEL_CHR!);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          if (checkoutState != null) checkoutState!(() {});
        } else {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var getdata = json.decode(response.message!);
    String errorMsg = getdata["error"]["description"];
    setSnackbar(errorMsg, _checkscaffoldKey);

    if (mounted)
      checkoutState!(() {
        _placeOrder = true;
      });
    context.read<CartProvider>().setProgress(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  updateCheckout() {
    if (mounted) checkoutState!(() {});
  }

  // razorpayPayment() async {
  //   SettingProvider settingsProvider =
  //   Provider.of<SettingProvider>(this.context, listen: false);
  //
  //   String? contact = settingsProvider.mobile;
  //   String? email = settingsProvider.email;
  //
  //   String amt = ((totalPrice) * 100).toStringAsFixed(2);
  //
  //   if (contact != '' && email != '') {
  //     context.read<CartProvider>().setProgress(true);
  //
  //     checkoutState!(() {});
  //     var options = {
  //       KEY: razorpayId,
  //       AMOUNT: amt,
  //       NAME: settingsProvider.userName,
  //       'prefill': {CONTACT: contact, EMAIL: email},
  //     };
  //
  //     try {
  //       _razorpay!.open(options);
  //     } catch (e) {
  //       debugPrint(e.toString());
  //     }
  //   } else {
  //     if (email == '')
  //       setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
  //     else if (contact == '')
  //       setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
  //   }
  // }
  razorpayPayment() async {

    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(this.context, listen: false);
    print("Payment Email ${settingsProvider.email}");
    print("Payment Email ${settingsProvider.mobile}");

    String? contact = settingsProvider.mobile;
    // String? email = settingsProvider.email;

    String amt = ((totalPrice) * 100).toStringAsFixed(2);

    if (contact != '') {
      context.read<CartProvider>().setProgress(true);

      checkoutState!(() {});
      var options = {
        KEY: razorpayId,
        AMOUNT: amt,
        NAME: settingsProvider.userName,
        'prefill': {CONTACT: contact},
      };

      try {
        _razorpay!.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      // if (email == '')
      //   setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
      if (contact == '')
        setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
    }
  }

  void paytmPayment() async {
    String? paymentResponse;
    context.read<CartProvider>().setProgress(true);

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl = (payTesting
        ? 'https://securegw-stage.paytm.in'
        : 'https://securegw.paytm.in') +
        '/theia/paytmCallback?ORDER_ID=' +
        orderId;

    var parameter = {
      AMOUNT: totalPrice.toString(),
      USER_ID: CUR_USERID,
      ORDER_ID: orderId
    };

    try {
      final response = await post(
        getPytmChecsumkApi,
        body: parameter,
        headers: headers,
      );

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        String txnToken = getdata["txn_token"];

        setState(() {
          paymentResponse = txnToken;
        });
        // orderId, mId, txnToken, txnAmount, callback
        print(
            "para are $paytmMerId # $orderId # $txnToken # ${totalPrice.toString()} # $callBackUrl  $payTesting");
        var paytmResponse = Paytm.payWithPaytm(
            callBackUrl: callBackUrl,
            mId: paytmMerId!,
            orderId: orderId,
            txnToken: txnToken,
            txnAmount: totalPrice.toString(),
            staging: payTesting);
        paytmResponse.then((value) {
          print("valie is $value");
          value.forEach((key, value) {
            print("key is $key");
            print("value is $value");
          });
          context.read<CartProvider>().setProgress(false);

          _placeOrder = true;
          setState(() {});
          checkoutState!(() {
            if (value['error']) {
              paymentResponse = value['errorMessage'];

              if (value['response'] != null)
                addTransaction(value['response']['TXNID'], orderId,
                    value['response']['STATUS'] ?? '', paymentResponse, false);
            } else {
              if (value['response'] != null) {
                paymentResponse = value['response']['STATUS'];
                if (paymentResponse == "TXN_SUCCESS")
                  placeOrder(value['response']['TXNID']);
                else
                  addTransaction(
                      value['response']['TXNID'],
                      orderId,
                      value['response']['STATUS'],
                      value['errorMessage'] ?? '',
                      false);
              }
            }

            setSnackbar(paymentResponse!, _checkscaffoldKey);
          });
        });
      } else {
        checkoutState!(() {
          _placeOrder = true;
        });


        context.read<CartProvider>().setProgress(false);

        setSnackbar(getdata["message"], _checkscaffoldKey);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> placeOrder(String? tranId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);

      SettingProvider settingsProvider =
      Provider.of<SettingProvider>(this.context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId = varientId != null
            ? varientId + "," + sec.varientId!
            : sec.varientId;
        quantity = quantity != null ? quantity + "," + sec.qty! : sec.qty;
      }
      String? payVia;
      if (payMethod == getTranslated(context, 'COD_LBL'))
        payVia = "COD";
      else if (payMethod == getTranslated(context, 'PAYPAL_LBL'))
        payVia = "PayPal";
      else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL'))
        payVia = "PayUMoney";
      else if (payMethod == getTranslated(context, 'RAZORPAY_LBL'))
        payVia = "RazorPay";
      else if (payMethod == getTranslated(context, 'PAYSTACK_LBL'))
        payVia = "Paystack";
      else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL'))
        payVia = "Flutterwave";
      else if (payMethod == getTranslated(context, 'STRIPE_LBL'))
        payVia = "Stripe";
      else if (payMethod == getTranslated(context, 'PAYTM_LBL'))
        payVia = "Paytm";
      else if (payMethod == "Wallet")
        payVia = "Wallet";
      else if (payMethod == getTranslated(context, 'BANKTRAN'))
        payVia = "bank_transfer";
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          MOBILE: mob,
          PRODUCT_VARIENT_ID: varientId,
          QUANTITY: quantity,
          TOTAL: oriPrice.toString(),
          FINAL_TOTAL: totalPrice.toString(),
          DEL_CHARGE: delCharge.toString(),
          // TAX_AMT: taxAmt.toString(),
          TAX_PER: taxPer.toString(),

          PAYMENT_METHOD: payVia,
          ADD_ID: selAddress,
          ISWALLETBALUSED: isUseWallet! ? "1" : "0",
          WALLET_BAL_USED: usedBal.toString(),
          ORDER_NOTE: noteC.text
        };

        if (isTimeSlot!) {
          parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
          parameter[DELIVERY_DATE] = selDate ?? '';
        }
        if (isPromoValid!) {
          parameter[PROMOCODE] = promocode;
          parameter[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
          parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
          if (tranId == "succeeded")
            parameter[ACTIVE_STATUS] = PLACED;
          else
            parameter[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
          parameter[ACTIVE_STATUS] = WAITING;
        }
        print(parameter.toString());
        print("PLACE ORDER PARAMETER====" + parameter.toString());

        Response response =
        await post(placeOrderApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(placeOrderApi.toString());
        print(parameter.toString());
        _placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            String orderId = getdata["order_id"].toString();
            if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
              addTransaction(stripePayId, orderId,
                  tranId == "succeeded" ? PLACED : WAITING, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else {
              context.read<UserProvider>().setCartCount("0");

              clearAll();

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => OrderSuccess()),
                  ModalRoute.withName('/home'));
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted)
          checkoutState!(() {
            _placeOrder = true;
          });
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
        AMOUNT: totalPrice.toString()
      };
      Response response =
      await post(paypalTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        String? data = getdata["data"];
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaypalWebview(
                  url: data,
                  from: "order",
                  orderId: orderId,
                )));
      } else {
        setSnackbar(msg!, _checkscaffoldKey);
      }
      context.read<CartProvider>().setProgress(false);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };
      Response response =
      await post(addTransactionApi, body: parameter, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          // CUR_CART_COUNT = "0";

          context.read<UserProvider>().setCartCount("0");
          clearAll();

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => OrderSuccess()),
              ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1!, _checkscaffoldKey);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  paystackPayment(BuildContext context) async {
    context.read<CartProvider>().setProgress(true);

    String? email = context.read<SettingProvider>().email;

    Charge charge = Charge()
      ..amount = totalPrice.toInt()
      ..reference = _getReference()
      ..email = email;

    try {
      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        placeOrder(response.reference);
      } else {
        setSnackbar(response.message, _checkscaffoldKey);
        if (mounted)
          setState(() {
            _placeOrder = true;
          });
        context.read<CartProvider>().setProgress(false);
      }
    } catch (e) {
      context.read<CartProvider>().setProgress(false);
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // stripePayment() async {
  //   context.read<CartProvider>().setProgress(true);
  //
  //   var response = await StripeService.payWithNewCard(
  //       amount: (totalPrice.toInt() * 100).toString(),
  //       currency: stripeCurCode,
  //       from: "order",
  //       context: context);
  //
  //   if (response.message == "Transaction successful") {
  //     placeOrder(response.status);
  //   } else if (response.status == 'pending' || response.status == "captured") {
  //     placeOrder(response.status);
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _placeOrder = true;
  //       });
  //
  //     context.read<CartProvider>().setProgress(false);
  //   }
  //   setSnackbar(response.message!, _checkscaffoldKey);
  // }

  address() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on),
                Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      getTranslated(context, 'SHIPPING_DETAIL') ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.fontColor),
                    )),
              ],
            ),
            Divider(),
            addressList.length > 0
                ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child:
                          Text(addressList[selectedAddress!].name!)),
                      InkWell(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            getTranslated(context, 'CHANGE')!,
                            style: TextStyle(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ManageAddress(
                                        home: false,
                                      )));

                          checkoutState!(() {
                            deliverable = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    addressList[selectedAddress!].address! +
                        ", " +
                        // addressList[selectedAddress!].area! +
                        ", " +
                        addressList[selectedAddress!].city! +
                        ", " +
                        addressList[selectedAddress!].state! +
                        ", " +
                        addressList[selectedAddress!].country! +
                        ", " +
                        addressList[selectedAddress!].pincode!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                          addressList[selectedAddress!].mobile!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: GestureDetector(
                child: Text(
                  getTranslated(context, 'ADDADDRESS')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
                onTap: () async {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAddress(
                          update: false,
                          index: addressList.length,
                        )),
                  );
                  if (mounted) setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  payment() {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          msg = '';
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      Payment(updateCheckout, msg)));
          if (mounted) checkoutState!(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.payment),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      //SELECT_PAYMENT,
                      getTranslated(context, 'SELECT_PAYMENT')!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              payMethod != null && payMethod != ''
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Divider(), Text(payMethod!)],
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  cartItems(List<SectionModel> cartList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return cartItem(index, cartList);
      },
    );
  }

  orderSummary(List<SectionModel> cartList) {
    return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, 'ORDER_SUMMARY')! +
                    " (" +
                    cartList.length.toString() +
                    " items)",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'SUBTOTAL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + oriPrice.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'DELIVERY_CHARGE')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + dCharge.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              isPromoValid!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + promoAmt.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
              isUseWallet!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'WALLET_BAL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    CUR_CURRENCY! + " " + usedBal.toStringAsFixed(2),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
            ],
          ),
        ));
  }

  Future<void> validatePromo(bool check) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        if (check) {
          if (this.mounted && checkoutState != null) checkoutState!(() {});
        }
        setState(() {});
        var parameter = {
          USER_ID: CUR_USERID,
          PROMOCODE: promoC.text,
          FINAL_TOTAL: oriPrice.toString()
        };
        Response response =
        await post(validatePromoApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"][0];

            totalPrice = double.parse(data["final_total"]) + delCharge;

            promoAmt = double.parse(data["final_discount"]);
            promocode = data["promo_code"];
            isPromoValid = true;
            setSnackbar(
                getTranslated(context, 'PROMO_SUCCESS')!, _checkscaffoldKey);
          } else {
            isPromoValid = false;
            promoAmt = 0;
            promocode = null;
            promoC.clear();
            var data = getdata["data"];

            totalPrice = double.parse(data["final_total"]) + delCharge;

            setSnackbar(msg!, _checkscaffoldKey);
          }
          if (isUseWallet!) {
            remWalBal = 0;
            payMethod = null;
            usedBal = 0;
            isUseWallet = false;
            isPayLayShow = true;

            selectedMethod = null;
            context.read<CartProvider>().setProgress(false);
            if (mounted && check) checkoutState!(() {});
            setState(() {});
          } else {
            if (mounted && check) checkoutState!(() {});
            setState(() {});
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        if (mounted && check) checkoutState!(() {});
        setState(() {});
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      _isNetworkAvail = false;
      if (mounted && check) checkoutState!(() {});
      setState(() {});
    }
  }

  Future<void> flutterwavePayment() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          AMOUNT: totalPrice.toString(),
          USER_ID: CUR_USERID,
        };
        Response response =
        await post(flutterwaveApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["link"];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => PaypalWebview(
                      url: data,
                      from: "order",
                    )));
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
          }

          context.read<CartProvider>().setProgress(false);
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted)
        checkoutState!(() {
          _isNetworkAvail = false;
        });
    }
  }

  void confirmDialog() {
    showGeneralDialog(
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'CONFIRM_ORDER')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme.of(context).colorScheme.lightBlack),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'SUBTOTAL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        oriPrice.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'DELIVERY_CHARGE')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        dCharge.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              isPromoValid!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(
                                        context, 'PROMO_CODE_DIS_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        promoAmt.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              isUseWallet!
                                  ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'WALLET_BAL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        usedBal.toStringAsFixed(2),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                                  : Container(),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getTranslated(context, 'TOTAL_PRICE')!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack2),
                                    ),
                                    Text(
                                      "$CUR_CURRENCY ${totalamount.toString()}",
                                      //   "$CUR_CURRENCY  +${totalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  /* decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),*/
                                  child: TextField(
                                    controller: noteC,
                                    style:
                                    Theme.of(context).textTheme.subtitle2,
                                    decoration: InputDecoration(
                                      contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor:
                                      colors.primary.withOpacity(0.1),
                                      //isDense: true,
                                      hintText: getTranslated(context, 'NOTE'),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          checkoutState!(() {
                            _placeOrder = true;
                          });
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: colors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);

                          doPayment();
                        })
                  ],
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void bankTransfer() {
    showGeneralDialog(
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'BANKTRAN')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme.of(context).colorScheme.lightBlack),
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: Text(getTranslated(context, 'BANK_INS')!,
                                style: Theme.of(context).textTheme.caption)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Text(
                            getTranslated(context, 'ACC_DETAIL')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'ACCNAME')! +
                                " : " +
                                acName!,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'ACCNO')! + " : " + acNo!,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'BANKNAME')! +
                                " : " +
                                bankName!,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'BANKCODE')! +
                                " : " +
                                bankNo!,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            getTranslated(context, 'EXTRADETAIL')! +
                                " : " +
                                exDetails!,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        )
                      ]),
                  actions: <Widget>[
                    new TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          checkoutState!(() {
                            _placeOrder = true;
                          });
                          Navigator.pop(context);
                        }),
                    new TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);

                          context.read<CartProvider>().setProgress(true);

                          placeOrder('');
                        })
                  ],
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<void> checkDeliverable() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: selAddress,
        };
        print(parameter.toString());

        Response response =
        await post(checkCartDelApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));
        print(checkCartDelApi.toString());

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        var data = getdata["data"];
        context.read<CartProvider>().setProgress(false);

        if (error) {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          checkoutState!(() {
            deliverable = false;
            _placeOrder = true;
          });

          setSnackbar(msg!, _checkscaffoldKey);
        } else {
          deliverableList = (data as List)
              .map((data) => new Model.checkDeliverable(data))
              .toList();

          checkoutState!(() {
            deliverable = true;
          });
          confirmDialog();
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }
}

