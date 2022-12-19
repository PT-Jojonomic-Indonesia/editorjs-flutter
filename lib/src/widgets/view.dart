import 'dart:convert';

import 'package:code_text_field/code_text_field.dart';
import 'package:editorjs_flutter/src/model/EditorJSBlock.dart';
import 'package:flutter/material.dart';
import 'package:editorjs_flutter/src/model/EditorJSData.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _buildBlocks();
  }

  @override
  void dispose() {
    super.dispose();
    _codeController?.dispose();
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
          case "code":
            _codeController = CodeController(
              text: element.data!.code,
            );
            items.add(SizedBox(
              height: 200,
              child: CodeField(
                controller: _codeController ?? CodeController(),
                textStyle: TextStyle(
                  fontFamily: 'SourceCode',
                  color: Colors.black,
                ),
                expands: true,
                lineNumbers: false,
                background: getColor('#FFF9F9F9'),
                readOnly: true,
                horizontalScroll: true,
              ),
            ));
            break;
          case "raw":
            _codeController = CodeController(
              text: element.data!.html,
            );
            items.add(CodeField(
              controller: _codeController ?? CodeController(),
              textStyle: TextStyle(fontFamily: 'SourceCode'),
              lineNumbers: false,
              background: getColor('#FF1F2128'),
              readOnly: true,
              horizontalScroll: true,
            ));
            break;
          case "warning":
            items.add(Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.exclamationCircle,
                  size: 24,
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(element.data?.title ?? ''),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(element.data?.message ?? ''),
                      ),
                    ],
                  ),
                )
              ],
            ));
            break;
          case "quote":
            items.add(Row(
              children: [
                Container(
                  width: 15,
                  constraints: BoxConstraints(minHeight: 100),
                  color: Colors.black26,
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(minHeight: 100),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    color: getColor('#FFF9F9F9'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.quoteLeft,
                          size: 20,
                          color: getColor('#FFCCCCCC'),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          element.data?.text ?? '',
                          textAlign: element.data?.alignment == 'left'
                              ? TextAlign.start
                              : TextAlign.center,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          element.data?.caption ?? '',
                          textAlign: element.data?.alignment == 'left'
                              ? TextAlign.start
                              : TextAlign.center,
                        )
                      ],
                    ),
                  ),
                )
              ],
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
          case "checklist":
            element.data!.checklist!.forEach((element) {
              items.add(Row(
                children: [
                  SizedBox(
                    width: 4,
                  ),
                  Checkbox(
                    value: element.checked,
                    onChanged: (value) {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    activeColor: getColor('#FF398AE5'),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(element.text ?? ''),
                ],
              ));
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
              ],
            ));
            break;
          case "table":
            items.add(SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: [
                ...?element.data?.headers?.map((e) => DataColumn(
                        label: Expanded(
                      child: Text(
                        e.toString(),
                        style: TextStyle(
                            fontWeight: element.data?.withHeadings == true
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    )))
              ], rows: [
                ...?element.data?.body?.map(
                  (e) => DataRow(
                    cells: [
                      ...e.map(
                        (element) => DataCell(
                          Text(element.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
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
