import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;

  const PrivacyPolicy({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? privacy;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  // final flutterWebViewPlugin = FlutterWebviewPlugin();
  // late StreamSubscription<WebViewStateChanged> _onStateChanged;
  //InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();

    getSetting();
    // flutterWebViewPlugin.close();
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

    // _onStateChanged =
    //     flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
    //   if (state.type == WebViewState.abortLoad) {
    //     _launchSocialNativeLink(state.url);
    //   }
    // });
  }

  Future<void> _launchSocialNativeLink(String url) async {
    if (Platform.isIOS) {
      if (url.contains("tel:")) {
        _launchUrl(url);
      }
    } else if (Platform.isAndroid) {
      if (url.contains("tel:") ||
          url.contains("https://api.whatsapp.com/send")) {
        _launchUrl(url);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    // _onStateChanged.cancel();
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
    return _isLoading
        ? Scaffold(
            key: _scaffoldKey,
            appBar: getSimpleAppBar(widget.title!, context),
            body: getProgress(),
          )
        : privacy != null
            ? Scaffold(
                key: _scaffoldKey,
                appBar: getSimpleAppBar(widget.title!, context),
                body: SingleChildScrollView(
                    child: Html(
                  data: privacy,
                )) /*InAppWebView(
                    initialData: InAppWebViewInitialData(
                        baseUrl: Uri.dataFromString(privacy!,
                            mimeType: 'text/html', encoding: utf8),
                        data: privacy!.toString(),
                        mimeType: 'text/html',
                        encoding: "utf8"),
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: false,
                          transparentBackground: true,
                          supportZoom: true,
                          verticalScrollBarEnabled: true,
                          javaScriptEnabled: true,
                          cacheEnabled: true,
                        ),
                        android: AndroidInAppWebViewOptions(
                          defaultFontSize: 30,
                        ),
                        ios: IOSInAppWebViewOptions(

                        )),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _webViewController = controller;
                    },
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    })*/
                )
            /*WebviewScaffold(
                appBar: getSimpleAppBar(widget.title!, context),
                withJavascript: true,
                appCacheEnabled: true,
                scrollBar: false,
                url: new Uri.dataFromString(privacy!,
                        mimeType: 'text/html', encoding: utf8)
                    .toString(),
                invalidUrlRegex: Platform.isAndroid
                    ? "^tel:|^https:\/\/api.whatsapp.com\/send|^mailto:"
                    : "^tel:|^mailto:",
              )*/
            : Scaffold(
                key: _scaffoldKey,
                appBar: getSimpleAppBar(widget.title!, context),
                body: _isNetworkAvail ? Container() : noInternet(context),
              );
  }

  Future<void> getSetting() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        String? type;
        if (widget.title == getTranslated(context, 'PRIVACY'))
          type = PRIVACY_POLLICY;
        else if (widget.title == getTranslated(context, 'TERM'))
          type = TERM_COND;
        else if (widget.title == getTranslated(context, 'ABOUT_LBL'))
          type = ABOUT_US;
        else if (widget.title == getTranslated(context, 'CONTACT_LBL'))
          type = CONTACT_US;

        var parameter = {TYPE: type};
        Response response =
            await post(getSettingApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            privacy = getdata["data"][type][0].toString();
          } else {
            setSnackbar(msg!);
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        _isLoading = false;
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isLoading = false;
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
}
