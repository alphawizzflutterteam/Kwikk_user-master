import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Helper/String.dart';

class OrderSuccess extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateSuccess();
  }
}

class StateSuccess extends State<OrderSuccess> {
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'ORDER_PLACED')!, context),
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(vertical: 40),
              child: SvgPicture.asset(
                imagePath + "bags.svg",
                color: colors.primary,
              ),
              /*  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.white,
                      borderRadius: BorderRadius.all(Radius.circular(20))),*/
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'ORD_PLC')!,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              getTranslated(context, 'ORD_PLC_SUCC')!,
              style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
            ),
            Padding(
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
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(10.0)),
                    ),
                    child: Text(getTranslated(context, 'CONTINUE_SHOPPING')!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).colorScheme.white,
                            fontWeight: FontWeight.normal))),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home', (Route<dynamic> route) => false);
                },
              ),
            )
          ],
        )),
      ),
    );
  }
}
