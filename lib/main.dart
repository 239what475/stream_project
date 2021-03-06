import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Divider _divider() {
    return const Divider(
      height: 0.6,
      color: Color(0xffacaeba),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _BasePage(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[200],
                    blurRadius: 5.0, //阴影模糊程度
                    spreadRadius: 5.0 //阴影扩散程度
                    )
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                // TODO: 两个输入之后的存储上传逻辑没写
                TitleInputField(),
                _divider(),
                BodyInputField(),
                // TODO: 图片选择之后，长按图片有删除功能，最多四张，图片的临时存储和上传没写
                // TODO: 图片选择的自定义界面中，有一张图片是放在android/src/drawable中的
                ImagesGridView(),
                // TODO: 网络请求获取tag没写
                TagView(),
                _divider(),
                // TODO: 提交没写
                SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            '提交',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff303c66),
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class TagView extends StatefulWidget {
  @override
  _TagViewState createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  String tab;

  _showTags(BuildContext context) async {
    var result = await showModalBottomSheet<String>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => TabGridView(
        tab: tab,
      ),
    );
    if (result != null)
      setState(() {
        tab = result;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Builder(
        builder: (_) => InkWell(
          onTap: () async => await _showTags(context),
          child: Text(
            tab == null ? '+添加标签（必须添加一个）' : '#$tab （点击更改标签）',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff303c66),
            ),
          ),
        ),
      ),
    );
  }
}

class TabGridView extends StatefulWidget {
  final String tab;

  const TabGridView({Key key, this.tab}) : super(key: key);

  @override
  _TabGridViewState createState() => _TabGridViewState();
}

class _TabGridViewState extends State<TabGridView>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  String currentTab;

  // TODO: 网络请求 tabs  还有 部门介绍
  var list = ['单纯吐槽', '天外天', '教务处', '学工部', '后勤保障处'];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200))
          ..forward();
    currentTab = widget.tab;
  }

  void updateGroupValue(String v) {
    setState(() {
      currentTab = v;
      _animationController.forward(from: 0.0);
    });
  }

  TextButton _confirmButton({VoidCallback onPressed}) => TextButton(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all(Size(0, 0)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
      ),
      onPressed: onPressed,
      child: const Text(
        '确定',
        style: TextStyle(
          color: Color(0xff303c66),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ));

  ActionChip _tagChip({String text}) => ActionChip(
        backgroundColor:
            text == currentTab ? Color(0xff62677c) : Color(0xffeeeeee),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: text == currentTab ? Colors.white : Color(0xff62677c),
          ),
        ),
        onPressed: () {
          updateGroupValue(text);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0))),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 25),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _confirmButton(onPressed: null),
              ),
              const Text(
                '添加标签',
                style: TextStyle(
                  color: Color(0xff303c66),
                  fontSize: 16,
                ),
              ),
              _confirmButton(
                  onPressed: () => Navigator.of(context).pop(currentTab))
            ],
          ),
          if (currentTab != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                currentTab + ': 部门介绍',
                style: TextStyle(
                  color: Color(0xff303c66),
                  fontSize: 10,
                ),
              ),
            ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            children: List.generate(list.length, (index) {
              return list[index] == currentTab
                  ? FadeTransition(
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .animate(_animationController),
                      child: _tagChip(text: list[index]),
                    )
                  : _tagChip(text: list[index]);
            }),
          )
        ],
      ),
    );
  }
}

