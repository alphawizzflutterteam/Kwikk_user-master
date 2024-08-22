import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

bool buildResult = false;

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int pos = 0;
  bool _isProgress = false;
  List<Product> productList = [];
  List<TextEditingController> _controllerList = [];
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  String query = "";
  int notificationoffset = 0;
  ScrollController? notificationcontroller;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  late AnimationController _animationController;
  Timer? _debounce;
  List<Product> history = [];
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  ChoiceChip? tagChip;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    productList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted)
          setState(() {
            query = "";
          });
      } else {
        query = _controller.text;
        notificationoffset = 0;
        notificationisnodata = false;
        buildResult = false;
        if (query.trim().length > 0) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (query.trim().length > 0) {
              notificationisloadmore = true;
              notificationoffset = 0;

              getProduct();
            }
          });
        }
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

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

  _transactionscrollListener() {
    if (notificationcontroller!.offset >=
            notificationcontroller!.position.maxScrollExtent &&
        !notificationcontroller!.position.outOfRange) {
      if (mounted)
        setState(() {
          getProduct();
        });
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    notificationcontroller!.dispose();
    _controller.dispose();
    for (int i = 0; i < _controllerList.length; i++)
      _controllerList[i].dispose();
    _animationController.dispose();
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
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(10),
              decoration: shadow(),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4.0),
                  child:
                      Icon(Icons.arrow_back_ios_rounded, color: colors.primary),
                ),
              ),
            );
          }),
          backgroundColor: Theme.of(context).colorScheme.white,
          title: TextField(
            controller: _controller,
            autofocus: true,
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
              hintText: getTranslated(context, 'SEARCH_LBL'),
              hintStyle: TextStyle(color: colors.primary.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.white),
              ),
            ),
            // onChanged: (query) => updateSearchQuery(query),
          ),
          titleSpacing: 0,
          actions: [
            // Container(
            //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            //   decoration: shadow(),
            //   child: Card(
            //     elevation: 0,
            //     child: InkWell(
            //       borderRadius: BorderRadius.circular(4),
            //       onTap: () {
            //         CUR_USERID == null
            //             ? Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => Login(),
            //                 ))
            //             : Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) =>
            //                       Cart(widget.updateHome, null),
            //                 )).then((val) => widget.updateHome);
            //       },
            //       child: new Stack(children: <Widget>[
            //         Center(
            //           child: Padding(
            //             padding: const EdgeInsets.all(5.0),
            //             child: SvgPicture.asset(
            //               'assets/images/noti_cart.svg',
            //             ),
            //           ),
            //         ),
            //         (CUR_CART_COUNT != null &&
            //                 CUR_CART_COUNT.isNotEmpty &&
            //                 CUR_CART_COUNT != "0")
            //             ? new Positioned(
            //                 top: 0.0,
            //                 right: 5.0,
            //                 bottom: 10,
            //                 child: Container(
            //                     decoration: BoxDecoration(
            //                         shape: BoxShape.circle,
            //                         color: colors.primary.withOpacity(0.5)),
            //                     child: new Center(
            //                       child: Padding(
            //                         padding: EdgeInsets.all(3),
            //                         child: new Text(
            //                           CUR_CART_COUNT,
            //                           style: TextStyle(
            //                               fontSize: 7,
            //                               fontWeight: FontWeight.bold),
            //                         ),
            //                       ),
            //                     )),
            //               )
            //             : Container()
            //       ]),
            //     ),
            //   ),
            // ),

            _controller.text != ""
                ? IconButton(
                    onPressed: () {
                      _controller.text = '';
                    },
                    icon: Icon(
                      Icons.close,
                      color: colors.primary,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.mic,
                      color: colors.primary,
                    ),
                    onPressed: () {
                      lastWords = '';
                      if (!_hasSpeech)
                        initSpeechState();
                      else
                        showSpeechDialog();
                    },
                  )
          ],
        ),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(),
                  showCircularProgress(_isProgress, colors.primary),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index) {
    Product model = productList[index];

    if (_controllerList.length < index + 1)
      _controllerList.add(new TextEditingController());

    _controllerList[index].text =
        model.prVarientList![model.selVarient!].cartCount!;

    double price =
        double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (price == 0)
      price = double.parse(model.prVarientList![model.selVarient!].price!);

    List att = [], val = [];
    if (model.prVarientList![model.selVarient!].attr_name != null) {
      att = model.prVarientList![model.selVarient!].attr_name!.split(',');
      val = model.prVarientList![model.selVarient!].varient_value!.split(',');
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                      tag: "$index${model.id}",
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                                productList[index].image!),
                            height: 80.0,
                            width: 80.0,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(80),

                            //errorWidget:(context, url,e) => placeHolder(80) ,
                            placeholder: placeHolder(80),
                          ))),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        price.toString() +
                                        " ",
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                                Text(
                                  double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY! +
                                          "" +
                                          model
                                              .prVarientList![model.selVarient!]
                                              .price!
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0),
                                ),
                              ],
                            ),
                            model.prVarientList![model.selVarient!].attr_name !=
                                        null &&
                                    model.prVarientList![model.selVarient!]
                                        .attr_name!.isNotEmpty
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
                                                        .lightBlack),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        )
                                      ]);
                                    })
                                : Container(),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: colors.primary,
                                      size: 12,
                                    ),
                                    Text(
                                      " " + productList[index].rating!,
                                      style:
                                          Theme.of(context).textTheme.overline,
                                    ),
                                    Text(
                                      " (" +
                                          productList[index].noOfRating! +
                                          ")",
                                      style:
                                          Theme.of(context).textTheme.overline,
                                    )
                                  ],
                                ),
                                Spacer(),
                                model.availability == "0"
                                    ? Container()
                                    : cartBtnList
                                        ? Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      margin:
                                                          EdgeInsetsDirectional
                                                              .only(end: 8),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 14,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .lightWhite,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          3))),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress ==
                                                              false &&
                                                          (int.parse(productList[
                                                                      index]
                                                                  .prVarientList![
                                                                      model
                                                                          .selVarient!]
                                                                  .cartCount!)) >
                                                              0)
                                                        removeFromCart(index);
                                                    },
                                                  ),
                                                  Container(
                                                    width: 40,
                                                    height: 20,
                                                    child: Stack(
                                                      children: [
                                                        TextField(
                                                          textAlign:
                                                              TextAlign.center,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                          ),
                                                          controller:
                                                              _controllerList[
                                                                  index],
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    5.0),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  width: 0.5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                            ),
                                                          ),
                                                        ),
                                                        // PopupMenuButton<String>(
                                                        //   tooltip: '',
                                                        //   icon: const Icon(
                                                        //     Icons
                                                        //         .arrow_drop_down,
                                                        //     size: 1,
                                                        //   ),
                                                        //   onSelected:
                                                        //       (String value) {
                                                        //     if (_isProgress ==
                                                        //         false)
                                                        //       addToCart(
                                                        //           index, value);
                                                        //   },
                                                        //   itemBuilder:
                                                        //       (BuildContext
                                                        //           context) {
                                                        //     return model
                                                        //         .itemsCounter!
                                                        //         .map<
                                                        //             PopupMenuItem<
                                                        //                 String>>((String
                                                        //             value) {
                                                        //       return new PopupMenuItem(
                                                        //           child:
                                                        //               new Text(
                                                        //                   value),
                                                        //           value: value);
                                                        //     }).toList();
                                                        //   },
                                                        // ),
                                                      ],
                                                    ),
                                                  ), // ),

                                                  GestureDetector(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      margin: EdgeInsets.only(
                                                          left: 8),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 14,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .fontColor,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .lightWhite,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          3))),
                                                    ),
                                                    onTap: () {
                                                      if (_isProgress == false)
                                                        addToCart(
                                                            index,
                                                            ((int.parse(model
                                                                        .prVarientList![model
                                                                            .selVarient!]
                                                                        .cartCount!)) +
                                                                    int.parse(model
                                                                        .qtyStepSize!))
                                                                .toString());
                                                    },
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        : Container(),
                              ],
                            ),
                          ],
                        )),
                  )
                ],
              ),
              productList[index].availability == "0"
                  ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold))
                  : Container(),
            ],
          ),
          splashColor: colors.primary.withOpacity(0.2),
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            Product model = productList[index];
            Navigator.push(
              context,
              PageRouteBuilder(
                  // transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        secPos: 0,
                        index: index,
                        list: true,
                      )),
            );
          },
        ),
      ),
    );
  }

  Future<void> addToCart(int index, String qty) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });

          if (int.parse(qty) < productList[index].minOrderQuntity!) {
            qty = productList[index].minOrderQuntity.toString();

            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty");
          }

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: productList[index]
                .prVarientList![productList[index].selVarient!]
                .id,
            QTY: qty
          };
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];
            userProvider.setCartCount(data['cart_count']);

            productList[index]
                .prVarientList![productList[index].selVarient!]
                .cartCount = qty.toString();
          } else {
            setSnackbar(msg!);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> removeFromCart(int index) async {
    Product model = productList[index];
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null)
        try {
          if (mounted)
            setState(() {
              _isProgress = true;
            });

          int qty;

          qty = (int.parse(productList[index]
                  .prVarientList![model.selVarient!]
                  .cartCount!) -
              int.parse(productList[index].qtyStepSize!));

          if (qty < productList[index].minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            String? qty = data["total_quantity"];
            //CUR_CART_COUNT = data['cart_count'];
            userProvider.setCartCount(data['cart_count']);
            model.prVarientList![model.selVarient!].cartCount = qty.toString();
          } else {
            setSnackbar(msg!);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!);
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void getAvailVarient(List<Product> tempList) {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    if (notificationoffset == 0) {
      productList = [];
    }

    if (notificationoffset == 0 && !buildResult) {
      Product element = Product(
          name: 'Search Result for "$query"',
          image: "",
          catName: "All Categories",
          history: false);
      productList.insert(0, element);
      for (int i = 0; i < history.length; i++) {
        if (history[i].name == query) productList.insert(0, history[i]);
      }
    }

    productList.addAll(tempList);

    notificationisloadmore = true;
    notificationoffset = notificationoffset + perPage;
  }

  Future getProduct() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (notificationisloadmore) {
          if (mounted)
            setState(() {
              notificationisloadmore = false;
              notificationisgettingdata = true;
            });

          var parameter = {
            SEARCH: query.trim(),
            LIMIT: perPage.toString(),
            OFFSET: notificationoffset.toString(),
          };
          print("parameter :  $parameter API name : $getProductApi");
          if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

          Response response =
              await post(getProductApi, headers: headers, body: parameter)
                  .timeout(Duration(seconds: timeOut));
          // print("serach***$parameter***${response.body.toString()}");
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];

          Map<String, dynamic> tempData = getdata;
          if (tempData.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          String? search = getdata['search'];

          notificationisgettingdata = false;
          if (notificationoffset == 0) notificationisnodata = error;

          if (!error && search!.trim() == query.trim()) {
            if (mounted) {
              new Future.delayed(
                  Duration.zero,
                  () => setState(() {
                        List mainlist = getdata['data'];

                        if (mainlist.length != 0) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(mainlist
                              .map((data) => new Product.fromJson(data))
                              .toList());

                          allitems.addAll(items);

                          getAvailVarient(allitems);
                        } else {
                          notificationisloadmore = false;
                        }
                      }));
            }
          } else {
            notificationisloadmore = false;
            if (mounted) setState(() {});
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted)
          setState(() {
            notificationisloadmore = false;
          });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
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

  clearAll() {
    setState(() {
      query = _controller.text;
      notificationoffset = 0;
      notificationisloadmore = true;
      productList.clear();
    });
  }

  _tags() {
    if (tagList != null) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList[i],
              style: TextStyle(
                  color: Theme.of(context).colorScheme.white, fontSize: 11)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (selected) if (mounted)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                      name: tagList[i],
                      fromSeller: false,
                      tag: true,
                    ),
                  ));
          },
        );

        chips.add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 2), child: tagChip));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          tagList.length > 0
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0),
                  child: Text('Discover more'),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              children: chips.map<Widget>((Widget chip) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: chip,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  _showContent() {
    if (_controller.text == "") {
      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      return FutureBuilder<List<String>>(
          future: settingsProvider.getPrefrenceList(HISTORYLIST),
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final entities = snapshot.data!;
              List<Product> itemList = [];
              for (int i = 0; i < entities.length; i++) {
                Product item = Product.history(entities[i]);
                itemList.add(item);
              }
              history.clear();
              history.addAll(itemList);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _SuggestionList(
                      textController: _controller,
                      suggestions: itemList,
                      notificationcontroller: notificationcontroller,
                      getProduct: getProduct,
                      clearAll: clearAll,
                    ),
                    _tags()
                  ],
                ),
              );
            } else {
              return Column();
            }
          });
    } else if (buildResult) {
      return notificationisnodata
          ? getNoItem(context)
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsetsDirectional.only(
                          bottom: 5, start: 10, end: 10, top: 12),
                      controller: notificationcontroller,
                      physics: BouncingScrollPhysics(),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        Product? item;
                        try {
                          item =
                              productList.isEmpty ? null : productList[index];
                          if (notificationisloadmore &&
                              index == (productList.length - 1) &&
                              notificationcontroller!.position.pixels <= 0) {
                            getProduct();
                          }
                        } on Exception catch (_) {}

                        return item == null ? Container() : listItem(index);
                      }),
                ),
                notificationisgettingdata
                    ? Padding(
                        padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
              ],
            );
    }
    return notificationisnodata
        ? getNoItem(context)
        : Column(
            children: <Widget>[
              Expanded(
                  child: _SuggestionList(
                textController: _controller,
                suggestions: productList,
                notificationcontroller: notificationcontroller,

                getProduct: getProduct,
                clearAll: clearAll,
                // onSelected: (String suggestion) {
                //   query = suggestion;
                // },
              )),
              notificationisgettingdata
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(top: 5, bottom: 5),
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ],
          );
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: Duration(milliseconds: 0));
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      // lastError = '${error.errorMsg} - ${error.permanent}';
      setSnackbar(error.errorMsg);
    });
  }

  void statusListener(String status) {
    setStater(() {
      lastStatus = '$status';
    });
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = '${result.recognizedWords}';
      query = lastWords;
    });

    if (result.finalResult) {
      Future.delayed(Duration(seconds: 1)).then((_) async {
        clearAll();

        _controller.text = lastWords;
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));

        setState(() {});
        Navigator.of(context).pop();
      });
    }
  }

  showSpeechDialog() {
    return dialogAnimate(context, StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
      setStater = setStater1;
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        title: Text(
          getTranslated(context, "SEarchHint")!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: .26,
                      spreadRadius: level * 1.5,
                      color:
                          Theme.of(context).colorScheme.black.withOpacity(.05))
                ],
                color: Theme.of(context).colorScheme.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    if (!_hasSpeech)
                      initSpeechState();
                    else
                      !_hasSpeech || speech.isListening
                          ? null
                          : startListening();
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(lastWords),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
              child: Center(
                child: speech.isListening
                    ? Text(
                        "I'm listening...",
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'Not listening',
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      );
    }));
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {this.suggestions,
      this.textController,
      this.searchDelegate,
      this.notificationcontroller,
      this.getProduct,
      this.clearAll});
  final List<Product>? suggestions;
  final TextEditingController? textController;

  final notificationcontroller;
  final SearchDelegate<Product>? searchDelegate;
  final Function? getProduct, clearAll;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationcontroller,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (BuildContext context, int i) {
        final Product suggestion = suggestions![i];

        return ListTile(
            title: Text(
              suggestion.name!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: textController!.text.toString().trim().isEmpty ||
                    suggestion.history!
                ? null
                : Text(
                    "In " + suggestion.catName!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor),
                  ),
            leading: textController!.text.toString().trim().isEmpty ||
                    suggestion.history!
                ? Icon(Icons.history)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: suggestion.image == ''
                        ? Image.asset(
                            'assets/images/placeholder.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : FadeInImage(
                            image:
                                CachedNetworkImageProvider(suggestion.image!),
                            fadeInDuration: Duration(milliseconds: 10),
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                            placeholder: placeHolder(50),
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(50),
                          )),
            trailing: Icon(
              Icons.reply,
            ),
            onTap: () async {
              if (suggestion.name!.startsWith('Search Result for ')) {
                SettingProvider settingsProvider =
                    Provider.of<SettingProvider>(context, listen: false);

                settingsProvider.setPrefrenceList(
                    HISTORYLIST, textController!.text.toString().trim());

                buildResult = true;
                clearAll!();
                getProduct!();
              } else if (suggestion.history!) {
                clearAll!();

                buildResult = true;
                textController!.text = suggestion.name!;
                textController!.selection = TextSelection.fromPosition(
                    TextPosition(offset: textController!.text.length));
              } else {
                SettingProvider settingsProvider =
                    Provider.of<SettingProvider>(context, listen: false);

                settingsProvider.setPrefrenceList(
                    HISTORYLIST, textController!.text.toString().trim());
                buildResult = false;
                Product model = suggestion;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                      // transitionDuration: Duration(seconds: 1),
                      pageBuilder: (_, __, ___) => ProductDetail(
                            model: model,
                            secPos: 0,
                            index: i,
                            list: true,
                          )),
                );
              }
            });
      },
    );
  }
}
