import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class SetPass extends StatefulWidget {
  final String mobileNumber;

  SetPass({
    Key? key,
    required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<SetPass> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final confirmpassController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? password, comfirmpass;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getResetPass();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
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

  Future<void> getResetPass() async {
    try {
      var data = {MOBILENO: widget.mobileNumber, NEWPASS: password};
      Response response =
          await post(getResetPassApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          setSnackbar(getTranslated(context, 'PASS_SUCCESS_MSG')!);
          Future.delayed(Duration(seconds: 1)).then((_) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => Login(),
            ));
          });
        } else {
          setSnackbar(msg!);
        }
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  subLogo() {
    return Expanded(
      child: Center(
        child: new Image.asset(
          'assets/images/homelogo.png',
        ),
      ),
    );
  }

  forgotpassTxt() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            getTranslated(context, 'FORGOT_PASSWORDTITILE')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: colors.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 30.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: true,
          style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: passwordController,
          validator: (val) => validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            password = value;
          },
          decoration: InputDecoration(
            prefixIcon: SvgPicture.asset(
              "assets/images/password.svg",
              color: Theme.of(context).colorScheme.fontColor,
            ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            // filled: true,
            // fillColor: Theme.of(context).colorScheme.lightWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.primary),
              borderRadius: BorderRadius.circular(7.0),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ));
  }

  setConfirmpss() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 20.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: true,
          style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          controller: confirmpassController,
          validator: (value) {
            if (value!.length == 0)
              return getTranslated(context, 'CON_PASS_REQUIRED_MSG');
            if (value != password) {
              return getTranslated(context, 'CON_PASS_NOT_MATCH_MSG');
            } else {
              return null;
            }
          },
          onSaved: (String? value) {
            comfirmpass = value;
          },
          decoration: InputDecoration(
            prefixIcon: SvgPicture.asset(
              "assets/images/password.svg",
              color: Theme.of(context).colorScheme.fontColor,
            ),
            hintText: getTranslated(context, 'CONFIRMPASSHINT_LBL'),
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal),
            // filled: true,
            // fillColor: Theme.of(context).colorScheme.lightWhite,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: EdgeInsetsDirectional.only(top: 20.0, start: 10.0),
            alignment: Alignment.topLeft,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: InkWell(
                  child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  @override
  void initState() {
    super.initState();
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

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setPassBtn() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 20.0, bottom: 20.0),
        child: AppBtn(
          title: getTranslated(context, 'SET_PASSWORD'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            validateAndSubmit();
          },
        ));
  }

  expandedBottomView() {
    return Expanded(
        child: SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Card(
          elevation: 0.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 20.0),
          child: Column(
            children: [
              forgotpassTxt(),
              setPass(),
              setConfirmpss(),
              setPassBtn(),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: back(),
                  ),
                  Image.asset(
                    'assets/images/doodle.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 110,
        height: 110,
        child: Image.asset(
          'assets/images/loginlogo.png',
        ),
      ),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      forgotpassTxt(),
                      setPass(),
                      setConfirmpss(),
                      setPassBtn(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
