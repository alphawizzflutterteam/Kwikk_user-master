import 'dart:convert';
import 'dart:io';

import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Screen/Dashboard.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Helper/Color.dart';
import 'SignUp.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController aadharC = TextEditingController();
  TextEditingController bussinessC = TextEditingController();
  File? aadharImage;



  setUserDetails() async {
    var headers = {
      'Cookie': 'ci_session=7855398310a31f210c6d7a00096e156a7c27686e'
    };
    var request = http.MultipartRequest('POST', Uri.parse('https://developmentalphawizz.com/kwikk/app/v1/api/set_bussiness_name'));
    request.fields.addAll({
      'user_id':  CUR_USERID.toString(),
      'bussiness_name': bussinessC.text
    });
   print('_____dcssddsss_____${request.fields}_________');
    aadharImage ==  null ? null : request.files.add(await http.MultipartFile.fromPath('aadhar_number', aadharImage!.path.toString()));
    print('____ssssssssss______${request.files}_________');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    var result = await response.stream.bytesToString();
    var finalResult =  jsonDecode(result);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
    }
    else {
    print(response.reasonPhrase);
    }


  }

//   Future<void> setUserDetails() async {
//     var headers = {
//       'Cookie': 'ci_session=c4e5419c58269cd74027653ca721c6b39b5fd1a3'
//     };
//     var request = http.MultipartRequest('POST', Uri.parse('set_bussiness_name'));
//     request.fields.addAll({
//       // 'user_id': '${CUR_USERID.toString()}',
//       'bussiness_name': '${bussinessC.text.toString()}'
//     });
//     print('______zxzzzz____${request.fields}_________');
//     aadharImage ==  null ? null : request.files.add(await http.MultipartFile.fromPath('aadhar_number', aadharImage!.path.toString()));
//     request.headers.addAll(headers);
//
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       print(await response.stream.bytesToString());
//       Navigator.push(context, MaterialPageRoute(builder: (context) => BottomAppBar()));
//     }
//     else {
//       print(response.reasonPhrase);
//     }
//
//     // print("Api Word");
//     // var headers = {
//     //   'Cookie': 'ci_session=5ea86fe9b77c1791e0a49d6de674ab6c0699f508'
//     // };
//     // var request = http.MultipartRequest('GET', Uri.parse('set_bussiness_name'));
//     // request.fields.addAll({
//     //   'user_id': '${CUR_USERID.toString()}',
//     //   // 'aadhar_number': '${aadharC.text.toString()}',
//     //   'bussiness_name': '${bussinessC.text.toString()}',
//     // });
//     //
//     // request.headers.addAll(headers);
//     // http.StreamedResponse response = await request.send();
//     //
//     // if (response.statusCode == 200) {
//     //   print(await response.stream.bytesToString());
//     //   Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
//     // }
//     // else {
//     //   print(response.reasonPhrase);
//     // }
// }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: InkWell(
              onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.keyboard_arrow_left, color: colors.primary, size: 30,)),
            backgroundColor: Colors.white,
            title: Text("KYC Details", style:  TextStyle(fontSize: 18, color: colors.primary),
            ),
          ),
             body: SingleChildScrollView(
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                   InkWell(
                     onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
                     },
                     child: Text("Skip>>>", style: TextStyle(fontSize: 18, color: colors.primary),
                     ),
                   ),
                     SizedBox(height: 140,),
                     InkWell(
                       onTap: (){
                         imageUpload();
                       },
                       child: InkWell(
                         onTap: () {
                         },
                         child: Column(
                           children: [
                             Padding(
                               padding: const EdgeInsets.only(left: 5.0, bottom: 5),
                               child: Text(
                                 "Upload Aadhar Image",
                                 style: TextStyle(
                                   fontSize: 15,
                                   color:colors.primary,
                                 ),
                               ),
                             ),
                             imageAadhar(),
                           ],
                         ),
                       ),
                       // child: Container(
                       //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),
                       //   ),
                       //   child: TextFormField(
                       //     controller: aadharC,
                       //     validator: (value) {
                       //       if (value == null || value.isEmpty) {
                       //         return 'Please Enter Aadhar Details.';
                       //       }
                       //       return null;
                       //     },
                       //   decoration: InputDecoration(
                       //     hintText: "Upload Adhar Image",
                       //   ),
                       // ),
                       // ),
                     ),
                     SizedBox(height: 13,),
                     Container(
                       padding: EdgeInsets.only(right: 10, left: 10),
                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),
                       ),
                       child:
                       TextFormField(
                         controller: bussinessC,
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Please Enter Business Name';
                           }
                           return null;
                         },
                         decoration: InputDecoration(
                           hintText: "Business Name",
                         ),
                       ),
                     ),
                     SizedBox(height: 60,),
                     Center(
                       child: Container(
                         height: 40,
                         width: MediaQuery.of(context).size.width,
                         // color: colors.primary,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(10), color: colors.primary),
                         child:
                         Align(
                           alignment: Alignment.center,
                             child: InkWell(
                               onTap: () {
                                 setUserDetails();

                               },
                                 child: Text("Submit", style: TextStyle(fontSize: 18, color: colors.lightWhite2),
                                 ),
                             ),
                         ),
                       ),
                     ),
                     // InkWell
                     //   (onTap: (){
                     // },
                     //     child: Text("jhbccbuz"),
                     // ),
                 ],
                 ),
               ),
             ),
      ),
      ),
    );
  }

  void containerForSheet<T>({BuildContext? context, Widget? child}) {
    showCupertinoModalPopup<T>(
      context: context!,
      builder: (BuildContext context) => child!,
    ).then<void>((T? value) {});
  }


  Future<void> getAadharFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        aadharImage =  File(pickedFile.path);
        // imagePath = File(pickedFile.path) ;
        // filePath = imagePath!.path.toString();
      });
    }
  }

  Future<void> getAadharFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        aadharImage =  File(pickedFile.path);
        // imagePath = File(pickedFile.path) ;
        // filePath = imagePath!.path.toString();
      });
    }
  }

  uploadAadharFromCamOrGallary(BuildContext context) {
    containerForSheet<String>(
      context: context,
      child: CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
              "Camera",
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            onPressed: () {
              getAadharFromCamera();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              "Photo & Video Library",
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
            onPressed: () {
              getAadharFromGallery();
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          isDefaultAction: true,
          onPressed: () {
            // Navigator.pop(context, 'Cancel');
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        ),
      ),
    );
  }

    Widget imageUpload(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 5),
          child: Text("Image Upload",
            style: TextStyle(
                fontSize: 15,
                color:colors.primary,
            ),),
        ),
        imageAadhar(),
      ],
    );
  }

  Widget imageAadhar() {
    return Material(
      // elevation: 2,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () {
          uploadAadharFromCamOrGallary(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 10),
          child: Container(
            height: 80,
            width: MediaQuery.of(context).size.width /1.3,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: aadharImage != null ?
              Stack(
                children: [
                  Container(
                      width: double.infinity,
                      child: Image.file(aadharImage!, fit: BoxFit.fill)),
                  Align(alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            aadharImage = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(top: 10,right: 10),
                          decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Icon(
                            Icons.clear,color: Colors.white, size: 18,
                          ),
                        ),
                      ),),
                ],
              )
                  : Column(
                children: [
                  Icon(Icons.person, size: 30),
                  Text("Image Upload")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




