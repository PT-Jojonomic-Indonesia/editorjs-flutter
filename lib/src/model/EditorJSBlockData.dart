import 'package:editorjs_flutter/src/model/EditorJSBlockFile.dart';

class EditorJSBlockData {
  final String? text;
  final String? code;
  final String? html;
  final String? alignment;
  final String? message;
  final String? title;
  final int? level;
  final String? style;
  final List<String>? items;
  final List<Checklist>? checklist;
  final List<dynamic>? headers;
  final List<List<dynamic>>? body;
  final EditorJSBlockFile? file;
  final String? caption;
  final bool? withBorder;
  final bool? withHeadings;
  final bool? stretched;
  final bool? withBackground;

  EditorJSBlockData(
      {this.text,
      this.code,
      this.html,
      this.alignment,
      this.message,
      this.title,
      this.level,
      this.style,
      this.items,
      this.checklist,
      this.headers,
      this.body,
      this.file,
      this.caption,
      this.withBorder,
      this.withHeadings,
      this.stretched,
      this.withBackground});

  factory EditorJSBlockData.fromJson(Map<String, dynamic> parsedJson) {
    final list = parsedJson['items'] as List?;
    final listTable = parsedJson['content'] as List?;
    final List<String> itemsList = [];
    final List<Checklist> itemsChecklist = [];
    final List<dynamic> itemsHeader = [];
    final List<List<dynamic>> itemsBody = [];

    if (list != null) {
      list.forEach((element) {
        if (element is String) {
          itemsList.add(element.toString());
        } else {
          itemsChecklist.add(Checklist.fromJson(element));
        }
      });
    }

    if (listTable != null) {
      listTable.first?.map((e) => itemsHeader.add(e)).toList();
      listTable.removeAt(0);
      listTable.forEach((element) {
        itemsBody.add(element);
      });
    }

    return EditorJSBlockData(
        text: parsedJson['text'],
        code: parsedJson['code'],
        html: parsedJson['html'],
        alignment: parsedJson['alignment'],
        message: parsedJson['message'],
        title: parsedJson['title'],
        level: parsedJson['level'],
        style: parsedJson['style'],
        items: itemsList,
        checklist: itemsChecklist,
        headers: itemsHeader,
        body: itemsBody,
        file: (parsedJson['file'] != null)
            ? EditorJSBlockFile.fromJson(parsedJson['file'])
            : null,
        caption: parsedJson['caption'],
        withBorder: parsedJson['withBorder'],
        withHeadings: parsedJson['withHeadings'],
        withBackground: parsedJson['withBackground']);
  }
}

class Checklist {
  bool? checked;
  String? text;

  Checklist({this.checked, this.text});

  Checklist.fromJson(Map<String, dynamic> json) {
    checked = json['checked'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checked'] = this.checked;
    data['text'] = this.text;
    return data;
  }
}
