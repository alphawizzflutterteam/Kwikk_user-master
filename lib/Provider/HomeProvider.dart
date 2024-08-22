import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _curSlider = 0;
  int _curSlider2 = 0;
  int _curSlider3 = 0;
  bool _catLoading = true;
  bool _secLoading = true;
  bool _sliderLoading = true;
  bool _offerLoading = true;
  bool _sellerLoading = true;

  get sellerLoading => _sellerLoading;

  get catLoading => _catLoading;

  get curSlider => _curSlider;

  get secLoading => _secLoading;

  get sliderLoading => _sliderLoading;

  get offerLoading => _offerLoading;

  setCurSlider(int pos) {
    _curSlider = pos;
    notifyListeners();
  }

  setCurSlider2(int pos) {
    _curSlider2 = pos;
    notifyListeners();
  }

  setCurSlider3(int pos) {
    _curSlider3 = pos;
    notifyListeners();
  }

  setOfferLoading(bool loading) {
    _offerLoading = loading;
    notifyListeners();
  }

  setSliderLoading(bool loading) {
    _sliderLoading = loading;
    notifyListeners();
  }

  setSecLoading(bool loaidng) {
    _secLoading = loaidng;
    notifyListeners();
  }

  setSellerLoading(bool laoding) {
    _sellerLoading = laoding;
    notifyListeners();
  }

  setCatLoading(bool loading) {
    _catLoading = loading;
    notifyListeners();
  }
}
