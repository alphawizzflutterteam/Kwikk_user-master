import 'dart:convert';
/// error : false
/// message : "Profile Update Succesfully"

UpdateUserModels updateUserModelsFromJson(String str) => UpdateUserModels.fromJson(json.decode(str));
String updateUserModelsToJson(UpdateUserModels data) => json.encode(data.toJson());
class UpdateUserModels {
  UpdateUserModels({
      bool? error, 
      String? message,}){
    _error = error;
    _message = message;
}

  UpdateUserModels.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
  }
  bool? _error;
  String? _message;
UpdateUserModels copyWith({  bool? error,
  String? message,
}) => UpdateUserModels(  error: error ?? _error,
  message: message ?? _message,
);
  bool? get error => _error;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    return map;
  }

}