import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_dictionary/model/model_domain.dart';

import 'modal_edit_domain.dart';
import 'model/db_provider.dart';
import 'util/util_excel.dart';

class TabDomain extends StatefulWidget{
  const TabDomain({super.key});

  @override
  State<StatefulWidget> createState() => TabDomainState();

}

class TabDomainState extends State<TabDomain> with AutomaticKeepAliveClientMixin{

  List<ModelDomain> data = [];

  TextEditingController keywordController = TextEditingController();
  DbProvider db = DbProvider();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    db.getDomainList('', false).then((list){
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
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
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
            columns: const [
              DataColumn2(label: SelectableText('도메인\n그룹', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n분류', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n명', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('도메인\n설명', style: TextStyle(fontSize: 10)), size: ColumnSize.L),
              DataColumn2(label: SelectableText('데이터\n타입', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('데이터\n길이', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('데이터\n소수점길이', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('저장\n형식', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('표현\n형식', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('단위', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('허용값', style: TextStyle(fontSize: 10)), size: ColumnSize.M),
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
                  search();
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
                      db.deleteDomain(item);
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
              icon: const Icon(Icons.download, color: Colors.black),
              onPressed: (){
                db.getDomainList('', true).then((list){
                  List<Map<String,dynamic>> excelData = [];
                  for(var row in list){
                    excelData.add(row.toMap());
                  }
                  UtilExcel().downloadExcel(
                    "DOMAIN",
                    ["도메인그룹","도메인분류","도메인명","도메인설명","데이터타입","데이터길이","데이터소수점길이","저장형식","표현형식","단위","허용값"],
                    ["domain_grp","domain_type","domain_name","domain_desc","data_type","data_length1","data_length2","data_save_form","data_exprs_form","unit","allow"],
                    excelData
                  );
                });

              },
            )
          ],
        )
      )
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
      onTap: (){
        showDialog(context: context, builder: (context){
          debugPrint(item.toMap().toString());
          return Dialog(
            child: ModalEditDomain(model: item),
          );
        }).then((value){
          search();
        });
      },
      cells: [
        DataCell(SelectableText(item.domain_grp as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_type as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_name as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_desc as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.data_type as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText('${item.data_length1 ?? ''}', style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText('${item.data_length2 ?? ''}', style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.data_save_form as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.data_exprs_form as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.unit as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.allow as String, style: const TextStyle(fontSize: 10))),
      ]
    );
  }

  search(){
    debugPrint('>>search()');
    db.getDomainList(keywordController.text, false).then((list){
      setState(() {
        data = list;
      });
    });
  }
}
