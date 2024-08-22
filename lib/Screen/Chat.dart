import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Model/Model.dart';

class Chat extends StatefulWidget {
  final String? id, status;
  const Chat({Key? key, this.id, this.status}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

StreamController<String>? chatstreamdata;

class _ChatState extends State<Chat> {
  TextEditingController msgController = new TextEditingController();
  List<File> files = [];
  List<Model> chatList = [];
  late Map<String?, String> downloadlist;
  String _filePath = "";

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    downloadlist = new Map<String?, String>();
    CUR_TICK_ID = widget.id;
    FlutterDownloader.registerCallback(downloadCallback);
    setupChannel();

    getMsg();
  }

  @override
  void dispose() {
    CUR_TICK_ID = '';
    if (chatstreamdata != null) chatstreamdata!.sink.close();

    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'CHAT')!, context),
      body: Column(
        children: <Widget>[buildListMessage(), msgRow()],
      ),
    );
  }

  void setupChannel() {
    chatstreamdata = StreamController<String>(); //.broadcast();
    chatstreamdata!.stream.listen((response) {
      setState(() {
        final res = json.decode(response);
        Model message;
        String mid;

        message = Model.fromChat(res["data"]);

        chatList.insert(0, message);
        files.clear();
      });
    });
  }

  void insertItem(String response) {
    if (chatstreamdata != null) chatstreamdata!.sink.add(response);
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, index) => msgItem(index, chatList[index]),
        itemCount: chatList.length,
        reverse: true,
        controller: _scrollController,
      ),
    );
  }

  Widget msgItem(int index, Model message) {
    if (message.uid == context.read<SettingProvider>().userId) {
      //Own message
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
        ],
      );
    } else {
      //Other's message
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
  }

  Widget MsgContent(int index, Model message) {
    //String filetype = message.attachment_mime_type.trim();

    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: message.uid == settingsProvider.userId
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        message.uid == settingsProvider.userId
            ? Container()
            : Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ClipOval(child:
                    // message.profile == null || message.profile.isEmpty? Image.asset("assets/images/placeholder.png",width: 25, height: 25,)
                    //     :FadeInImage.assetNetwork(
                    //   image: message.profile,
                    //   placeholder: "assets/images/placeholder.png",
                    //   width: 25,
                    //   height: 25,
                    //   fit: BoxFit.cover,
                    // )),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(capitalize(message.name!),
                          style:
                              TextStyle(color: colors.primary, fontSize: 12)),
                    )
                  ],
                ),
              ),
        ListView.builder(
            itemBuilder: (context, index) {
              return attachItem(message.attach!, index, message);
            },
            itemCount: message.attach!.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true),
        message.msg != null && message.msg!.isNotEmpty
            ? Card(
                elevation: 0.0,
                color: message.uid == settingsProvider.userId
                    ? Theme.of(context).colorScheme.fontColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    crossAxisAlignment: message.uid == settingsProvider.userId
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${message.msg}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.black)),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5),
                        child: Text(message.date!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: 9)),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void _requestDownload(String? url, String? mid) async {
    bool checkpermission = await Checkpermission();
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        _filePath = target.path.toString();
      } else {
        Directory? downloadsDirectory =
            await (DownloadsPathProvider.downloadsDirectory);
        _filePath = downloadsDirectory!.path.toString();
      }

      String fileName = url!.substring(url.lastIndexOf("/") + 1);
      File file = new File(_filePath + "/" + fileName);
      bool hasExisted = await file.exists();

      if (downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query:
                "SELECT status FROM task WHERE task_id=${downloadlist[mid]}");

        if (tasks == 4 || tasks == 5) downloadlist.remove(mid);
      }

      if (hasExisted) {
        final _openFile = await OpenFilex.open(_filePath + "/" + fileName);
      } else if (downloadlist.containsKey(mid)) {
        setSnackbar(getTranslated(context, 'Downloading')!);
      } else {
        setSnackbar(getTranslated(context, 'Downloading')!);
        final taskid = await FlutterDownloader.enqueue(
            url: url,
            savedDir: _filePath,
            headers: {"auth": "test_for_sql_encoding"},
            showNotification: true,
            openFileFromNotification: true);

        setState(() {
          downloadlist[mid] = taskid.toString();
        });
      }
    }
  }

  Future<bool> Checkpermission() async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare();
        return true;
      }
    } else {
      FileDirectoryPrepare();
      return true;
    }
    return false;
  }

  Future<Null> FileDirectoryPrepare() async {
    // _filePath = (await _findLocalPath()) +
    //     Platform.pathSeparator +
    //     'Download'; //"${StringsRes.mainappname}";

    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      _filePath = target.path.toString();
    } else {
      Directory? downloadsDirectory =
          await (DownloadsPathProvider.downloadsDirectory);
      _filePath = downloadsDirectory!.path.toString();
    }
  }

  _imgFromGallery() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendMessage(String message) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);

    setState(() {
      msgController.text = "";
    });
    var request = http.MultipartRequest("POST", sendMsgApi);
    request.headers.addAll(headers);
    request.fields[USER_ID] = settingsProvider.userId!;
    request.fields[TICKET_ID] = widget.id!;
    request.fields[USER_TYPE] = USER;
    request.fields[MESSAGE] = message;

    if (files != null) {
      for (int i = 0; i < files.length; i++) {
        var pic = await http.MultipartFile.fromPath(ATTACH, files[i].path);
        request.files.add(pic);
      }
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var getdata = json.decode(responseString);
    bool error = getdata["error"];
    String? msg = getdata['message'];
    var data = getdata["data"];
    if (!error) {
      insertItem(responseString);
    }
  }

  Future<void> getMsg() async {
    try {
      var data = {
        TICKET_ID: widget.id,
      };

      Response response = await post(getMsgApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          chatList =
              (data as List).map((data) => new Model.fromChat(data)).toList();
        } else {
          if (msg != "Ticket Message(s) does not exist") setSnackbar(msg!);
        }
        if (mounted) setState(() {});
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
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

  msgRow() {
    return widget.status != "4"
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              color: Theme.of(context).colorScheme.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _imgFromGallery();
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.fontColor,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      maxLines: null,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.lightBlack),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      if (msgController.text.trim().length > 0 ||
                          files.length > 0) {
                        sendMessage(msgController.text.trim());
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.fontColor,
                      size: 18,
                    ),
                    backgroundColor: colors.primary,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget attachItem(List<attachment> attach, int index, Model message) {
    String? file = attach[index].media;
    String? type = attach[index].type;
    String icon;
    if (type == "video")
      icon = "assets/images/video.png";
    else if (type == "document")
      icon = "assets/images/doc.png";
    else if (type == "spreadsheet")
      icon = "assets/images/sheet.png";
    else
      icon = "assets/images/zip.png";
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(this.context, listen: false);

    return file == null
        ? Container()
        : Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Card(
                //margin: EdgeInsets.only(right: message.sender_id == myid ? 10 : 50, left: message.sender_id == myid ? 50 : 10, bottom: 10),
                elevation: 0.0,
                color: message.uid == settingsProvider.userId
                    ? Theme.of(context).colorScheme.fontColor.withOpacity(0.1)
                    : Theme.of(context).colorScheme.white,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: message.uid == settingsProvider.userId
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      //_messages[index].issend ? Container() : Center(child: SizedBox(height:20,width: 20,child: new CircularProgressIndicator(backgroundColor: ColorsRes.secondgradientcolor,))),

                      GestureDetector(
                        onTap: () {
                          _requestDownload(attach[index].media, message.id);
                        },
                        child: type == "image"
                            ? Image.network(file,
                                width: 250,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    erroWidget(150))
                            : Image.asset(
                                icon,
                                width: 100,
                                height: 100,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(message.date!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontSize: 9)),
                ),
              ),
            ],
          );
  }
}
