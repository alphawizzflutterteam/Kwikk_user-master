import 'dart:convert';
/// error : false
/// message : "Seller retrieved successfully"
/// total : "11"
/// data : [{"seller_id":"232","seller_name":"ronak","email":"ronak@gmail.com","mobile":"8827272799","dob":"2022-03-23","gender":"male","slug":"ronak-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"ronak","store_url":"","store_description":"","seller_profile":"https://alphawizztest.tk/ZuqZuq/","open_close_status":"0","balance":"0"},{"seller_id":"228","seller_name":"RAJ","email":"raj@gmail.com","mobile":"827272733","dob":"1995-11-22","gender":"male","slug":"raj-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"raj","store_url":"","store_description":"","seller_profile":"https://alphawizztest.tk/ZuqZuq/","open_close_status":"1","balance":"0"},{"seller_id":"227","seller_name":"aman","email":"aman@gmail.com","mobile":"8827272700","dob":"1994-01-22","gender":"male","slug":"kumar-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"KUMAR","store_url":"","store_description":"","seller_profile":"https://alphawizztest.tk/ZuqZuq/","open_close_status":"1","balance":"0"},{"seller_id":"172","seller_name":"vipin","email":"vipin@gmail.com","mobile":"8871548522","dob":"2022-03-01","gender":"male","slug":"vipin-store-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"vipin store","store_url":"@","store_description":"","seller_profile":"https://alphawizztest.tk/ZuqZuq/","open_close_status":"0","balance":"0"},{"seller_id":"168","seller_name":"palak","email":"rohitj11alphawizz@gmail.com","mobile":"8770669970","dob":"2022-03-25","gender":"male","slug":"rohit","seller_rating":"0.00","no_of_ratings":"0","store_name":"Rohit","store_url":"#","store_description":"cgfhj","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/indain_milan__com1.png","open_close_status":"1","balance":"0"},{"seller_id":"158","seller_name":"vinay","email":"chouhanvinay30@gmail.com","mobile":"9669977096","dob":"1990-12-30","gender":"male","slug":"llliiiiccc-1","seller_rating":"5.00","no_of_ratings":"1","store_name":"llliiiiccc","store_url":"vinay.yahoo.in","store_description":"asdsadasd","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/OIP.jpg","open_close_status":"0","balance":"0"},{"seller_id":"148","seller_name":"Deepak kumar","email":"alphawizz456789@gmail.com","mobile":"7737505375","dob":"2002-08-11","gender":"male","slug":"raj","seller_rating":"0.00","no_of_ratings":"0","store_name":"raj","store_url":"hgdsdxjchdycjags","store_description":"goods store","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/plastic-plplpl1.jpg","open_close_status":"0","balance":"0"},{"seller_id":"144","seller_name":"TIK","email":"alpha4544554wizz@gmail.com","mobile":"1234568794","dob":"2006-10-30","gender":"male","slug":"ok","seller_rating":"0.00","no_of_ratings":"0","store_name":"OK","store_url":"sdhshfklshf454hjshd","store_description":"abc","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/BOOKS2.jpg","open_close_status":"0","balance":"0"},{"seller_id":"132","seller_name":"A2Z","email":"a2z@gmail.com","mobile":"9000000000","dob":"1999-05-04","gender":"male","slug":"a2z-store-1","seller_rating":"0.00","no_of_ratings":"0","store_name":"A2Z STORE","store_url":"A2Z.COM","store_description":"A2Z PRODUCT","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/Penguins4.jpg","open_close_status":"0","balance":"0"},{"seller_id":"129","seller_name":"RELIANCE","email":"reliance@gmail.com","mobile":"9999999999","dob":"1999-01-17","gender":"male","slug":"reliance-store","seller_rating":"5.00","no_of_ratings":"1","store_name":"RELIANCE STORE","store_url":"RELIANCE.COM","store_description":"KAR LO DUNIYA MUTHI ME","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/Penguins2.jpg","open_close_status":"0","balance":"0"},{"seller_id":"126","seller_name":"ALPHA","email":"alpha@gmail.com","mobile":"9123456789","dob":"2022-03-24","gender":"male","slug":"alphawizz","seller_rating":"1.00","no_of_ratings":"1","store_name":"ALPHAWIZZ","store_url":"www.zuqzuq.com","store_description":"ALPHAWIZZ IS SOFTWERE SERVICE PROVIDER","seller_profile":"https://alphawizztest.tk/ZuqZuq/uploads/seller/Penguins3.jpg","open_close_status":"1","balance":"0"}]

