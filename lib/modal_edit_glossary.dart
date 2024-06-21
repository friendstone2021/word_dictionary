import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_dictionary/model/model_glossary.dart';

import 'modal_find_domain.dart';
import 'model/db_provider.dart';

class ModalEditGlossary extends StatefulWidget{

  ModelGlossary? model;

  ModalEditGlossary({super.key, this.model});

  @override
  State<StatefulWidget> createState() => ModalEditGlossaryState();

}

class ModalEditGlossaryState extends State<ModalEditGlossary> {

  TextEditingController controller_glossary_name = TextEditingController();
  TextEditingController controller_glossary_desc = TextEditingController();
  TextEditingController controller_glossary_short = TextEditingController();
  TextEditingController controller_glossary_domain = TextEditingController();
  TextEditingController controller_allow = TextEditingController();
  TextEditingController controller_data_save_form = TextEditingController();
  TextEditingController controller_data_exprs_form = TextEditingController();
  TextEditingController controller_glossary_same = TextEditingController();

  DbProvider db = DbProvider();

  @override
  Widget build(BuildContext context) {
    if(widget.model != null){
      controller_glossary_name.text = widget.model?.glossary_name as String;
      controller_glossary_desc.text = widget.model?.glossary_desc as String;
      controller_glossary_short.text = widget.model?.glossary_short as String;
      controller_glossary_domain.text = widget.model?.glossary_domain as String;
      controller_allow.text = widget.model?.allow as String;
      controller_data_save_form.text = widget.model?.data_save_form as String;
      controller_data_exprs_form.text = widget.model?.data_exprs_form as String;
      controller_glossary_same.text = widget.model?.glossary_same as String;
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
                      child: Text('용어명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_glossary_name)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('용어설명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_glossary_desc, minLines: 1, maxLines: 5,)
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
                      child: TextField(controller: controller_glossary_short)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('도메인'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_glossary_domain, readOnly: true,)
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
                            controller_glossary_domain.text = value;
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
                      child: Text('허용값'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_allow)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('저장형식'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_data_save_form)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('표현형식'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_data_exprs_form)
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
                      child: TextField(controller: controller_glossary_same)
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
                    ModelGlossary newModel = ModelGlossary(
                      glossary_name: controller_glossary_name.text,
                      glossary_desc: controller_glossary_desc.text,
                      glossary_short: controller_glossary_short.text,
                      glossary_domain: controller_glossary_domain.text,
                      allow: controller_allow.text,
                      data_save_form: controller_data_save_form.text,
                      data_exprs_form: controller_data_exprs_form.text,
                      glossary_same: controller_glossary_same.text,
                    );
                    db.checkDuplicateGlossary(newModel, context).then((value){
                      if(value){
                        Navigator.pop(context, newModel);
                      }else{
                        widget.model = newModel;
                      }
                    });
                  }else{
                    widget.model?.glossary_name = controller_glossary_name.text;
                    widget.model?.glossary_desc = controller_glossary_desc.text;
                    widget.model?.glossary_short = controller_glossary_short.text;
                    widget.model?.glossary_domain = controller_glossary_domain.text;
                    widget.model?.allow = controller_allow.text;
                    widget.model?.data_save_form = controller_data_save_form.text;
                    widget.model?.data_exprs_form = controller_data_exprs_form.text;
                    widget.model?.glossary_same = controller_glossary_same.text;
                    db.checkDuplicateGlossary(widget.model!, context).then((value){
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
