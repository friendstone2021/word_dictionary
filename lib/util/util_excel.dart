import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:word_dictionary/model/model_glossary.dart';

class UtilExcel {
  downloadExcel(String type, List<String> headers, List<String> columns, List<Map<String,dynamic>> rows) async {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    for(int i=0;i<headers.length;i++){
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers.elementAt(i));
    }

    for(int i=0;i<rows.length;i++){
      Map<String, dynamic> row = rows.elementAt(i);
      for(int j=0;j<columns.length;j++){
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i+1));
        if(row[columns.elementAt(j)].runtimeType.toString() == 'int'){
          cell.value = TextCellValue(row[columns.elementAt(j)]!=null?row[columns.elementAt(j)].toString():'');
        }else {
          cell.value = TextCellValue(row[columns.elementAt(j)] ?? '');
        }
      }
    }

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: '파일을 저장할 경로를 선택하세요.',
      fileName: '$type.xlsx'
    );

    if(outputFile != null) {
      List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        File(join(outputFile))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }
    }
  }

  Future<List<ModelGlossary>> loadExcel() async {
    List<ModelGlossary> result = [];

    FilePickerResult? inputFile = await FilePicker.platform.pickFiles(
      dialogTitle: '불러올 파일을 선택하세요.',
      type: FileType.custom,
      allowedExtensions: ['xlsx','xls']
    );

    if(inputFile != null){
      File file = File(inputFile.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        // debugPrint(table); //sheet Name
        // debugPrint('${excel.tables[table]?.maxColumns}');
        // debugPrint('${excel.tables[table]?.maxRows}');
        for (var row in excel.tables[table]!.rows) {
          // debugPrint('$row');
          Map<String, String> map = {
            'glossary_name' : '',
            'glossary_desc' : '',
            'glossary_short' : '',
            'glossary_domain' : '',
            'allow' : '',
            'data_save_form' : '',
            'data_exprs_form' : '',
            'glossary_same' : ''
          };
          for(var i=0;i<8;i++){
            final cell = row.elementAt(i);
            final value = cell?.value.toString();

            switch(i){
              case 0:
                map['glossary_name'] = value!;
                break;
              case 1:
                map['glossary_desc'] = value ?? '';
                break;
              case 2:
                map['glossary_short'] = value ?? '';
                break;
              case 3:
                map['glossary_domain'] = value ?? '';
                break;
              case 4:
                map['allow'] = value ?? '';
                break;
              case 5:
                map['data_save_form'] = value ?? '';
                break;
              case 6:
                map['data_exprs_form'] = value ?? '';
                break;
              case 7:
                map['glossary_same'] = value ?? '';
                break;
            }
          }

          ModelGlossary item = ModelGlossary(
            glossary_name: map['glossary_name'],
            glossary_desc: map['glossary_desc'],
            glossary_short: map['glossary_short'],
            glossary_domain: map['glossary_domain'],
            allow: map['allow'],
            data_save_form: map['data_save_form'],
            data_exprs_form: map['data_exprs_form'],
            glossary_same: map['glossary_same']
          );

          result.add(item);
        }
      }
    }

    return result;
  }
}