SingleSellerModal singleSellerModalFromJson(String str) => SingleSellerModal.fromJson(json.decode(str));
String singleSellerModalToJson(SingleSellerModal data) => json.encode(data.toJson());
class SingleSellerModal {
  SingleSellerModal({
      bool? error, 
      String? message, 
      String? total, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _total = total;
    _data = data;
}

  SingleSellerModal.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    _total = json['total'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  String? _total;
  List<Data>? _data;
SingleSellerModal copyWith({  bool? error,
  String? message,
  String? total,
  List<Data>? data,
}) => SingleSellerModal(  error: error ?? _error,
  message: message ?? _message,
  total: total ?? _total,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  String? get total => _total;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    map['total'] = _total;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// seller_id : "232"
/// seller_name : "ronak"
/// email : "ronak@gmail.com"
/// mobile : "8827272799"
/// dob : "2022-03-23"
/// gender : "male"
/// slug : "ronak-1"
/// seller_rating : "0.00"
/// no_of_ratings : "0"
/// store_name : "ronak"
/// store_url : ""
/// store_description : ""
/// seller_profile : "https://alphawizztest.tk/ZuqZuq/"
/// open_close_status : "0"
/// balance : "0"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? sellerId, 
      String? sellerName, 
      String? email, 
      String? mobile, 
      String? dob, 
      String? gender, 
      String? slug, 
      String? sellerRating, 
      String? noOfRatings, 
      String? storeName, 
      String? storeUrl, 
      String? storeDescription, 
      String? sellerProfile, 
      String? openCloseStatus, 
      String? balance,}){
    _sellerId = sellerId;
    _sellerName = sellerName;
    _email = email;
    _mobile = mobile;
    _dob = dob;
    _gender = gender;
    _slug = slug;
    _sellerRating = sellerRating;
    _noOfRatings = noOfRatings;
    _storeName = storeName;
    _storeUrl = storeUrl;
    _storeDescription = storeDescription;
    _sellerProfile = sellerProfile;
    _openCloseStatus = openCloseStatus;
    _balance = balance;
}

  Data.fromJson(dynamic json) {
    _sellerId = json['seller_id'];
    _sellerName = json['seller_name'];
    _email = json['email'];
    _mobile = json['mobile'];
    _dob = json['dob'];
    _gender = json['gender'];
    _slug = json['slug'];
    _sellerRating = json['seller_rating'];
    _noOfRatings = json['no_of_ratings'];
    _storeName = json['store_name'];
    _storeUrl = json['store_url'];
    _storeDescription = json['store_description'];
    _sellerProfile = json['seller_profile'];
    _openCloseStatus = json['open_close_status'];
    _balance = json['balance'];
  }
  String? _sellerId;
  String? _sellerName;
  String? _email;
  String? _mobile;
  String? _dob;
  String? _gender;
  String? _slug;
  String? _sellerRating;
  String? _noOfRatings;
  String? _storeName;
  String? _storeUrl;
  String? _storeDescription;
  String? _sellerProfile;
  String? _openCloseStatus;
  String? _balance;
Data copyWith({  String? sellerId,
  String? sellerName,
  String? email,
  String? mobile,
  String? dob,
  String? gender,
  String? slug,
  String? sellerRating,
  String? noOfRatings,
  String? storeName,
  String? storeUrl,
  String? storeDescription,
  String? sellerProfile,
  String? openCloseStatus,
  String? balance,
}) => Data(  sellerId: sellerId ?? _sellerId,
  sellerName: sellerName ?? _sellerName,
  email: email ?? _email,
  mobile: mobile ?? _mobile,
  dob: dob ?? _dob,
  gender: gender ?? _gender,
  slug: slug ?? _slug,
  sellerRating: sellerRating ?? _sellerRating,
  noOfRatings: noOfRatings ?? _noOfRatings,
  storeName: storeName ?? _storeName,
  storeUrl: storeUrl ?? _storeUrl,
  storeDescription: storeDescription ?? _storeDescription,
  sellerProfile: sellerProfile ?? _sellerProfile,
  openCloseStatus: openCloseStatus ?? _openCloseStatus,
  balance: balance ?? _balance,
);
  String? get sellerId => _sellerId;
  String? get sellerName => _sellerName;
  String? get email => _email;
  String? get mobile => _mobile;
  String? get dob => _dob;
  String? get gender => _gender;
  String? get slug => _slug;
  String? get sellerRating => _sellerRating;
  String? get noOfRatings => _noOfRatings;
  String? get storeName => _storeName;
  String? get storeUrl => _storeUrl;
  String? get storeDescription => _storeDescription;
  String? get sellerProfile => _sellerProfile;
  String? get openCloseStatus => _openCloseStatus;
  String? get balance => _balance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['seller_id'] = _sellerId;
    map['seller_name'] = _sellerName;
    map['email'] = _email;
    map['mobile'] = _mobile;
    map['dob'] = _dob;
    map['gender'] = _gender;
    map['slug'] = _slug;
    map['seller_rating'] = _sellerRating;
    map['no_of_ratings'] = _noOfRatings;
    map['store_name'] = _storeName;
    map['store_url'] = _storeUrl;
    map['store_description'] = _storeDescription;
    map['seller_profile'] = _sellerProfile;
    map['open_close_status'] = _openCloseStatus;
    map['balance'] = _balance;
    return map;
  }

}