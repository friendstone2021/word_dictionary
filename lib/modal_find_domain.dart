import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/db_provider.dart';
import 'model/model_domain.dart';

class ModalFindDomain extends StatefulWidget{

  const ModalFindDomain({super.key});

  @override
  State<StatefulWidget> createState() => ModalFindDomainState();

}

class ModalFindDomainState extends State<ModalFindDomain>{

  List<ModelDomain> data = [];

  TextEditingController keywordController = TextEditingController();
  DbProvider db = DbProvider();

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
    );
  }

  makeRow(ModelDomain item){

    String data_type = item.data_type!;
    if(item.data_length1 != null){
      data_type += '(' + item.data_length1.toString();
      if(item.data_length2 != null){
        data_type += ','+item.data_length2.toString();
      }
      data_type += ')';
    }

    return DataRow2(
      onTap: (){
        Navigator.pop(context, item.domain_name);
      },
      cells: [
        DataCell(SelectableText(item.domain_grp as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_type as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_name as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain_desc as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(data_type, style: const TextStyle(fontSize: 10))),
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
