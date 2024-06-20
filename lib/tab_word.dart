import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_dictionary/model/db_provider.dart';
import 'package:word_dictionary/model/model_word.dart';
import 'package:word_dictionary/util/util_excel.dart';

import 'modal_edit_word.dart';

class TabWord extends StatefulWidget{
  const TabWord({super.key});

  @override
  State<StatefulWidget> createState() => TabWordState();

}

class TabWordState extends State<TabWord> with AutomaticKeepAliveClientMixin{

  List<ModelWord> data = [];

  TextEditingController keywordController = TextEditingController();
  DbProvider db = DbProvider();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    db.getWordList('', false).then((list){
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
            columns: const [
              DataColumn2(label: SelectableText('단어명', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('단어영문명', style: TextStyle(fontSize: 10)), size: ColumnSize.S),
              DataColumn2(label: SelectableText('약어', style: TextStyle(fontSize: 10)), fixedWidth: 90),
              DataColumn2(label: SelectableText('단어설명', style: TextStyle(fontSize: 10)), size: ColumnSize.L),
              // DataColumn2(label: SelectableText('형식\n단어\n여부'), size: ColumnSize.S),
              DataColumn2(label: SelectableText('표준\n도메인', style: TextStyle(fontSize: 10)), fixedWidth: 90),
              DataColumn2(label: SelectableText('이음동의어', style: TextStyle(fontSize: 10)), fixedWidth: 90),
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
                    child: ModalEditWord(),
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
                      db.deleteWord(item);
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
                db.getWordList('', true).then((list){
                  List<Map<String,dynamic>> excelData = [];
                  for(var row in list){
                    excelData.add(row.toMap());
                  }
                  UtilExcel().downloadExcel(
                    "WORD",
                    ["단어명","단어영문명","약어","단어설명","표준도메인","이음동의어"],
                    ["word","word_eng","word_short","word_desc","domain","word_same"],
                    excelData
                  );
                });

              },
            )
          ],
        )
      ),
    );
  }

  makeRow(ModelWord item){
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
            child: ModalEditWord(model: item),
          );
        }).then((value){
          search();
        });
      },
      cells: [
        DataCell(SelectableText(item.word as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.word_eng as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.word_short as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.word_desc as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.domain as String, style: const TextStyle(fontSize: 10))),
        DataCell(SelectableText(item.word_same as String, style: const TextStyle(fontSize: 10))),
      ]
    );
  }

  search(){
    debugPrint('>>search()');
    db.getWordList(keywordController.text, false).then((list){
      setState(() {
        data = list;
      });
    });
  }

}
