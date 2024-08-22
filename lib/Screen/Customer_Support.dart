import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/AppBtn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';

import 'Chat.dart';
import '../Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../Helper/Constant.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';

class CustomerSupport extends StatefulWidget {
  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport>
    with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  Animation? buttonSqueezeanimation;
  late AnimationController buttonController;
  bool _isNetworkAvail = true;
  List<Model> typeList = [];
  List<Model> ticketList = [];
  List<Model> statusList = [];
  List<Model> tempList = [];
  String? type, email, title, desc, status, id;
  FocusNode? nameFocus, emailFocus, descFocus;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final descController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool edit = false, show = false;
  bool fabIsVisible = true;
  ScrollController controller = new ScrollController();
  int offset = 0;
  int total = 0, curEdit = -1;
  bool isLoadingmore = true;

  @override
  void initState() {
    super.initState();
    statusList = [
      Model(id: "3", title: "Resolved"),
      Model(id: "5", title: "Reopen")
    ];
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
    controller = ScrollController();
    controller.addListener(() {
      setState(() {
        fabIsVisible =
            controller.position.userScrollDirection == ScrollDirection.forward;

        if (controller.offset >= controller.position.maxScrollExtent &&
            !controller.position.outOfRange) {
          isLoadingmore = true;

          if (offset < total) getTicket();
        }
      });
    });
    getType();
    getTicket();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    descController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getSimpleAppBar(getTranslated(context, 'CUSTOMER_SUPPORT')!, context),
      floatingActionButton: AnimatedOpacity(
        child: FloatingActionButton(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          onPressed: () async {
            setState(() {
              edit = false;
              show = !show;

              clearAll();
            });
          },
          heroTag: null,
        ),
        duration: Duration(milliseconds: 100),
        opacity: fabIsVisible ? 1 : 0,
      ),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer(context)
              : Stack(children: [
                  SingleChildScrollView(
                      controller: controller,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            show
                                ? Card(
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          setType(),
                                          setEmail(),
                                          setTitle(),
                                          setDesc(),
                                          Row(
                                            children: [
                                              edit
                                                  ? statusDropDown()
                                                  : Container(),
                                              Spacer(),
                                              sendButton(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ))
                                : Container(),
                            ticketList.length > 0
                                ? ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            Divider(),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: (offset < total)
                                        ? ticketList.length + 1
                                        : ticketList.length,
                                    itemBuilder: (context, index) {
                                      return (index == ticketList.length &&
                                              isLoadingmore)
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ticketItem(index);
                                    })
                                : Container(
                                    height: deviceHeight! -
                                        kToolbarHeight -
                                        MediaQuery.of(context).padding.top,
                                    child: getNoItem(context))
                          ],
                        ),
                      )),
                  showCircularProgress(_isProgress, colors.primary),
                ])
          : noInternet(context),
    );
  }

  Widget setType() {
    return DropdownButtonFormField(
      iconEnabledColor: Theme.of(context).colorScheme.fontColor,
      isDense: true,
      hint: new Text(
        getTranslated(context, 'SELECT_TYPE')!,
        style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
      ),
      decoration: InputDecoration(
        filled: true,
        isDense: true,
        fillColor: Theme.of(context).colorScheme.lightWhite,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.fontColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      value: type,
      style: Theme.of(context)
          .textTheme
          .subtitle2!
          .copyWith(color: Theme.of(context).colorScheme.fontColor),
      onChanged: (String? newValue) {
        if (mounted)
          setState(() {
            type = newValue;
          });
      },
      items: typeList.map((Model user) {
        return DropdownMenuItem<String>(
          value: user.id,
          child: Text(
            user.title!,
          ),
        );
      }).toList(),
    );
  }

  void validateAndSubmit() async {
    if (type == null)
      setSnackbar('Please Select Type');
    else if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      sendRequest();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController.reverse();
      });
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
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
          _fieldFocusChange(context, emailFocus!, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setTitle() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        controller: nameController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) =>
            validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String? value) {
          title = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'TITLE'),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setDesc() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        focusNode: descFocus,
        controller: descController,
        maxLines: null,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) =>
            validateField(val!, getTranslated(context, 'FIELD_REQUIRED')),
        onSaved: (String? value) {
          desc = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'DESCRIPTION'),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<void> getType() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response = await post(getTicketTypeApi, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          typeList = (data as List)
              .map((data) => new Model.fromSupport(data))
              .toList();
        } else {
          setSnackbar(msg!);
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  Future<void> getTicket() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
        };

        Response response =
            await post(getTicketApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          total = int.parse(getdata["total"]);

          if ((offset) < total) {
            tempList.clear();
            var data = getdata["data"];
            tempList = (data as List)
                .map((data) => new Model.fromTicket(data))
                .toList();

            ticketList.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          if (msg != "Ticket(s) does not exist") setSnackbar(msg!);
          isLoadingmore = false;
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
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

  Widget sendButton() {
    return SimBtn(
        size: 0.4,
        title: getTranslated(context, 'SEND'),
        onBtnSelected: () {
          validateAndSubmit();
        });
  }

  Future<void> sendRequest() async {
    if (mounted)
      setState(() {
        _isProgress = true;
      });

    try {
      var data = {
        USER_ID: CUR_USERID,
        SUB: title,
        DESC: desc,
        TICKET_TYPE: type,
        EMAIL: email,
      };
      if (edit) {
        data[TICKET_ID] = id;
        data[STATUS] = status;
      }

      Response response = await post(edit ? editTicketApi : addTicketApi,
              body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          if (mounted)
            setState(() {
              if (edit)
                ticketList[curEdit] = Model.fromTicket(data[0]);
              else
                ticketList.add(Model.fromTicket(data[0]));
              edit = false;
              _isProgress = false;
              clearAll();
            });
        }
        setSnackbar(msg);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }
  }

  clearAll() {
    type = null;
    email = null;
    title = null;
    desc = null;
    emailController.text = "";
    nameController.text = "";
    descController.text = "";
  }

  Widget ticketItem(int index) {
    Color back;
    String? status = ticketList[index].status;
    //1 -> pending, 2 -> opened, 3 -> resolved, 4 -> closed, 5 -> reopened
    if (status == "1") {
      back = Colors.orange;
      status = "Pending";
    } else if (status == "2") {
      back = Colors.cyan;
      status = "Opened";
    } else if (status == "3") {
      back = Colors.green;
      status = "Resolved";
    } else if (status == "5") {
      back = Colors.cyan;
      status = "Reopen";
    } else {
      back = Colors.red;
      status = "Close";
    }
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  id: ticketList[index].id,
                  status: ticketList[index].status,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Type : " + ticketList[index].type!),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                        color: back,
                        borderRadius:
                            new BorderRadius.all(const Radius.circular(4.0))),
                    child: Text(
                      status,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.white),
                    ),
                  )
                ],
              ),
              Text(getTranslated(context, "TITLE")! +
                  " : " +
                  ticketList[index].title!),
              Text(
                getTranslated(context, "DESCRIPTION")! +
                    " : " +
                    ticketList[index].desc!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(getTranslated(context, "DATE")! +
                  " : " +
                  ticketList[index].date!),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    GestureDetector(
                        child: Container(
                          margin: EdgeInsetsDirectional.only(start: 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.lightWhite,
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(4.0),
                            ),
                          ),
                          child: Text(
                            getTranslated(context, 'EDIT')!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 11),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            edit = true;
                            show = true;
                            curEdit = index;
                            id = ticketList[index].id;
                            emailController.text = ticketList[index].email!;
                            nameController.text = ticketList[index].title!;
                            descController.text = ticketList[index].desc!;
                            type = ticketList[index].typeId;
                          });
                        }),
                    GestureDetector(
                        child: Container(
                          margin: EdgeInsetsDirectional.only(start: 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.lightWhite,
                              borderRadius: new BorderRadius.all(
                                  const Radius.circular(4.0))),
                          child: Text(
                            getTranslated(context, 'CHAT')!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 11),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(
                                  id: ticketList[index].id,
                                  status: ticketList[index].status,
                                ),
                              ));
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  statusDropDown() {
    return Container(
      width: MediaQuery.of(context).size.width * .4,
      child: DropdownButtonFormField(
        iconEnabledColor: Theme.of(context).colorScheme.fontColor,
        isDense: true,
        hint: new Text(
          getTranslated(context, 'SELECT_TYPE')!,
          style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
        ),
        decoration: InputDecoration(
          filled: true,
          isDense: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        value: status,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: Theme.of(context).colorScheme.fontColor),
        onChanged: (String? newValue) {
          if (mounted)
            setState(() {
              status = newValue;
            });
        },
        items: statusList.map((Model user) {
          return DropdownMenuItem<String>(
            value: user.id,
            child: Text(
              user.title!,
            ),
          );
        }).toList(),
      ),
    );
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
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }
}
