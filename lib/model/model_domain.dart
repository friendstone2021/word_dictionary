class ModelDomain {
  int? id;
  String? domain_grp;
  String? domain_type;
  String? domain_name;
  String? domain_desc;
  String? data_type;
  int? data_length1;
  int? data_length2;
  String? data_save_form;
  String? data_exprs_form;
  String? unit;
  String? allow;
  bool selected = false;

  ModelDomain({
    this.id,
    required this.domain_grp,
    required this.domain_type,
    required this.domain_name,
    required this.domain_desc,
    required this.data_type,
    this.data_length1,
    this.data_length2,
    this.data_save_form,
    this.data_exprs_form,
    this.unit,
    this.allow
  });

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'domain_grp' : domain_grp,
      'domain_type' : domain_type,
      'domain_name' : domain_name,
      'domain_desc' : domain_desc,
      'data_type' : data_type,
      'data_length1' : data_length1,
      'data_length2' : data_length2,
      'data_save_form' : data_save_form,
      'data_exprs_form' : data_exprs_form,
      'unit' : unit,
      'allow' : allow,
      'selected' : selected
    };
  }
}
