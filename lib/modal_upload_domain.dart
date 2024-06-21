import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'modal_edit_domain.dart';
import 'modal_edit_word.dart';
import 'model/db_provider.dart';
import 'model/model_domain.dart';
import 'model/model_word.dart';
import 'util/util_excel.dart';

class ModalUploadDomain extends StatefulWidget{

  final List<ModelDomain> data;

  const ModalUploadDomain({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => ModalUploadDomainState();

}

class ModalUploadDomainState extends State<ModalUploadDomain>{

  TextStyle ts_s = const TextStyle(fontSize: 10);
  TextStyle ts_m = const TextStyle(fontSize: 12);
  TextStyle ts_l = const TextStyle(fontSize: 14);

  late TextStyle textStyle;

  List<ModelDomain> data = [];

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
              DataColumn2(label: SelectableText('도메인\n그룹', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n분류', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n명', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n설명', style: textStyle), size: ColumnSize.L),
              DataColumn2(label: SelectableText('데이터\n타입', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('데이터\n길이', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('데이터\n소수점길이', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('저장\n형식', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('표현\n형식', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('단위', style: textStyle), size: ColumnSize.S),
              DataColumn2(label: SelectableText('허용값', style: textStyle), size: ColumnSize.M),
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
                        child: ModalEditDomain(),
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
                      List<ModelDomain> deleteList = [];
                      for(var item in data){
                        if(item.selected) {
                          var isSuccess = await db.insertDomain(item, context);
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
                      "DOMAIN",
                      ["도메인그룹","도메인분류","도메인명","도메인설명","데이터타입","데이터길이","데이터소수점길이","저장형식","표현형식","단위","허용값"],
                      ["domain_grp","domain_type","domain_name","domain_desc","data_type","data_length1","data_length2","data_save_form","data_exprs_form","unit","allow"],
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

  makeRow(ModelDomain item){
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
            child: ModalEditDomain(model: item),
          );
        }).then((value){
          setState(() {
            data.setAll(data.indexOf(item), [value]);
          });
        });
      },
      cells: [
        DataCell(SelectableText(item.domain_grp as String, style: textStyle)),
        DataCell(SelectableText(item.domain_type as String, style: textStyle)),
        DataCell(SelectableText(item.domain_name as String, style: textStyle)),
        DataCell(SelectableText(item.domain_desc as String, style: textStyle)),
        DataCell(SelectableText(item.data_type as String, style: textStyle)),
        DataCell(SelectableText('${item.data_length1 ?? ''}', style: textStyle)),
        DataCell(SelectableText('${item.data_length2 ?? ''}', style: textStyle)),
        DataCell(SelectableText(item.data_save_form as String, style: textStyle)),
        DataCell(SelectableText(item.data_exprs_form as String, style: textStyle)),
        DataCell(SelectableText(item.unit as String, style: textStyle)),
        DataCell(SelectableText(item.allow as String, style: textStyle)),
      ]
    );
  }

}
