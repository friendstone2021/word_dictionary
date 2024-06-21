import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'modal_edit_glossary.dart';
import 'modal_edit_word.dart';
import 'model/db_provider.dart';
import 'model/model_glossary.dart';
import 'model/model_word.dart';
import 'util/util_excel.dart';

class ModalUploadGlossary extends StatefulWidget{

  final List<ModelGlossary> data;

  const ModalUploadGlossary({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => ModalUploadGlossaryState();

}

class ModalUploadGlossaryState extends State<ModalUploadGlossary>{

  TextStyle ts_s = const TextStyle(fontSize: 10);
  TextStyle ts_m = const TextStyle(fontSize: 12);
  TextStyle ts_l = const TextStyle(fontSize: 14);

  late TextStyle textStyle;

  List<ModelGlossary> data = [];

  DbProvider db = DbProvider();

  @override
  void initState() {
    textStyle = ts_m;
    data = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Theme(
          // Using themes to override scroll bar appearence, note that iOS scrollbars do not support color overrides
          data: ThemeData(
              iconTheme: const IconThemeData(color: Colors.white),
              scrollbarTheme: ScrollbarThemeData(
                thickness: WidgetStateProperty.all(5),
                // thumbVisibility: MaterialStateProperty.all(true),
                // thumbColor: MaterialStateProperty.all<Color>(Colors.yellow)
              )),
          child: DataTable2(
            columnSpacing: 0,
            columns: [
              DataColumn2(label: SelectableText('용어명', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('용어설명', style: textStyle), size: ColumnSize.L),
              DataColumn2(label: SelectableText('약어', style: textStyle), fixedWidth: 120),
              DataColumn2(label: SelectableText('도메인', style: textStyle), fixedWidth: 90),
              DataColumn2(label: SelectableText('허용값', style: textStyle), size: ColumnSize.M),
              DataColumn2(label: SelectableText('저장형식', style: textStyle), size: ColumnSize.M),
              DataColumn2(label: SelectableText('표현형식', style: textStyle), size: ColumnSize.M),
              DataColumn2(label: SelectableText('이음동의어', style: textStyle), fixedWidth: 90),
            ],
            // rows: rowData,
            rows : data.isEmpty ? [] : List<DataRow2>.generate(data.length, (index) => makeRow(data.elementAt(index))),
            dataRowHeight: 100,
          ),
        )
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      child: const Text("A", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                      onPressed: (){
                        setState(() {
                          textStyle = ts_l;
                        });
                      }
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      child: const Text("A", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      onPressed: (){
                        setState(() {
                          textStyle = ts_m;
                        });
                      }
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: TextButton(
                      child: const Text("A", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      onPressed: (){
                        setState(() {
                          textStyle = ts_s;
                        });
                      }
                    ),
                  ),
                ],
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black,),
                  onPressed: (){
                    showDialog(context: context, builder: (context){
                      return Dialog(
                        child: ModalEditWord(),
                      );
                    }).then((value){
                      setState(() {
                        data.add(value);
                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.black,),
                  onPressed: (){
                    setState(() {
                      data.removeWhere((item){
                        return item.selected;
                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save_alt, color: Colors.black,),
                  onPressed: () async{
                    var existsError = false;
                    for(var item in data){
                      if(item.selected && item.error){
                        existsError = true;
                        break;
                      }
                    }
                    if(existsError){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text('데이터에 오류가 있습니다.'),
                              actions: [
                                ElevatedButton(
                                  child: const Text("확인"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          }
                      );
                    }else{
                      List<ModelGlossary> deleteList = [];
                      for(var item in data){
                        if(item.selected) {
                          var isSuccess = await db.insertGlossary(item, context);
                          if(isSuccess){
                            deleteList.add(item);
                          }
                        }
                      }
                      for(var item in deleteList){
                        data.remove(item);
                      }
                      if(data.isEmpty) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.black),
                  onPressed: (){
                    List<Map<String,dynamic>> excelData = [];
                    for(var row in data){
                      excelData.add(row.toMap());
                    }
                    UtilExcel().downloadExcel(
                      "GLOSSARY",
                      ["용어명","용어설명","약어","도메인","허용값","저장형식","표현형식","동의어"],
                      ["glossary_name","glossary_desc","glossary_short","glossary_domain","allow","data_save_form","data_exprs_form","glossary_same"],
                      excelData
                    );
                  },
                )
              ],
            )
          ],
        )

      ),
    );
  }

  makeRow(ModelGlossary item){
    return DataRow2(
      selected: item.selected,
      onSelectChanged: (check){
        setState(() {
          item.selected = check!;
        });
      },
      decoration: item.error ? const BoxDecoration(color: Colors.pinkAccent) : null,
      onTap: (){
        showDialog(context: context, builder: (context){
          debugPrint(item.toMap().toString());
          return Dialog(
            child: ModalEditGlossary(model: item),
          );
        }).then((value){
          setState(() {
            data.setAll(data.indexOf(item), [value]);
          });
        });
      },
      cells: [
        DataCell(SelectableText(item.glossary_name as String, style: textStyle)),
        DataCell(SelectableText(item.glossary_desc as String, style: textStyle)),
        DataCell(SelectableText(item.glossary_short as String, style: textStyle)),
        DataCell(SelectableText(item.glossary_domain as String, style: textStyle)),
        DataCell(SelectableText(item.allow as String, style: textStyle)),
        DataCell(SelectableText(item.data_save_form as String, style: textStyle)),
        DataCell(SelectableText(item.data_exprs_form as String, style: textStyle)),
        DataCell(SelectableText(item.glossary_same as String, style: textStyle)),
      ]
    );
  }

}
