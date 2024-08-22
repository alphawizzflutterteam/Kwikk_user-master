// import 'dart:async';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:eshop_multivendor/Helper/AppBtn.dart';
// import 'package:eshop_multivendor/Helper/Color.dart';
// import 'package:eshop_multivendor/Helper/Constant.dart';
// import 'package:eshop_multivendor/Helper/Session.dart';
// import 'package:eshop_multivendor/Helper/SimBtn.dart';
// import 'package:eshop_multivendor/Helper/String.dart';
// import 'package:eshop_multivendor/Model/Section_Model.dart';
// import 'package:eshop_multivendor/Provider/HomeProvider.dart';
// import 'package:eshop_multivendor/Provider/SettingProvider.dart';
// import 'package:eshop_multivendor/Provider/UserProvider.dart';
// import 'package:eshop_multivendor/Screen/Sale_Section.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import 'HomePage.dart';
// import 'ProductList.dart';
// import 'Product_Detail.dart';
//
// class Sale extends StatefulWidget {
//   const Sale({Key? key}) : super(key: key);
//
//   @override
//   _SaleState createState() => _SaleState();
// }
//
// class _SaleState extends State<Sale>
//     with AutomaticKeepAliveClientMixin<Sale>, TickerProviderStateMixin {
//   bool _isNetworkAvail = true;
//
//   final _controller = PageController();
//   late Animation buttonSqueezeanimation;
//   late AnimationController buttonController;
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//   List<Product> productList = [];
//   List<Product> tempList = [];
//   List<SectionModel> saleList = [];
//
//   List<int> disList = [5, 10, 20, 30, 40, 50, 70, 80];
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();
//   int curDis = 0;
//   bool _loading = true;
//   bool _productLoading = true;
//
//   //String? curPin;
//   bool _isFirstLoad = true;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     callApi();
//     buttonController = new AnimationController(
//         duration: new Duration(milliseconds: 2000), vsync: this);
//
//     buttonSqueezeanimation = new Tween(
//       begin: deviceWidth! * 0.7,
//       end: 50.0,
//     ).animate(new CurvedAnimation(
//       parent: buttonController,
//       curve: new Interval(
//         0.0,
//         0.150,
//       ),
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: _isNetworkAvail
//             ? RefreshIndicator(
//                 color: colors.primary,
//                 key: _refreshIndicatorKey,
//                 onRefresh: _refresh,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           getTranslated(context, 'CHOOSE_DIS')!,
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.fontColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                       discountRow(),
//                       // _catList(),
//                       // _slider(),
//                       _product(),
//                       _section(),
//                     ],
//                   ),
//                 ))
//             : noInternet(context));
//   }
//
//   Future<Null> _refresh() {
//     context.read<HomeProvider>().setCatLoading(true);
//     context.read<HomeProvider>().setSecLoading(true);
//     context.read<HomeProvider>().setSliderLoading(true);
//
//     return callApi();
//   }
//
//   _singleSection(int index) {
//     return saleList[index].productList!.length > 0
//         ? Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     _getHeading(saleList[index].title ?? "", index),
//                     _getSection(index),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         : Container();
//   }
//
//   _getHeading(String title, int index) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(right: 20.0),
//           child: Container(
//             padding: EdgeInsetsDirectional.only(
//               start: 10,
//               bottom: 3,
//               top: 3,
//             ),
//             child: Text(
//               title,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.fontColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         Padding(
//             padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(saleList[index].shortDesc ?? "",
//                       style: Theme.of(context).textTheme.subtitle2),
//                 ),
//                 InkWell(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       getTranslated(context, 'seeAll')!,
//                       style: Theme.of(context)
//                           .textTheme
//                           .caption!
//                           .copyWith(color: colors.primary),
//                     ),
//                   ),
//                   onTap: () {
//                     SectionModel model = saleList[index];
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Sale_Section(
//                           index: index,
//                           section_model: model,
//                           dis: disList[curDis],
//                           sectionList: saleList,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 /*    TextButton(
//                     style: TextButton.styleFrom(
//                         minimumSize: Size.zero, // <
//                         backgroundColor: (Theme.of(context).colorScheme.white)),
//                        // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
//                     child: Text(
//                       getTranslated(context, 'SHOP_NOW')!,
//                       style: Theme.of(context).textTheme.caption!.copyWith(
//                           color: Theme.of(context).colorScheme.fontColor, fontWeight: FontWeight.bold),
//                     ),
//                     onPressed: () {
//                       SectionModel model = sectionList[index];
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SectionList(
//                               index: index,
//                               section_model: model,
//                             ),
//                           ));
//                     }),*/
//               ],
//             )),
//       ],
//     );
//   }
//
//   _getSection(int i) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
//       child: GridView.count(
//           padding: EdgeInsetsDirectional.only(top: 5),
//           crossAxisCount: 3,
//           shrinkWrap: true,
//           childAspectRatio: 0.8,
//           physics: NeverScrollableScrollPhysics(),
//           children: List.generate(
//             saleList[i].productList!.length < 6
//                 ? saleList[i].productList!.length
//                 : 6,
//             (index) {
//               return sectionItem(i, index, index % 2 == 0 ? true : false);
//             },
//           )),
//     );
//   }
//
//   Widget productItem(int index, bool pad) {
//     if (productList.length > index) {
//       String? offPer;
//       double price =
//           double.parse(productList[index].prVarientList![0].disPrice!);
//       if (price == 0) {
//         price = double.parse(productList[index].prVarientList![0].price!);
//       } else {
//         double off =
//             double.parse(productList[index].prVarientList![0].price!) - price;
//         offPer = ((off * 100) /
//                 double.parse(productList[index].prVarientList![0].price!))
//             .toStringAsFixed(2);
//       }
//
//       double width = deviceWidth! * 0.5;
//
//       return Card(
//         elevation: 0.0,
//         margin: EdgeInsetsDirectional.only(bottom: 2, end: 2),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(4),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Expanded(
//                 child: Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     ClipRRect(
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(5),
//                             topRight: Radius.circular(5)),
//                         child: Hero(
//                           transitionOnUserGestures: true,
//                           tag: "$index${productList[index].id}",
//                           child: FadeInImage(
//                             fit: BoxFit.contain,
//                             fadeInDuration: Duration(milliseconds: 150),
//                             image: CachedNetworkImageProvider(
//                                 productList[index].image!),
//                             height: double.maxFinite,
//                             width: double.maxFinite,
//                             imageErrorBuilder: (context, error, stackTrace) =>
//                                 erroWidget(double.maxFinite),
//                             //fit: BoxFit.fill,
//                             placeholder: placeHolder(width),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//               Text(" " + CUR_CURRENCY! + " " + price.toString(),
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.fontColor,
//                       fontWeight: FontWeight.bold)),
//               Padding(
//                 padding: const EdgeInsetsDirectional.only(
//                     start: 5.0, bottom: 5, top: 3),
//                 child: double.parse(
//                             productList[index].prVarientList![0].disPrice!) !=
//                         0
//                     ? Row(
//                         children: <Widget>[
//                           Text(
//                             double.parse(productList[index]
//                                         .prVarientList![0]
//                                         .disPrice!) !=
//                                     0
//                                 ? CUR_CURRENCY! +
//                                     "" +
//                                     productList[index].prVarientList![0].price!
//                                 : "",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .overline!
//                                 .copyWith(
//                                     decoration: TextDecoration.lineThrough,
//                                     letterSpacing: 0),
//                           ),
//                           Flexible(
//                             child: Text(" | " + "-$offPer%",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .overline!
//                                     .copyWith(
//                                         color: colors.primary,
//                                         letterSpacing: 0)),
//                           ),
//                         ],
//                       )
//                     : Container(
//                         height: 5,
//                       ),
//               )
//             ],
//           ),
//           onTap: () {
//             Product model = productList[index];
//             Navigator.push(
//               context,
//               PageRouteBuilder(
//                   // transitionDuration: Duration(milliseconds: 150),
//                   pageBuilder: (_, __, ___) => ProductDetail(
//                       model: model, secPos: 0, index: index, list: false
//                       //  title: sectionList[secPos].title,
//                       )),
//             );
//           },
//         ),
//       );
//     } else
//       return Container();
//   }
//
//   Widget sectionItem(int secPos, int index, bool pad) {
//     if (saleList[secPos].productList!.length > index) {
//       String? offPer;
//       double price = double.parse(
//           saleList[secPos].productList![index].prVarientList![0].disPrice!);
//       if (price == 0) {
//         price = double.parse(
//             saleList[secPos].productList![index].prVarientList![0].price!);
//       } else {
//         double off = double.parse(
//                 saleList[secPos].productList![index].prVarientList![0].price!) -
//             price;
//         offPer = ((off * 100) /
//                 double.parse(saleList[secPos]
//                     .productList![index]
//                     .prVarientList![0]
//                     .price!))
//             .toStringAsFixed(2);
//       }
//
//       double width = deviceWidth! * 0.5;
//
//       return Card(
//         elevation: 0.0,
//         margin: EdgeInsetsDirectional.only(bottom: 2, end: 2),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(4),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Expanded(
//                 child: Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10.0),
//                       child: ClipRRect(
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(5),
//                               topRight: Radius.circular(5)),
//                           child: Hero(
//                             transitionOnUserGestures: true,
//                             tag:
//                                 "${saleList[secPos].productList![index].id}$secPos$index",
//                             child: FadeInImage(
//                               fit: BoxFit.contain,
//                               fadeInDuration: Duration(milliseconds: 150),
//                               image: CachedNetworkImageProvider(
//                                   saleList[secPos].productList![index].image!),
//                               height: double.maxFinite,
//                               width: double.maxFinite,
//                               imageErrorBuilder: (context, error, stackTrace) =>
//                                   erroWidget(double.maxFinite),
//                               //fit: BoxFit.fill,
//                               placeholder: placeHolder(width),
//                             ),
//                           )),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(" " + CUR_CURRENCY! + " " + price.toString(),
//                   style: TextStyle(
//                       color: Theme.of(context).colorScheme.fontColor,
//                       fontWeight: FontWeight.bold)),
//               Padding(
//                 padding: const EdgeInsetsDirectional.only(
//                     start: 5.0, bottom: 5, top: 3),
//                 child: double.parse(saleList[secPos]
//                             .productList![index]
//                             .prVarientList![0]
//                             .disPrice!) !=
//                         0
//                     ? Row(
//                         children: <Widget>[
//                           Text(
//                             double.parse(saleList[secPos]
//                                         .productList![index]
//                                         .prVarientList![0]
//                                         .disPrice!) !=
//                                     0
//                                 ? CUR_CURRENCY! +
//                                     "" +
//                                     saleList[secPos]
//                                         .productList![index]
//                                         .prVarientList![0]
//                                         .price!
//                                 : "",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .overline!
//                                 .copyWith(
//                                     decoration: TextDecoration.lineThrough,
//                                     letterSpacing: 0),
//                           ),
//                           Flexible(
//                             child: Text(" | " + "-$offPer%",
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .overline!
//                                     .copyWith(
//                                         color: colors.primary,
//                                         letterSpacing: 0)),
//                           ),
//                         ],
//                       )
//                     : Container(
//                         height: 5,
//                       ),
//               )
//             ],
//           ),
//           onTap: () {
//             Product model = saleList[secPos].productList![index];
//             Navigator.push(
//               context,
//               PageRouteBuilder(
//                   // transitionDuration: Duration(milliseconds: 150),
//                   pageBuilder: (_, __, ___) => ProductDetail(
//                       model: model, secPos: secPos, index: index, list: false
//                       //  title: sectionList[secPos].title,
//                       )),
//             );
//           },
//         ),
//       );
//     } else
//       return Container();
//   }
//
//   _section() {
//     return _loading
//         ? saleShimmer(6)
//         : ListView.builder(
//             padding: EdgeInsets.all(0),
//             itemCount: saleList.length,
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemBuilder: (context, index) {
//               return _singleSection(index);
//             },
//           );
//   }
//
//   saleShimmer(int length) {
//     return Container(
//         width: double.infinity,
//         child: Shimmer.fromColors(
//             baseColor: Theme.of(context).colorScheme.simmerBase,
//             highlightColor: Theme.of(context).colorScheme.simmerHigh,
//             child: GridView.count(
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 crossAxisCount: length == 4 ? 2 : 3,
//                 shrinkWrap: true,
//
//                 childAspectRatio: 1.0,
//                 physics: NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 10,
//                 crossAxisSpacing: 10,
//                 children: List.generate(
//                   length,
//                   (index) {
//                     return Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       color: Theme.of(context).colorScheme.white,
//                     );
//                   },
//                 ))));
//   }
//
//   _product() {
//     return _productLoading
//         ? saleShimmer(4)
//         : productList.length > 0
//             ? Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: GridView.count(
//                         padding: EdgeInsetsDirectional.only(top: 5),
//                         crossAxisCount: 2,
//                         shrinkWrap: true,
//                         childAspectRatio: 1.2,
//                         crossAxisSpacing: 10,
//
//                         mainAxisSpacing: 10,
//                         physics: NeverScrollableScrollPhysics(),
//                         children: List.generate(
//                           productList.length < 4 ? productList.length : 4,
//                           (index) {
//                             return productItem(
//                                 index, index % 2 == 0 ? true : false);
//                           },
//                         )),
//                   ),
//                   Container(
//                     color: Theme.of(context).colorScheme.white,
//                     child: ListTile(
//                       title: Text(
//                         getTranslated(context, 'seeAll')!,
//                         style: Theme.of(context)
//                             .textTheme
//                             .caption!
//                             .copyWith(color: colors.primary),
//                       ),
//                       trailing: Icon(
//                         Icons.keyboard_arrow_right,
//                         color: colors.primary,
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ProductList(
//                               name: getTranslated(context, 'OFFER'),
//                               id: '',
//                               tag: false,
//                               dis: disList[curDis],
//                               fromSeller: false,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : Container();
//   }
//
//   List<T> map<T>(List list, Function handler) {
//     List<T> result = [];
//     for (var i = 0; i < list.length; i++) {
//       result.add(handler(i, list[i]));
//     }
//
//     return result;
//   }
//
//   Future<Null> callApi() async {
//     UserProvider user = Provider.of<UserProvider>(context, listen: false);
//     SettingProvider setting =
//         Provider.of<SettingProvider>(context, listen: false);
//
//     user.setUserId(setting.userId);
//
//     bool avail = await isNetworkAvailable();
//     if (avail) {
//       //getSlider();
//       // getCat();
//       getProduct("0");
//       getSection();
//       //getOfferImages();
//     } else {
//       if (mounted)
//         setState(() {
//           _isNetworkAvail = false;
//         });
//     }
//     return null;
//   }
//
//   void getProduct(String top) {
//     Map parameter = {
//       LIMIT: perPage.toString(),
//       OFFSET: "0", //offset.toString(),
//       TOP_RETAED: top,
//       DISCOUNT: disList[curDis].toString()
//     };
//
//     if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
//
//     apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
//       bool error = getdata["error"];
//       String? msg = getdata["message"];
//       if (!error) {
//         total = int.parse(getdata["total"]);
//
//         if ((offset) < total) {
//           tempList.clear();
//
//           var data = getdata["data"];
//           tempList =
//               (data as List).map((data) => new Product.fromJson(data)).toList();
//
//           if (getdata.containsKey(TAG)) {
//             print("we are here");
//             List<String> tempList = List<String>.from(getdata[TAG]);
//             if (tempList != null && tempList.length > 0) tagList = tempList;
//           }
//
//           getAvailVarient();
//
//           //  offset = offset + perPage;
//         } else {
//           if (msg != "Products Not Found !") setSnackbar(msg!, context);
//         }
//       } else {
//         if (msg != "Products Not Found !") setSnackbar(msg!, context);
//       }
//
//       setState(() {
//         _productLoading = false;
//       });
//       // context.read<ProductListProvider>().setProductLoading(false);
//     }, onError: (error) {
//       setSnackbar(error.toString(), context);
//       setState(() {
//         _productLoading = false;
//       });
//       //context.read<ProductListProvider>().setProductLoading(false);
//     });
//   }
//
//   void getAvailVarient() {
//     for (int j = 0; j < tempList.length; j++) {
//       if (tempList[j].stockType == "2") {
//         for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
//           if (tempList[j].prVarientList![i].availability == "1") {
//             tempList[j].selVarient = i;
//
//             break;
//           }
//         }
//       }
//     }
//     productList.clear();
//     productList.addAll(tempList);
//   }
//
//   void getSection() {
//     Map parameter = {
//       PRODUCT_LIMIT: "6",
//       PRODUCT_OFFSET: "0",
//       DISCOUNT: disList[curDis].toString()
//     };
//
//     if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
//     String curPin = context.read<UserProvider>().curPincode;
//     if (curPin != '') parameter[ZIPCODE] = curPin;
//
//     apiBaseHelper.postAPICall(getSectionApi, {}).then((getdata) {
//       bool error = getdata["error"];
//       String? msg = getdata["message"];
//
//       saleList.clear();
//       if (!error) {
//         var data = getdata["data"];
//
//         saleList = (data as List)
//             .map((data) => new SectionModel.fromJson(data))
//             .toList();
//       } else {
//         if (curPin != '') context.read<UserProvider>().setPincode('');
//         setSnackbar(msg!, context);
//       }
//       setState(() {
//         _loading = false;
//       });
//     }, onError: (error) {
//       setSnackbar(error.toString(), context);
//       print("Error Msg ----========> $error");
//       setState(() {
//         _loading = false;
//       });
//     });
//   }
//
//   updateDailog() async {
//     await dialogAnimate(context,
//         StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(5.0))),
//         title: Text(getTranslated(context, 'UPDATE_APP')!),
//         content: Text(
//           getTranslated(context, 'UPDATE_AVAIL')!,
//           style: Theme.of(this.context)
//               .textTheme
//               .subtitle1!
//               .copyWith(color: Theme.of(context).colorScheme.fontColor),
//         ),
//         actions: <Widget>[
//           new TextButton(
//               child: Text(
//                 getTranslated(context, 'NO')!,
//                 style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
//                     color: Theme.of(context).colorScheme.lightBlack,
//                     fontWeight: FontWeight.bold),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               }),
//           new TextButton(
//               child: Text(
//                 getTranslated(context, 'YES')!,
//                 style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
//                     color: Theme.of(context).colorScheme.fontColor,
//                     fontWeight: FontWeight.bold),
//               ),
//               onPressed: () async {
//                 Navigator.of(context).pop(false);
//
//                 String _url = '';
//                 if (Platform.isAndroid) {
//                   _url = androidLink + packageName;
//                 } else if (Platform.isIOS) {
//                   _url = iosLink;
//                 }
//
//                 if (await canLaunch(_url)) {
//                   await launch(_url);
//                 } else {
//                   throw 'Could not launch $_url';
//                 }
//               })
//         ],
//       );
//     }));
//   }
//
//   Widget homeShimmer() {
//     return Container(
//       width: double.infinity,
//       child: Shimmer.fromColors(
//         baseColor: Theme.of(context).colorScheme.simmerBase,
//         highlightColor: Theme.of(context).colorScheme.simmerHigh,
//         child: SingleChildScrollView(
//             child: Column(
//           children: [
//             catLoading(),
//             sliderLoading(),
//             sectionLoading(),
//           ],
//         )),
//       ),
//     );
//   }
//
//   Widget sliderLoading() {
//     double width = deviceWidth!;
//     double height = width / 2;
//     return Shimmer.fromColors(
//         baseColor: Theme.of(context).colorScheme.simmerBase,
//         highlightColor: Theme.of(context).colorScheme.simmerHigh,
//         child: Container(
//           margin: EdgeInsets.symmetric(vertical: 10),
//           width: double.infinity,
//           height: height,
//           color: Theme.of(context).colorScheme.white,
//         ));
//   }
//
//   Widget deliverLoading() {
//     return Shimmer.fromColors(
//         baseColor: Theme.of(context).colorScheme.simmerBase,
//         highlightColor: Theme.of(context).colorScheme.simmerHigh,
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//           width: double.infinity,
//           height: 18.0,
//           color: Theme.of(context).colorScheme.white,
//         ));
//   }
//
//   Widget catLoading() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//                 children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//                     .map((_) => Container(
//                           margin: EdgeInsets.symmetric(horizontal: 10),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).colorScheme.white,
//                             shape: BoxShape.circle,
//                           ),
//                           width: 50.0,
//                           height: 50.0,
//                         ))
//                     .toList()),
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//           width: double.infinity,
//           height: 18.0,
//           color: Theme.of(context).colorScheme.white,
//         ),
//       ],
//     );
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
//               context.read<HomeProvider>().setCatLoading(true);
//               context.read<HomeProvider>().setSecLoading(true);
//               context.read<HomeProvider>().setSliderLoading(true);
//               _playAnimation();
//
//               Future.delayed(Duration(seconds: 2)).then((_) async {
//                 _isNetworkAvail = await isNetworkAvailable();
//                 if (_isNetworkAvail) {
//                   callApi();
//                 } else {
//                   await buttonController.reverse();
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
//   _deliverPincode() {
//     String curpin = context.read<UserProvider>().curPincode;
//     return GestureDetector(
//       child: Container(
//         // padding: EdgeInsets.symmetric(vertical: 8),
//         color: Theme.of(context).colorScheme.white,
//         child: ListTile(
//           dense: true,
//           minLeadingWidth: 10,
//           leading: Icon(
//             Icons.location_pin,
//           ),
//           title: Selector<UserProvider, String>(
//             builder: (context, data, child) {
//               return Text(
//                 data == ''
//                     ? getTranslated(context, 'SELOC')!
//                     : getTranslated(context, 'DELIVERTO')! + data,
//                 style:
//                     TextStyle(color: Theme.of(context).colorScheme.fontColor),
//               );
//             },
//             selector: (_, provider) => provider.curPincode,
//           ),
//           trailing: Icon(Icons.keyboard_arrow_right),
//         ),
//       ),
//       onTap: _pincodeCheck,
//     );
//   }
//
//   void _pincodeCheck() {
//     showModalBottomSheet<dynamic>(
//         context: context,
//         isScrollControlled: true,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(25), topRight: Radius.circular(25))),
//         builder: (builder) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//             return Container(
//               constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.9),
//               child: ListView(shrinkWrap: true, children: [
//                 Padding(
//                     padding: const EdgeInsets.only(
//                         left: 20.0, right: 20, bottom: 40, top: 30),
//                     child: Padding(
//                       padding: EdgeInsets.only(
//                           bottom: MediaQuery.of(context).viewInsets.bottom),
//                       child: Form(
//                           key: _formkey,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Align(
//                                 alignment: Alignment.topRight,
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Icon(Icons.close),
//                                 ),
//                               ),
//                               TextFormField(
//                                 keyboardType: TextInputType.text,
//                                 textCapitalization: TextCapitalization.words,
//                                 validator: (val) => validatePincode(val!,
//                                     getTranslated(context, 'PIN_REQUIRED')),
//                                 onSaved: (String? value) {
//                                   context
//                                       .read<UserProvider>()
//                                       .setPincode(value!);
//                                 },
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .subtitle2!
//                                     .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .fontColor),
//                                 decoration: InputDecoration(
//                                   isDense: true,
//                                   prefixIcon: Icon(Icons.location_on),
//                                   hintText:
//                                       getTranslated(context, 'PINCODEHINT_LBL'),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       margin:
//                                           EdgeInsetsDirectional.only(start: 20),
//                                       width: deviceWidth! * 0.35,
//                                       child: OutlinedButton(
//                                         onPressed: () {
//                                           context
//                                               .read<UserProvider>()
//                                               .setPincode('');
//
//                                           context
//                                               .read<HomeProvider>()
//                                               .setSecLoading(true);
//                                           getSection();
//                                           Navigator.pop(context);
//                                         },
//                                         child: Text(
//                                             getTranslated(context, 'All')!),
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     SimBtn(
//                                         size: 0.35,
//                                         title: getTranslated(context, 'APPLY'),
//                                         onBtnSelected: () async {
//                                           if (validateAndSave()) {
//                                             // validatePin(curPin);
//                                             context
//                                                 .read<HomeProvider>()
//                                                 .setSecLoading(true);
//                                             getSection();
//                                             Navigator.pop(context);
//                                           }
//                                         }),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           )),
//                     ))
//               ]),
//             );
//             //});
//           });
//         });
//   }
//
//   bool validateAndSave() {
//     final form = _formkey.currentState!;
//
//     form.save();
//     if (form.validate()) {
//       return true;
//     }
//     return false;
//   }
//
//   Future<Null> _playAnimation() async {
//     try {
//       await buttonController.forward();
//     } on TickerCanceled {}
//   }
//
//   sectionLoading() {
//     return Column(
//         children: [0, 1, 2, 3, 4]
//             .map((_) => Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: Container(
//                                 margin: EdgeInsets.only(bottom: 40),
//                                 decoration: BoxDecoration(
//                                     color: Theme.of(context).colorScheme.white,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(20),
//                                         topRight: Radius.circular(20)))),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               Container(
//                                 margin: EdgeInsets.symmetric(
//                                     horizontal: 20, vertical: 5),
//                                 width: double.infinity,
//                                 height: 18.0,
//                                 color: Theme.of(context).colorScheme.white,
//                               ),
//                               GridView.count(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   crossAxisCount: 2,
//                                   shrinkWrap: true,
//                                   childAspectRatio: 1.0,
//                                   physics: NeverScrollableScrollPhysics(),
//                                   mainAxisSpacing: 5,
//                                   crossAxisSpacing: 5,
//                                   children: List.generate(
//                                     4,
//                                     (index) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: double.infinity,
//                                         color:
//                                             Theme.of(context).colorScheme.white,
//                                       );
//                                     },
//                                   )),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     sliderLoading()
//                     //offerImages.length > index ? _getOfferImage(index) : Container(),
//                   ],
//                 ))
//             .toList());
//   }
//
//   discountRow() {
//     return Container(
//         height: 50,
//         color: Theme.of(context).colorScheme.white,
//         child: Center(
//           child: ListView.builder(
//             shrinkWrap: true,
//             scrollDirection: Axis.horizontal,
//             itemCount: disList.length,
//             itemBuilder: (context, index) {
//               return InkWell(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     curDis == index
//                         ? SvgPicture.asset(
//                             imagePath + 'tap.svg',
//                             color: colors.primary,
//                           )
//                         : Container(),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         disList[index].toString() + "%",
//                         style: TextStyle(
//                             color: curDis == index
//                                 ? colors.blackTemp
//                                 : Theme.of(context).colorScheme.fontColor),
//                       ),
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   setState(() {
//                     curDis = index;
//                     _loading = true;
//                     _productLoading = true;
//                   });
//                   getSection();
//                   getProduct("0");
//                 },
//               );
//             },
//           ),
//         ));
//   }
// }
