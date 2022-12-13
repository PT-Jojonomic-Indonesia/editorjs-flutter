import 'dart:convert';

import 'package:editorjs_flutter/src/model/EditorJSBlock.dart';
import 'package:flutter/material.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:flutter_html/flutter_html.dart';

typedef EditorJSComponentBuilder = Widget Function(
  BuildContext context,
  EditorJSBlock block,
);

class EditorJSView extends StatefulWidget {
  const EditorJSView({Key? key, required this.editorJSData}) : super(key: key);

  final String editorJSData;

  @override
  EditorJSViewState createState() => EditorJSViewState();
}

class EditorJSViewState extends State<EditorJSView> {
  final List<Widget> items = <Widget>[];
  EditorJSData? dataObject;

  @override
  void initState() {
    super.initState();
    _buildBlocks();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: items);
  }

  Color getColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('$hexCode', radix: 16));
  }

  void _buildBlocks() {
    setState(() {
      final defaultStyleMap = {
        'body': Style(margin: Margins.zero),
        'code': Style(
          backgroundColor: getColor('#33ff0000'),
          color: getColor('#ffff0000'),
          padding: EdgeInsets.all(5.0),
        ),
        'mark': Style(
          backgroundColor: getColor('#ffffff00'),
          padding: EdgeInsets.all(5.0),
        ),
      };
      dataObject = EditorJSData.fromJson(jsonDecode(widget.editorJSData));
      dataObject?.blocks?.forEach((element) {
        switch (element.type) {
          case "header":
            items.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Html(
                    data: "<h${element.data!.level!}>" +
                        element.data!.text! +
                        "</h${element.data!.level!}>",
                    style: defaultStyleMap,
                  ),
                ),
              ],
            ));
            break;
          case "paragraph":
            items.add(Html(
              data: element.data!.text,
              style: defaultStyleMap,
            ));
            break;
          case "list":
            String bullet = "\u2022 ";
            String? style = element.data!.style;
            int counter = 1;
            element.data!.items!.forEach((element) {
              if (style == 'ordered') {
                bullet = counter.toString();
                items.add(Row(children: [
                  Expanded(
                    child: Html(
                      data: bullet + element,
                      style: defaultStyleMap,
                    ),
                  )
                ]));
                counter++;
              } else {
                items.add(Row(
                  children: <Widget>[
                    Expanded(
                        child: Html(
                      data: bullet + element,
                      style: defaultStyleMap,
                    )),
                  ],
                ));
              }
            });
            break;
          case "delimiter":
            items.add(Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '***',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
                // Expanded(child: Divider(color: Colors.grey))
              ],
            ));
            break;
          case "image":
            items.add(Image.network(element.data!.file!.url!));
            break;
          default:
            items.add(Container(
              width: double.infinity,
              height: 64.0,
              color: Colors.black12,
              child: Center(child: Text('Unsupported Block')),
            ));
        }
        //Add space for each blocks
        items.add(const SizedBox(height: 10));
      });
    });
  }
}
