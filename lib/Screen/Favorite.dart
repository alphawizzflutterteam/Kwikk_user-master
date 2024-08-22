import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'Login.dart';
import 'Product_Detail.dart';

class Favorite extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateFav();
}

class StateFav extends State<Favorite> with TickerProviderStateMixin {
  // ScrollController controller = new ScrollController();
  //List<Product> tempList = [];

  //String? msg;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _isProgress = false, _isFavLoading = true;

  @override
  void initState() {
    super.initState();

    _getFav();

    //controller.addListener(_scrollListener);
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
                  _getFav();
                } else {
                  await buttonController!.reverse();
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
        appBar: getAppBar(getTranslated(context, 'FAVORITE')!, context),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(context),
                  showCircularProgress(_isProgress, colors.primary),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index, List<Product> favList) {
    if (index < favList.length && favList.length > 0) {
      // int selectedPos = 0;
      /*   for (int i = 0;
          i < favList[index].prVarientList!.length;
          i++) {
        if (favList[index].varientId ==
            favList[index].prVarientList![i].id)
          selectedPos = i;
      }
*/
      double price = double.parse(favList[index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(favList[index].prVarientList![0].price!);
      }

      double off = 0;
      if (favList[index].prVarientList![favList[index].selVarient!].disPrice! !=
          "0") {
        off = (double.parse(favList[index]
                    .prVarientList![favList[index].selVarient!]
                    .price!) -
                double.parse(favList[index]
                    .prVarientList![favList[index].selVarient!]
                    .disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(favList[index]
                .prVarientList![favList[index].selVarient!]
                .price!);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0.1,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Hero(
                        tag: "$index${favList[index].id}",
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                            child: Stack(
                              children: [
                                FadeInImage(
                                  image: CachedNetworkImageProvider(
                                      favList[index].image!),
                                  height: 125.0,
                                  width: 110.0,
                                  fit: BoxFit.cover,

                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                          erroWidget(125),

                                  // errorWidget: (context, url, e) => placeHolder(80),
                                  placeholder: placeHolder(125),
                                ),
                                Positioned.fill(
                                    child: favList[index].availability == "0"
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
                                off != 0
                                    ? Container(
                                        decoration: BoxDecoration(
                                            color: colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            off.toStringAsFixed(2) + "%",
                                            style: TextStyle(
                                                color: colors.whiteTemp,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9),
                                          ),
                                        ),
                                        margin: EdgeInsets.all(5),
                                      )
                                    : Container(),
                              ],
                            ))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    favList[index].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 5),
                                  child: InkWell(
                                    child: Icon(
                                      Icons.close,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                                    onTap: () {
                                      _removeFav(index, favList, context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            favList[index].noOfRating! != "0"
                                ? Row(
                                    children: [
                                      RatingBarIndicator(
                                        rating: double.parse(
                                            favList[index].rating!),
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star_rate_rounded,
                                          color: Colors.amber,
                                          //color: colors.primary,
                                        ),
                                        unratedColor:
                                            Colors.grey.withOpacity(0.5),
                                        itemCount: 5,
                                        itemSize: 18.0,
                                        direction: Axis.horizontal,
                                      ),
                                      Text(
                                        " (" + favList[index].noOfRating! + ")",
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline,
                                      )
                                    ],
                                  )
                                : Container(),
                            Row(
                              children: <Widget>[
                                Text(
                                  CUR_CURRENCY! + " " + price.toString() + " ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  double.parse(favList[index]
                                              .prVarientList![0]
                                              .disPrice!) !=
                                          0
                                      ? CUR_CURRENCY! +
                                          "" +
                                          favList[index]
                                              .prVarientList![0]
                                              .price!
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          letterSpacing: 0.7),
                                ),
                              ],
                            ),
                            /*  Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 20,
                                    child: PopupMenuButton(
                                      padding: EdgeInsets.zero,
                                      onSelected: (dynamic result) async {
                                        if (result == 0) {
                                          _removeFav(index, favList, context);
                                        }
                                        if (result == 1) {
                                          addToCart(index, favList, context);
                                        }
                                        if (result == 2) {}
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: 0,
                                          child: ListTile(
                                            dense: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.only(
                                                    start: 0.0, end: 0.0),
                                            leading: Icon(
                                              Icons.close,
                                              color: Theme.of(context).colorScheme.fontColor,
                                              size: 20,
                                            ),
                                            title: Text('Remove'),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: ListTile(
                                            dense: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.only(
                                                    start: 0.0, end: 0.0),
                                            leading: Icon(Icons.shopping_cart,
                                                color: Theme.of(context).colorScheme.fontColor,
                                                size: 20),
                                            title: Text('Add to Cart'),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: ListTile(
                                            dense: true,
                                            contentPadding:
                                                EdgeInsetsDirectional.only(
                                                    start: 0.0, end: 0.0),
                                            leading: Icon(
                                                Icons.share_outlined,
                                                color: Theme.of(context).colorScheme.fontColor,
                                                size: 20),
                                            title: Text('Share'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                splashColor: colors.primary.withOpacity(0.2),
                onTap: () {
                  Product model = favList[index];
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                              model: model,

                              secPos: 0,
                              index: index,
                              list: true,
                              //  title: productList[index].name,
                            )),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -15,
              right: 0,
              child: InkWell(
                onTap: () {
                  if (_isProgress == false) addToCart(index, favList, context);

                  /*  addToCart(
                                index,
                                (int.parse(model
                                            .prVarientList![model.selVarient!]
                                            .cartCount!) +
                                        int.parse(model.qtyStepSize!))
                                    .toString());*/
                },
                child: SvgPicture.asset(
                  imagePath + 'bag.svg',
                  color: colors.primary,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added')
              setSnackbar(msg!, context);
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> addToCart(
      int index, List<Product> favList, BuildContext context) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            _isProgress = true;
          });
        String qty = (int.parse(favList[index].prVarientList![0].cartCount!) +
                int.parse(favList[index].qtyStepSize!))
            .toString();

        if (int.parse(qty) < favList[index].minOrderQuntity!) {
          qty = favList[index].minOrderQuntity.toString();
          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: favList[index].prVarientList![0].id,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          setSnackbar("Added to Cart", context);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];
            // CUR_CART_COUNT = data['cart_count'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            favList[index].prVarientList![0].cartCount = qty.toString();
          } else {
            setSnackbar(msg!, context);
          }
          if (mounted)
            setState(() {
              _isProgress = false;
            });
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
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

  // removeFromCart(int index, bool remove) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     try {
  //       if (mounted)
  //         setState(() {
  //           _isProgress = true;
  //         });

  //       var parameter = {
  //         USER_ID: CUR_USERID,
  //         QTY: remove
  //             ? "0"
  //             : (int.parse(favList[index]
  //                         .productList[0]
  //                         .prVarientList[0]
  //                         .cartCount) -
  //                     1)
  //                 .toString(),
  //         PRODUCT_VARIENT_ID: favList[index].productList[0].prVarientList[0].id
  //       };

  //       Response response =
  //           await post(manageCartApi, body: parameter, headers: headers)
  //               .timeout(Duration(seconds: timeOut));
  //       if (response.statusCode == 200) {
  //         var getdata = json.decode(response.body);

  //         bool error = getdata["error"];
  //         String msg = getdata["message"];
  //         if (!error) {
  //           var data = getdata["data"];

  //           String qty = data['total_quantity'];
  //           CUR_CART_COUNT = data['cart_count'];

  //           if (remove)
  //             favList.removeWhere(
  //                 (item) => item.varientId == favList[index].varientId);
  //           else {
  //             favList[index].productList[0].prVarientList[0].cartCount =
  //                 qty.toString();
  //           }

  //           widget.update();
  //         } else {
  //           setSnackbar(msg);
  //         }
  //         if (mounted)
  //           setState(() {
  //             _isProgress = false;
  //           });
  //       }
  //     } on TimeoutException catch (_) {
  //       setSnackbar(getTranslated(context, 'somethingMSg'));
  //       if (mounted)
  //         setState(() {
  //           _isProgress = false;
  //         });
  //     }
  //   } else {
  //     if (mounted)
  //       setState(() {
  //         _isNetworkAvail = false;
  //       });
  //   }
  // }

  _removeFav(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (mounted)
        setState(() {
          _isProgress = true;
        });
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: favList[index].id,
        };
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          setSnackbar("Removed", context);
          context
              .read<FavoriteProvider>()
              .removeFavItem(favList[index].prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            _isProgress = false;
          });
      } on TimeoutException catch (_) {
        _isProgress = false;
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future _refresh() {
    if (mounted)
      setState(() {
        _isFavLoading = true;
      });
    offset = 0;
    total = 0;
    return _getFav();
  }

  _showContent(BuildContext context) {
    return Selector<FavoriteProvider, Tuple2<bool, List<Product>>>(
        builder: (context, data, child) {
          return data.item1
              ? shimmer(context)
              : data.item2.length == 0
                  ? Center(child: Text(getTranslated(context, 'noFav')!))
                  : RefreshIndicator(
                      color: colors.primary,
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        shrinkWrap: true,
                        // controller: controller,
                        itemCount: data.item2.length,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return listItem(index, data.item2);
                        },
                      ));
        },
        selector: (_, provider) =>
            Tuple2(provider.isLoading, provider.favList));
  }
}
