import 'dart:io';

import 'package:book/common/ReadSetting.dart';
import 'package:book/common/Screen.dart';
import 'package:book/common/text_composition.dart';
import 'package:book/entity/Book.dart';
import 'package:book/event/event.dart';
import 'package:book/model/ColorModel.dart';
import 'package:book/model/ReadModel.dart';
import 'package:book/model/ShelfModel.dart';
import 'package:book/store/Store.dart';
import 'package:book/view/book/ChapterView.dart';
import 'package:book/view/book/CoverReadView.dart';
import 'package:book/view/book/Menu.dart';
import 'package:book/view/book/ScrollViewBook.dart';
import 'package:book/view/system/BatteryView.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

class ReadBook extends StatefulWidget {
  final Book book;
  final bool reading;

  ReadBook(this.book, {this.reading = false});

  @override
  State<StatefulWidget> createState() {
    return _ReadBookState();
  }
}

class _ReadBookState extends State<ReadBook> with WidgetsBindingObserver {
  Widget body;
  ReadModel readModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ColorModel colorModel;
  TextComposition textComposition;

  @override
  void initState() {
    setUp();
    super.initState();
  }

  setUp() async {
    readModel = Store.value<ReadModel>(context);
    eventBus.on<ReadRefresh>().listen((event) {
      readModel.reSetPages();
      readModel.initPageContent(readModel.book.cur, true);
    });

    WidgetsBinding.instance.addObserver(this);
    eventBus.on<ZEvent>().listen((event) {
      move(event.off);
    });
    eventBus.on<OpenChapters>().listen((event) {
      _scaffoldKey.currentState.openDrawer();
    });
    colorModel = Store.value<ColorModel>(context);
    readModel.book = this.widget.book;
    readModel.getBookRecord();
    FlutterStatusbarManager.setFullscreen(true);
  }

  @override
  void dispose() async {
    super.dispose();
    readModel?.pageController?.dispose();
    readModel?.listController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    readModel.saveData();
  }

  @override
  Future<void> deactivate() async {
    print("deactuvate");
    super.deactivate();
    FlutterStatusbarManager.setFullscreen(false);
    await readModel.saveData();
    readModel.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (!Store.value<ShelfModel>(context)
              .exitsInBookShelfById(readModel.book.Id)) {
            await confirmAddToShelf(context);
          }
          return true;
        },
        child: Scaffold(
            key: _scaffoldKey,
            drawer: Drawer(
              child: ChapterView(),
            ),
            body: Store.connect<ReadModel>(
                builder: (context, ReadModel model, child) {
              return model.loadOk
                  ? Stack(
                      children: <Widget>[
                        // CoverReadView(),
                        //内容

                        // model.isPage
                        //     ?
                        GestureDetector(
                          child: PageView.builder(
                            controller: model.pageController,
                            physics: PageScrollPhysics(),
                            itemBuilder: (BuildContext context, int position) {
                              return model.allContent[position];
                            },
                            //条目个数
                            itemCount: model?.allContent?.length ?? 0,
                            onPageChanged: (page) => model.changeChapter(page),
                          ),
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (TapDownDetails details) {
                            readModel.tapPage(context, details);
                          },
                          // onHorizontalDragStart:
                          //     readModel.onHorizontalDragStart,
                          // onHorizontalDragUpdate:
                          //     readModel.onHorizontalDragUpdate,
                          // onHorizontalDragEnd:
                          //     readModel.onHorizontalDragEnd,
                        ),
                        // : Container(
                        //     width: Screen.width,
                        //     height: Screen.height,
                        //     child: Column(
                        //       children: [
                        //         SizedBox(
                        //           height: model.topSafeHeight,
                        //         ),
                        //         Container(
                        //           height: 30,
                        //           alignment: Alignment.centerLeft,
                        //           padding: EdgeInsets.only(left: 20),
                        //           child: Text(
                        //             model.readPages[model.cursor]
                        //                 .chapterName,
                        //             style: TextStyle(
                        //               fontSize: 12 / Screen.textScaleFactor,
                        //               color: colorModel.dark
                        //                   ? Color(0x8FFFFFFF)
                        //                   : Colors.black54,
                        //             ),
                        //             overflow: TextOverflow.ellipsis,
                        //           ),
                        //         ),
                        //         BookScrollView(),
                        //         Store.connect<ReadModel>(builder:
                        //             (context, ReadModel _readModel, child) {
                        //           return Container(
                        //             height: 30,
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 20),
                        //             child: Row(
                        //               children: <Widget>[
                        //                 BatteryView(
                        //                   electricQuantity:
                        //                       _readModel.electricQuantity,
                        //                 ),
                        //                 SizedBox(
                        //                   width: 4,
                        //                 ),
                        //                 Text(
                        //                   '${DateUtil.formatDate(DateTime.now(), format: DateFormats.h_m)}',
                        //                   style: TextStyle(
                        //                     fontSize:
                        //                         12 / Screen.textScaleFactor,
                        //                     color: colorModel.dark
                        //                         ? Color(0x8FFFFFFF)
                        //                         : Colors.black54,
                        //                   ),
                        //                 ),
                        //                 Spacer(),
                        //                 Text(
                        //                   '${_readModel.percent.toStringAsFixed(1)}%',
                        //                   style: TextStyle(
                        //                     fontSize:
                        //                         12 / Screen.textScaleFactor,
                        //                     color: colorModel.dark
                        //                         ? Color(0x8FFFFFFF)
                        //                         : Colors.black54,
                        //                   ),
                        //                   textAlign: TextAlign.center,
                        //                 ),
                        //                 // Expanded(child: Container()),
                        //               ],
                        //             ),
                        //           );
                        //         }),
                        //       ],
                        //     )),

                        //菜单
                        Offstage(offstage: !model.showMenu, child: Menu()),
                      ],
                    )
                  : Container();
            })));
  }

  Future confirmAddToShelf(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('是否加入本书'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Store.value<ShelfModel>(context)
                          .modifyShelf(this.widget.book);
                    },
                    child: Text('确定')),
                TextButton(
                    onPressed: () {
                      readModel.sSave = false;

                      Store.value<ShelfModel>(context)
                          .delLocalCache([this.widget.book.Id]);
                      Navigator.pop(context);
                    },
                    child: Text('取消')),
              ],
            ));
  }

  void move(int off) {
    var widgetsBinding = WidgetsBinding.instance;

    widgetsBinding.addPostFrameCallback((callback) {
      readModel.pageController.jumpToPage(off);
    });
  }
  // void move(bool isPage, double offset) {
  //   var widgetsBinding = WidgetsBinding.instance;
  //
  //   widgetsBinding.addPostFrameCallback((callback) {
  //     if (isPage) {
  //       readModel.pageController.jumpToPage(1);
  //     } else {
  //       if (offset == 0.0) {
  //         readModel.listController
  //             .jumpTo((readModel.ladderH[readModel.cursor - 1]));
  //       } else {
  //         readModel.listController.jumpTo(offset);
  //       }
  //     }
  //   });
  // }
}
