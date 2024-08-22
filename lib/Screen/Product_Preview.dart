import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import '../Helper/vimeoplayer.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Helper/Session.dart';
import 'HomePage.dart';

class ProductPreview extends StatefulWidget {
  final int? pos, secPos, index;
  final bool? list, from;
  final Size? screenSize;
  final String? id, video, videoType;
  final List<String?>? imgList;

  const ProductPreview(
      {Key? key,
      this.pos,
      this.secPos,
      this.index,
      this.list,
      this.id,
      this.imgList,
      this.screenSize,
      this.video,
      this.videoType,
      this.from})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StatePreview();
}

class StatePreview extends State<ProductPreview> {
  late PageController pageController = PageController(
    initialPage: widget.pos!,
  );

  late List<ScrollController> scrollControllers = [];

  late int curPos = widget.pos!;
  // YoutubePlayerController? _controller;
  VideoPlayerController? _videoController;

  void initScrollControllers() {
    double initialPosition = widget.screenSize!.width * (0.4);

    widget.imgList!.forEach((element) {
      scrollControllers
          .add(ScrollController(initialScrollOffset: initialPosition));
    });
  }

  @override
  void initState() {
    super.initState();
    initScrollControllers();

    // if (widget.from! && widget.videoType == "youtube") {
    //   _controller = YoutubePlayerController(
    //     initialVideoId: YoutubePlayer.convertUrlToId(widget.video!)!,
    //     flags: YoutubePlayerFlags(
    //         autoPlay: true,
    //         mute: false,
    //         forceHD: false,
    //         loop: false,
    //         disableDragSeek: true),
    //   );
    // } else
      if (widget.from! &&
        widget.videoType == "self_hosted" &&
        widget.video != "") {
      _videoController = VideoPlayerController.network(
        widget.video!,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      _videoController!.addListener(() {
        setState(() {});
      });
      _videoController!.setLooping(false);
      _videoController!.initialize();
    }
    curPos = widget.pos!;
  }

  @override
  void dispose() {
    super.dispose();
    // if (_controller != null) _controller!.dispose();
    if (_videoController != null) _videoController!.dispose();
  }

  void onHorizontalDragStart(DragStartDetails dragStartDetails) {
    //print();
    // print(MediaQuery.of(context).size,);
  }

  void onHorizontalDragDown(DragDownDetails dragDownDetails) {
    //print();
  }

  void onHorizontalDragCancel() {
    //print();
  }

  void onHorizontalDragEnd(DragEndDetails dragEndDetails) {
    //print();
  }

  void onHorizontalDragUpdate(DragUpdateDetails dragUpdateDetails) {
    if (dragUpdateDetails.primaryDelta! != 0.0) {
      double value =
          scrollControllers[curPos].offset - dragUpdateDetails.primaryDelta!;

      //if user has scrolled to the forward side end of the image
      //then it's time to scroll page view
      if (value >= scrollControllers[curPos].position.maxScrollExtent) {
        double pageControllerValue =
            pageController.offset - dragUpdateDetails.primaryDelta!;

        if (curPos != (widget.imgList!.length - 1)) {
          pageController.jumpTo(pageControllerValue);
        }
      } else {
        if (value < 0.0) {
          //if user has scrolled to the backword side end of the image
          //then it's time to scroll page view
          double pageControllerValue =
              pageController.offset - dragUpdateDetails.primaryDelta!;
          if (curPos != 0) {
            pageController.jumpTo(pageControllerValue);
          }
        } else {
          scrollControllers[curPos].jumpTo(value);
        }
      }
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    // if (_controller != null) _controller!.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    print("data is ${widget.index!}");
    print("section pos is ${widget.secPos!}");
    print("length is ${sectionList[widget.secPos!].productList!.length}");
    return Scaffold(
        body: Hero(
      tag: widget.list!
          ? "${widget.id}"
          : "${widget.secPos}${widget.index}",
      child: Stack(
        children: <Widget>[
          widget.video == ""
              ? Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onHorizontalDragStart: onHorizontalDragStart,
                        onHorizontalDragCancel: onHorizontalDragCancel,
                        onHorizontalDragDown: onHorizontalDragDown,
                        onHorizontalDragEnd: onHorizontalDragEnd,
                        onHorizontalDragUpdate: onHorizontalDragUpdate,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * (1.0),
                          child: PageView.builder(
                            onPageChanged: (index) {
                              setState(() {
                                curPos = index;
                              });
                            },
                            controller: pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.imgList!.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                controller: scrollControllers[index],
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * (1.8),
                                  child: Image.network(
                                    widget.imgList![index]!,
                                    fit: BoxFit.fitHeight,
                                    alignment: Alignment.center,
                                  ),

                                  // PhotoViewGallery.builder(
                                  //   scrollPhysics:
                                  //       const BouncingScrollPhysics(),
                                  //   builder: (BuildContext context, int index) {
                                  //     print("ab testing 1");
                                  //     return PhotoViewGalleryPageOptions(
                                  //         initialScale:
                                  //             PhotoViewComputedScale.contained *
                                  //                 0.9,
                                  //         tightMode: false,
                                  //         minScale:
                                  //             PhotoViewComputedScale.contained *
                                  //                 1,
                                  //         maxScale:
                                  //             PhotoViewComputedScale.contained *
                                  //                 1,
                                  //         imageProvider: NetworkImage(
                                  //             widget.imgList![index]!));
                                  //   },
                                  //   itemCount: widget.imgList!.length,
                                  //   loadingBuilder: (context, event) => Center(
                                  //     child: Container(
                                  //       width: 20.0,
                                  //       height: 20.0,
                                  //       child: CircularProgressIndicator(
                                  //         value: event == null
                                  //             ? 0
                                  //             : event.cumulativeBytesLoaded /
                                  //                 event.expectedTotalBytes!,
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   backgroundDecoration: BoxDecoration(
                                  //       color: Theme.of(context)
                                  //           .colorScheme
                                  //           .white),
                                  //   pageController:
                                  //       PageController(initialPage: curPos!),
                                  //   onPageChanged: (index) {
                                  //     if (mounted)
                                  //       setState(() {
                                  //         curPos = index;
                                  //       });
                                  //   },
                                  // ),
                                  // NetworkImage(widget.imgList![index]!)

                                  // Image.asset(
                                  //   widget.imgList![index]!,
                                  //   fit: BoxFit.fitHeight,
                                  //   alignment: Alignment.center,
                                  // ),
                                ),
                              );
                              //   ImageScrollContainer(
                              //     index: index,
                              //     scrollController: scrollControllers[index],
                              //     imgList,
                              //   );
                            },
                          ),
                        ),
                      ),
                    ),
                    curPos != (widget.imgList!.length - 1)
                        ? Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: IconButton(
                                onPressed: () {
                                  pageController.nextPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                )),
                          )
                        : SizedBox(),
                    curPos != 0
                        ? Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              onPressed: () {
                                pageController.previousPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              },
                              icon: Icon(Icons.arrow_back_ios),
                            ))
                        : SizedBox(),
                  ],
                )

              //  Container(
              //     child: PhotoViewGallery.builder(
              //     scrollPhysics: const BouncingScrollPhysics(),
              //     builder: (BuildContext context, int index) {
              //       print("ab testing 1");
              //       return PhotoViewGalleryPageOptions(
              //           initialScale: PhotoViewComputedScale.contained * 0.9,
              //           tightMode: false,
              //           minScale: PhotoViewComputedScale.contained * 1,
              //           maxScale: PhotoViewComputedScale.contained * 1,
              //           imageProvider: NetworkImage(widget.imgList![index]!));
              //     },
              //     itemCount: widget.imgList!.length,
              //     loadingBuilder: (context, event) => Center(
              //       child: Container(
              //         width: 20.0,
              //         height: 20.0,
              //         child: CircularProgressIndicator(
              //           value: event == null
              //               ? 0
              //               : event.cumulativeBytesLoaded /
              //                   event.expectedTotalBytes!,
              //         ),
              //       ),
              //     ),
              //     backgroundDecoration:
              //         BoxDecoration(color: Theme.of(context).colorScheme.white),
              //     pageController: PageController(initialPage: curPos!),
              //     onPageChanged: (index) {
              //       if (mounted)
              //         setState(() {
              //           curPos = index;
              //         });
              //     },
              //   ))
              : PageView.builder(
                  itemCount: widget.imgList!.length,
                  controller: PageController(initialPage: curPos),
                  onPageChanged: (index) {
                    if (mounted)
                      setState(() {
                        curPos = index;
                      });
                  },
                  itemBuilder: (BuildContext context, int index) {
                    print("first testing 1");
                    if (index == 1 &&
                        widget.from! &&
                        widget.videoType != null &&
                        widget.video != "") {
                      // if (widget.videoType == "youtube") {
                      //   _controller!.reset();
                      //   print("testing1");
                      //   return SafeArea(
                      //     child: YoutubePlayer(
                      //       controller: _controller!,
                      //       showVideoProgressIndicator: true,
                      //       progressIndicatorColor:
                      //           Theme.of(context).colorScheme.fontColor,
                      //       liveUIColor: colors.primary,
                      //     ),
                      //   );
                      // } else
                        if (widget.videoType == "vimeo") {
                        print("testing2");
                        List<String> id =
                            widget.video!.split("https://vimeo.com/");

                        return SafeArea(
                            child: Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          child: Center(
                            child: VimeoPlayer(
                              id: id[1],
                              autoPlay: true,
                              looping: false,
                            ),
                          ),
                        ));
                      } else {
                        print("testing3");
                        return _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: <Widget>[
                                    VideoPlayer(
                                      _videoController!,
                                    ),
                                    _ControlsOverlay(
                                        controller: _videoController),
                                    VideoProgressIndicator(_videoController!,
                                        allowScrubbing: true),
                                  ],
                                ),
                              )
                            : Container();
                      }
                    }
                    print("testing4");
                    // return Container();
                    return PhotoView(
                      backgroundDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.white),
                      initialScale: PhotoViewComputedScale.contained * 0.9,
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      gaplessPlayback: false,
                      customSize: MediaQuery.of(context).size,
                      imageProvider: NetworkImage(widget.imgList![index]!),
                    );
                  }),
          Positioned(
            top: 34.0,
            left: 5.0,
            child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: shadow(),
                  child: Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                )),
          ),
          Positioned(
              bottom: 10.0,
              left: 25.0,
              right: 25.0,
              child: SelectedPhoto(
                numberOfDots: widget.imgList!.length,
                photoIndex: curPos,
              )),
        ],
      ),
    ));
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller!.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Theme.of(context).colorScheme.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Theme.of(context).colorScheme.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller!.value.isPlaying
                ? controller!.pause()
                : controller!.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller!.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller!.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller!.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

class SelectedPhoto extends StatelessWidget {
  final int? numberOfDots;
  final int? photoIndex;

  SelectedPhoto({this.numberOfDots, this.photoIndex});

  Widget _inactivePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 3.0, end: 3.0),
        child: Container(
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4.0)),
        ),
      ),
    );
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];
    for (int i = 0; i < numberOfDots!; i++) {
      dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
    }
    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}

// class ImageScrollContainer extends StatefulWidget {
//   final int index;
//   final ScrollController scrollController;
//   List<String?> images;

//   ImageScrollContainer(
//       {Key? key,
//       required this.index,
//       required this.scrollController,
//       required this.images})
//       : super(key: key);

//   @override
//   _ImageScrollContainerState createState() => _ImageScrollContainerState();
// }

// class _ImageScrollContainerState extends State<ImageScrollContainer>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return SingleChildScrollView(
//       controller: widget.scrollController,
//       physics: const NeverScrollableScrollPhysics(),
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         width: MediaQuery.of(context).size.width * (1.8),
//         child: Image.asset(
//           images[widget.index],
//           fit: BoxFit.fitHeight,
//           alignment: Alignment.center,
//         ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
