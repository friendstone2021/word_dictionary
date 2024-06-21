import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'modal_edit_glossary.dart';
import 'modal_upload_glossary.dart';
import 'model/db_provider.dart';
import 'model/model_glossary.dart';
import 'util/util_excel.dart';

class TabGlossary extends StatefulWidget{
  const TabGlossary({super.key});

  @override
  State<StatefulWidget> createState() => TabWordState();

}

class TabWordState extends State<TabGlossary> with AutomaticKeepAliveClientMixin{

  TextStyle ts_s = const TextStyle(fontSize: 10);
  TextStyle ts_m = const TextStyle(fontSize: 12);
  TextStyle ts_l = const TextStyle(fontSize: 14);

  late TextStyle textStyle;

  List<ModelGlossary> data = [];

  TextEditingController keywordController = TextEditingController();
  DbProvider db = DbProvider();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    textStyle = ts_m;
    db.getGlossaryList('', false).then((list){
      setState(() {
        data = list;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: TextField(
                controller: keywordController,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) async {
                  search();
                },
              )
            ),
            IconButton(
              onPressed: search,
              icon: const Icon(Icons.search),
            )
          ],
        )
      ),
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
                        child: ModalEditGlossary(),
                      );
                    }).then((value){
                      if(value!=null) {
                        db.insertGlossary(value, context)
                            .then((value) {
                          if (value) {
                            search();
                          }
                        });
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.black,),
                  onPressed: (){
                    setState(() {
                      // var removeList = [];
                      for(var item in data){
                        if(item.selected){
                          db.deleteGlossary(item);
                          // removeList.add(item);
                        }
                      }
                      data.removeWhere((item){
                        return item.selected;
                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.upload, color: Colors.black),
                  onPressed: (){
                    UtilExcel().loadGlossaryExcel().then((data){
                      if(data != null){
                        showDialog(
                          context: context,
                          builder: (context){
                            return Dialog(
                              child: ModalUploadGlossary(data: data)
                            );
                          }
                        ).then((value){
                          search();
                        });
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.black),
                  onPressed: (){
                    db.getGlossaryList('', true).then((list){
                      List<Map<String,dynamic>> excelData = [];
                      for(var row in list){
                        excelData.add(row.toMap());
                      }
                      UtilExcel().downloadExcel(
                        "GLOSSARY",
                        ["용어명","용어설명","약어","도메인","허용값","저장형식","표현형식","동의어"],
                        ["glossary_name","glossary_desc","glossary_short","glossary_domain","allow","data_save_form","data_exprs_form","glossary_same"],
                        excelData
                      );
                    });

                  },
                )
              ],
            )
          ]
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
      onTap: (){
        showDialog(context: context, builder: (context){
          debugPrint(item.toMap().toString());
          return Dialog(
            child: ModalEditGlossary(model: item),
          );
        }).then((value){
          if(value != null) {
            db.updateGlossary(value, context)
                .then((value) {
              if (value) {
                search();
              }
            });
          }
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

  search(){
    debugPrint('>>search()');
    db.getGlossaryList(keywordController.text, false).then((list){
      setState(() {
        data = list;
      });
    });
  }
}
