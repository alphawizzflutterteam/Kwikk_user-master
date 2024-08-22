import 'dart:convert';
import 'dart:math';

import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:stripe_payment/stripe_payment.dart';

import 'String.dart';

class StripeTransactionResponse {
  final String? message, status;
  bool? success;

  StripeTransactionResponse({this.message, this.success, this.status});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String? secret;

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  // static init(String? stripeId, String? stripeMode) {
  //   StripePayment.setOptions(StripeOptions(
  //       publishableKey: stripeId,
  //       merchantId: "Test",
  //       androidPayMode: stripeMode));
  // }

  
  // static Future<StripeTransactionResponse> payWithNewCard(
  //     {String? amount, String? currency, String? from,BuildContext? context}) async {
  //   try {
  //     var paymentMethod = await StripePayment.paymentRequestWithCardForm(
  //         CardFormPaymentRequest());
  //
  //     var paymentIntent =
  //         await (StripeService.createPaymentIntent(amount, currency, from,context));
  //
  //     var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
  //       clientSecret: paymentIntent!['client_secret'],
  //       paymentMethodId: paymentMethod.id,
  //     ));
  //
  //     stripePayId = paymentIntent['id'];
  //
  //     if (response.status == 'succeeded') {
  //       return new StripeTransactionResponse(
  //           message: 'Transaction successful',
  //           success: true,
  //           status: response.status);
  //     } else if (response.status == 'pending' ||
  //         response.status == "captured") {
  //       return new StripeTransactionResponse(
  //           message: 'Transaction pending',
  //           success: true,
  //           status: response.status);
  //     } else {
  //       return new StripeTransactionResponse(
  //           message: 'Transaction failed',
  //           success: false,
  //           status: response.status);
  //     }
  //   } on PlatformException catch (err) {
  //     return StripeService.getPlatformExceptionErrorResult(err);
  //   } catch (err) {
  //     return new StripeTransactionResponse(
  //         message: 'Transaction failed: ${err.toString()}',
  //         success: false,
  //         status: "fail");
  //   }
  // }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(
        message: message, success: false, status: "cancelled");
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(
      String? amount, String? currency, String? from,BuildContext? context) async {

    SettingProvider settingsProvider = Provider.of<SettingProvider>(context!, listen: false);

    String orderId =
        "wallet-refill-user-${settingsProvider.userId}-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";

    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
        'description': from,

      };
      if (from == 'wallet') body['metadata[order_id]'] = orderId;


      var response = await http.post(Uri.parse(StripeService.paymentApiUrl),
          body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {

    }
    return null;
  }
}
