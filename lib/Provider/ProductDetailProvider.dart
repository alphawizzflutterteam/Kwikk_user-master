import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';

class ProductDetailProvider extends ChangeNotifier {
  bool _reviewLoading = true;
  bool _moreProductLoading = true;


  List<Product> _compareList = [];

  get compareList => _compareList;

  get moreProductLoading => _moreProductLoading;

  get reviewLoading => _reviewLoading;



  setReviewLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  setProductLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }


  addCompareList(Product compareList) {
    _compareList.add(compareList);
    notifyListeners();
  }
}
