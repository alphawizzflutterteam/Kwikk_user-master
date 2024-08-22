import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<SectionModel> _cartList = [];

  get cartList => _cartList;
  bool _isProgress = false;




  get cartIdList => _cartList.map((fav) => fav.id).toList();

  get qtyList => _cartList.map((fav) => fav.qty).toList();

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  removeCartItem(String id) {
    _cartList.removeWhere((item) => item.varientId == id);
    notifyListeners();
  }

  addCartItem(SectionModel? item) {
    if (item != null) {
      _cartList.add(item);
      notifyListeners();
    }
  }

  setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    notifyListeners();
  }
}
