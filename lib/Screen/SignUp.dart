import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = false;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  int count = 1;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode? nameFocus,
      emailFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  var genderSelect;
  var bankImg = null;
  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    mobile = await settingsProvider.getPrefrence(MOBILE);
    countrycode = await settingsProvider.getPrefrence(COUNTRY_CODE);
    if (mounted) setState(() {});
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      // if (referCode != null) getRegisterUser();
      getRegisterUser();
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      elevation: 1.0,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
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

  Future<void> getRegisterUser() async {
    try {
      DateTime date = selectedDate;
      var request = MultipartRequest("POST", (getUserSignUpApi));
      request.headers.addAll(headers);
      request.fields[MOBILE] = mobile!;
      request.fields[COUNTRY_CODE] = countrycode!;
      request.fields[NAME] = name!;
      request.fields[EMAIL] = email!;
      request.fields[PASSWORD] = password!;
      request.fields["gender"] = genderSelect ?? "male";
      // request.fields["dob"] = "${date.day}-${date.month}-${date.year}";
      request.fields[FRNDCODE] = referController.text.toString();
      // var pic = await MultipartFile.fromPath("bank_pass", bankImg.path);
      // request.files.add(pic);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      print("sdfsdfsdfassdfsd=============");
      print(request);
      print(request.fields);
      print(responseString);
      var getdata = json.decode(responseString);
      print("${getdata}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      // var data = {
      //   // MOBILE: mobile,
      //   MOBILE: "9999999999",
      //   NAME: name,
      //   EMAIL: email,
      //   PASSWORD: password,
      //   COUNTRY_CODE: countrycode,
      //   "gender": genderSelect ?? "male",
      //   "dob": "${date.day}-${date.month}-${date.year}",
      //   REFERCODE: referCode,
      //   // FRNDCODE: friendCode
      // };
      // print(data);
      // Response response =
      //     await post(getUserSignUpApi, body: data, headers: headers)
      //         .timeout(Duration(seconds: timeOut));
      // print(response.body);
      // var getdata = json.decode(response.body);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();
      if (!error) {
        // setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!);
        Fluttertoast.showToast(msg: getTranslated(context, 'REGISTER_SUCCESS_MSG')!,
            backgroundColor: colors.primary
        );
        var i = getdata["data"][0];

        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;

        // CUR_USERNAME = name;

        UserProvider userProvider = context.read<UserProvider>();
        userProvider.setName(name ?? "");
        userProvider.setBankPic(i["bank_pass"] ?? "");

        SettingProvider settingProvider = context.read<SettingProvider>();
        settingProvider.saveUserDetail(id!, name, email, mobile, city, area,
            address, pincode, latitude, longitude, "", context);

        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      } else {
        setSnackbar(msg!);
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(getTranslated(context, 'USER_REGISTER_DETAILS')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
      ),
    );
  }

  setUserName() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateUserName(
            val!,
            getTranslated(context, 'USER_REQUIRED'),
            getTranslated(context, 'USER_LENGTH')),
        onSaved: (String? value) {
          name = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'NAMEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
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
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, passFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.alternate_email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
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
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setRefer() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        onSaved: (String? value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
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
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0),
        child: TextFormField(
          keyboardType: TextInputType.text,
          obscureText: !_showPassword!,
          focusNode: passFocus,
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          textInputAction: TextInputAction.next,
          style: TextStyle(
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
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.primary),
              borderRadius: BorderRadius.circular(7.0),
            ),
            prefixIcon: SvgPicture.asset(
              "assets/images/password.svg",
              height: 17,
              width: 17,
              color: Theme.of(context).colorScheme.fontColor,
            ),
            // Icon(
            //   Icons.lock_outline,
            //   color: Theme.of(context).colorScheme.lightBlack2,
            //   size: 17,
            // ),
            hintText: getTranslated(context, 'PASSHINT_LBL'),
            hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
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
                  BorderSide(color: Theme.of(context).colorScheme.fontColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  showPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: Theme.of(context).colorScheme.fontColor,
              activeColor: Theme.of(context).colorScheme.lightWhite,
              onChanged: (bool? value) {
                if (mounted)
                  setState(() {
                    _showPassword = value;
                  });
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal))
          ],
        ));
  }

  // birthDate(){
  //   String birthDateInString;
  //   DateTime birthDate;
  //   bool isDateSelected= false;
  //
  //
  //   GestureDetector(
  //       child: new Icon(Icons.calendar_today),
  //
  //       onTap: ()async{
  //         final datePick= await showDatePicker(
  //             context: context,
  //             initialDate: new DateTime.now(),
  //             firstDate: new DateTime(1900),
  //             lastDate: new DateTime(2100)
  //         );
  //         if(datePick!=null
  //         //&&
  //            // datePick!=birthDate
  //         ){
  //           setState(() {
  //             birthDate=datePick;
  //             isDateSelected=true;
  //
  //             // put it here
  //             birthDateInString = "${birthDate.month}/${birthDate.day}/${birthDate.year}"; // 08/14/2019
  //
  //           });
  //         }
  //       }
  //   );
  //
  // }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'SAVE_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  loginTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: EdgeInsetsDirectional.only(top: 20.0, start: 10.0),
            alignment: AlignmentDirectional.topStart,
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

  expandedBottomView() {
    return Expanded(
        flex: 8,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
                child: Form(
              key: _formkey,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsetsDirectional.only(
                    start: 20.0, end: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    registerTxt(),
                    setUserName(),
                    setEmail(),
                    setPass(),
                    gender(),
                    getDob(),
                    setRefer(),
                    showPass(),
                    verifyBtn(),
                    loginTxt(),
                  ],
                ),
              ),
            )),
          ),
        ));
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getUserDetails();
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));

    generateReferral();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  backBtn(),
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
                  //getBgImage(),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };

      Response response =
          await post(validateReferalApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        referCode = refer;
        REFER_CODE = refer;
        if (mounted) setState(() {});
      } else {
        if (count < 5) generateReferral();
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

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
                    maxHeight: MediaQuery.of(context).size.height * 2.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      registerTxt(),
                      setUserName(),
                      setEmail(),
                      setPass(),
                      gender(),
                      // getDob(),
                       setRefer(),
                      //showPass(),
                      //birthDate(),
                      // InkWell(
                      //   onTap: () => getImage(context, ImgSource.Both),
                      //   child: bankImg != null
                      //       ? Container(
                      //           height: 60,
                      //           width: MediaQuery.of(context).size.width * 0.8,
                      //           child: Image.file(
                      //             File(bankImg.path),
                      //             fit: BoxFit.cover,
                      //           ))
                      //       : Container(
                      //     decoration: BoxDecoration(
                      //         color: colors.primary,
                      //       borderRadius: BorderRadius.circular(10)
                      //     ),
                      //           height: 40,
                      //           width: MediaQuery.of(context).size.width * 0.8,
                      //
                      //           alignment: Alignment.center,
                      //           child: Text(
                      //             "Upload bank proof",
                      //             style: TextStyle(color: Colors.white),
                      //           ),
                      //         ),
                      // ),
                      verifyBtn(),
                      loginTxt(),
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

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          'assets/images/loginlogo.png',
        ),
      ),
    );
  }

  gender() {
    return Column(
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0),
            ),
            Text("Male"),
            Radio(
                value: "male",
                groupValue: genderSelect,
                onChanged: (val) {
                  setState(() {
                    print(genderSelect);
                    genderSelect = val;
                  });
                }),
            Text("Female"),
            Radio(
                value: "female",
                groupValue: genderSelect,
                onChanged: (val) {
                  setState(() {
                    print(genderSelect);
                    genderSelect = val;
                  });
                })
          ],
        ),
      ],
    );
  }

  getDob() {
    DateTime date = selectedDate;
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined),
          Container(
            height: MediaQuery.of(context).size.height * 0.09,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(color: Colors.white),
            child: ListTile(
              onTap: () {
                _selectDate(context);
              },
              title: Text("Select Date Of Birth"),
              subtitle: Text("${date.day}-${date.month}-${date.year}"),
            ),
          ),
        ],
      ),
    );
  }

  Future getImage(context, ImgSource source) async {
    print("dsafsadfasd");
    var image = await ImagePickerGC.pickImage(
        enableCloseButton: true,
        closeIcon: Icon(
          Icons.close,
          color: Colors.red,
          size: 12,
        ),
        context: context,
        source: source,
        barrierDismissible: true,
        cameraIcon: Icon(
          Icons.camera_alt,
          color: Colors.red,
        ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
        cameraText: Text(
          "From Camera",
          style: TextStyle(color: Colors.red),
        ),
        galleryText: Text(
          "From Gallery",
          style: TextStyle(color: Colors.blue),
        ));
    setState(() {
      bankImg = image;
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: ( context,  child){
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xffFF00FF), // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.black, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }


    );
    if (selected != null && selected != selectedDate)
      setState(() {
        selectedDate = selected;
      });
  }
}
