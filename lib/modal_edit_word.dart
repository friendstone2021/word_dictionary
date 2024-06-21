import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_dictionary/modal_find_domain.dart';
import 'package:word_dictionary/model/model_word.dart';

import 'model/db_provider.dart';

class ModalEditWord extends StatefulWidget{

  ModelWord? model;

  ModalEditWord({super.key, this.model});

  @override
  State<StatefulWidget> createState() => ModalEditWordState();

}

class ModalEditWordState extends State<ModalEditWord>{

  TextEditingController controller_word = TextEditingController();
  TextEditingController controller_word_eng = TextEditingController();
  TextEditingController controller_word_short = TextEditingController();
  TextEditingController controller_word_desc = TextEditingController();
  TextEditingController controller_domain = TextEditingController();
  TextEditingController controller_word_same = TextEditingController();

  DbProvider db = DbProvider();

  @override
  Widget build(BuildContext context) {

    if(widget.model != null){
      controller_word.text = widget.model?.word as String;
      controller_word_eng.text = widget.model?.word_eng as String;
      controller_word_short.text = widget.model?.word_short as String;
      controller_word_desc.text = widget.model?.word_desc as String;
      controller_domain.text = widget.model?.domain as String;
      controller_word_same.text = widget.model?.word_same as String;
    }

    return SizedBox(
      width: 800,
      height: 450,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('단어명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_word)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('단어영문명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_word_eng)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('약어'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_word_short)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('단어설명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_word_desc, minLines: 1, maxLines: 5,)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('표준도메인'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_domain, readOnly: true,)
                    ),
                    IconButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return const Dialog(
                              child: ModalFindDomain(),
                            );
                          }
                        ).then((value){
                          if(value != null) {
                            controller_domain.text = value;
                          }
                        });
                      },
                      icon: const Icon(Icons.search, color: Colors.black,)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('이음동의어'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_word_same)
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(30),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(widget.model == null){
                    ModelWord newModel = ModelWord(
                      word: controller_word.text,
                      word_eng: controller_word_eng.text,
                      word_short: controller_word_short.text,
                      word_desc: controller_word_desc.text,
                      is_form_word: 'N',
                      domain: controller_domain.text,
                      word_same: controller_word_same.text
                    );

                    db.checkDuplicateWord(newModel, context).then((value){
                      if(value){
                        Navigator.pop(context, newModel);
                      }else{
                        widget.model = newModel;
                      }
                    });
                  }else{
                    widget.model?.word = controller_word.text;
                    widget.model?.word_eng = controller_word_eng.text;
                    widget.model?.word_short = controller_word_short.text;
                    widget.model?.word_desc = controller_word_desc.text;
                    widget.model?.domain = controller_domain.text;
                    widget.model?.word_same = controller_word_same.text;

                    db.checkDuplicateWord(widget.model!, context).then((value){
                      if(value){
                        widget.model?.error = !value;
                        Navigator.pop(context, widget.model);
                      }
                    });
                  }
                },
                child: const Text('저장')
              )
            ],
          )
        ),
      )
    );
  }

}