class TitleInputField extends StatefulWidget {
  @override
  _TitleInputFieldState createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  TextEditingController titleController;
  String titleCounter;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    titleCounter = '0/200';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                buildCounter: null,
                controller: titleController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                    color: Color(0xff303c66),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                minLines: 1,
                maxLines: 10,
                decoration: InputDecoration.collapsed(
                  hintStyle: TextStyle(
                      color: Color(0xffd0d1d6),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  hintText: '输入标题',
                ),
                onChanged: (text) {
                  titleCounter = '${text.characters.length}/200';
                  setState(() {});
                },
                inputFormatters: [
                  _CustomizedLengthTextInputFormatter(200),
                ],
              ),
            ),
            Container(width: 3),
            Text(
              titleCounter,
              style: TextStyle(
                color: Color(0xffd0d1d6),
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BodyInputField extends StatefulWidget {
  @override
  _BodyInputFieldState createState() => _BodyInputFieldState();
}

class _BodyInputFieldState extends State<BodyInputField> {
  TextEditingController bodyController;
  String bodyCounter;

  @override
  void initState() {
    super.initState();
    bodyController = TextEditingController();
    bodyCounter = '0/200';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          TextField(
            controller: bodyController,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            minLines: 6,
            maxLines: 20,
            style: TextStyle(
                color: Color(0xff000000),
                fontWeight: FontWeight.normal,
                fontSize: 13),
            decoration: InputDecoration.collapsed(
              hintStyle: TextStyle(
                color: Color(0xffd0d1d6),
                fontSize: 11,
              ),
              hintText: '问题详情...',
            ),
            onChanged: (text) {
              bodyCounter = '${text.characters.length}/200';
              setState(() {});
            },
            inputFormatters: [
              /// 输入的内容长度为 10 位
              _CustomizedLengthTextInputFormatter(200),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                bodyCounter,
                style: TextStyle(
                  color: Color(0xffd0d1d6),
                  fontSize: 10,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ImagesGridView extends StatefulWidget {
  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<ImagesGridView> {
  List<ByteData> images = List<ByteData>();
  List<Asset> resultList = List<Asset>();
  int maxImage = 4;

  //TODO: 这里选完图片以后的逻辑没搞
  //TODO: https://sh1d0w.github.io/multi_image_picker/#/gettingstarted 具体见这里
  Future<void> loadAssets() async {
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        selectedAssets: resultList,
        enableCamera: true,
        maxImages: maxImage,
        materialOptions: MaterialOptions(
          actionBarTitle: "图库",
          allViewTitle: "全部的照片",
          actionBarColor: "#f7f7f8",
          actionBarTitleColor: "#303c66",
          lightStatusBar: true,
          statusBarColor: '#f7f7f8',
          startInAllView: false,
          selectCircleStrokeColor: "#f7f7f8",
          selectionLimitReachedText: "足够了.",
          okButtonDrawable: "@drawable/ok",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      print('error:!!!!!!!!!!' + error);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    images.clear();
    for (var image in resultList) {
      var data = await image.getThumbByteData(300, 300);
      images.add(data);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount:
            images.length == maxImage ? images.length : images.length + 1,
        itemBuilder: (context, index) => index == images.length
            ? _ImagePickerWidget(
                onTap: loadAssets,
              )
            : InkWell(
                onLongPress: () async {
                  var result = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('是否要删除'),
                            actions: [
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('cancel');
                                  },
                                  child: Text('取消')),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop('ok');
                                  },
                                  child: Text('是的')),
                            ],
                          ));

                  if (result == 'ok')
                    setState(() {
                      images.removeAt(index);
                    });
                },
                child: _MyImage(image: images[index].buffer.asUint8List())),
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}

class _MyImage extends StatelessWidget {
  const _MyImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        image: MemoryImage(image),
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  const _ImagePickerWidget({
    Key key,
    this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: DottedBorder(
          borderType: BorderType.Rect,
          color: Color(0xffb5b7c5),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_sharp,
                  color: Color(0xffb5b7c5),
                ),
                Text(
                  '添加图片',
                  style: TextStyle(
                    color: Color(0xffd0d1d6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BasePage extends StatelessWidget {
  final Widget body;

  const _BasePage({this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: Container(
        color: Color(0xfff7f7f8),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                centerTitle: true,
                title: Text(
                  '新建问题',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff303c66),
                  ),
                ),
                brightness: Brightness.light,
                elevation: 0,
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back,
                    color: Color(0XFF62677B),
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
            body: Container(
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

/// 自定义兼容中文拼音输入法长度限制输入框
/// https://www.jianshu.com/p/d2c50b9271d3
class _CustomizedLengthTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  _CustomizedLengthTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.isComposingRangeValid) return newValue;
    return LengthLimitingTextInputFormatter(maxLength)
        .formatEditUpdate(oldValue, newValue);
  }
}
