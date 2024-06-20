import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/db_provider.dart';
import 'model/model_domain.dart';

class ModalEditDomain extends StatefulWidget{

  ModelDomain? model;

  ModalEditDomain({super.key, this.model});

  @override
  State<StatefulWidget> createState() => ModalEditDomainState();

}

class ModalEditDomainState extends State<ModalEditDomain>{

  TextEditingController controller_domain_grp = TextEditingController();
  TextEditingController controller_domain_type = TextEditingController();
  TextEditingController controller_domain_name = TextEditingController();
  TextEditingController controller_domain_desc = TextEditingController();
  TextEditingController controller_data_type = TextEditingController();
  TextEditingController controller_data_length1 = TextEditingController();
  TextEditingController controller_data_length2 = TextEditingController();
  TextEditingController controller_data_save_form = TextEditingController();
  TextEditingController controller_data_exprs_form = TextEditingController();
  TextEditingController controller_unit = TextEditingController();
  TextEditingController controller_allow = TextEditingController();

  DbProvider db = DbProvider();

  @override
  Widget build(BuildContext context) {

    if(widget.model != null){
      controller_domain_grp.text = widget.model?.domain_grp as String;
      controller_domain_type.text = widget.model?.domain_type as String;
      controller_domain_name.text = widget.model?.domain_name as String;
      controller_domain_desc.text = widget.model?.domain_desc as String;
      controller_data_type.text = widget.model?.data_type as String;
      controller_data_length1.text = '${widget.model?.data_length1 ?? ''}';
      controller_data_length2.text = '${widget.model?.data_length2 ?? ''}';
      controller_data_save_form.text = widget.model?.data_save_form as String;
      controller_data_exprs_form.text = widget.model?.data_exprs_form as String;
      controller_unit.text = widget.model?.unit as String;
      controller_allow.text = widget.model?.allow as String;
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
                      child: Text('도메인그룹'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_domain_grp)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('도메인분류'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_domain_type)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('도메인명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_domain_name)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('도메인설명'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_domain_desc, minLines: 1, maxLines: 5,)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('데이터타입'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_data_type)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('데이터길이'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_data_length1)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('데이터소수점길이'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_data_length2)
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
                      child: Text('단위'),
                    ),
                    Expanded(
                      child: TextField(controller: controller_unit)
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
                    ModelDomain newModel = ModelDomain(
                      domain_grp: controller_domain_grp.text,
                      domain_type: controller_domain_type.text,
                      domain_name: controller_domain_name.text,
                      domain_desc: controller_domain_desc.text,
                      data_type: controller_data_type.text,
                      data_length1: controller_data_length1.text.isEmpty?null:int.parse(controller_data_length1.text),
                      data_length2: controller_data_length2.text.isEmpty?null:int.parse(controller_data_length2.text),
                      data_save_form: controller_data_save_form.text,
                      data_exprs_form: controller_data_exprs_form.text,
                      unit: controller_unit.text,
                      allow: controller_allow.text,
                    );
                    db.insertDomain(newModel, context).then((value){
                      if(value){
                        widget.model = newModel;
                        Navigator.pop(context);
                      }
                    });
                  }else{
                    widget.model?.domain_grp = controller_domain_grp.text;
                    widget.model?.domain_type = controller_domain_type.text;
                    widget.model?.domain_name = controller_domain_name.text;
                    widget.model?.domain_desc = controller_domain_desc.text;
                    widget.model?.data_type = controller_data_type.text;
                    widget.model?.data_length1 = controller_data_length1.text.isEmpty?null:int.parse(controller_data_length1.text);
                    widget.model?.data_length2 = controller_data_length2.text.isEmpty?null:int.parse(controller_data_length2.text);
                    widget.model?.data_save_form = controller_data_save_form.text;
                    widget.model?.data_exprs_form = controller_data_exprs_form.text;
                    widget.model?.unit = controller_unit.text;
                    widget.model?.allow = controller_allow.text;
                    db.updateDomain(widget.model!,context).then((value){
                      Navigator.pop(context);
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
