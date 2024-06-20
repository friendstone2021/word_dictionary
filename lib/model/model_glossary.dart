class ModelGlossary {
  int? id;
  String? glossary_name;
  String? glossary_desc;
  String? glossary_short;
  String? glossary_domain;
  String? allow;
  String? data_save_form;
  String? data_exprs_form;
  String? glossary_same;
  bool selected = false;

  ModelGlossary({
    this.id,
    required this.glossary_name,
    required this.glossary_desc,
    required this.glossary_short,
    required this.glossary_domain,
    this.allow,
    this.data_save_form,
    this.data_exprs_form,
    this.glossary_same
  });

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'glossary_name' : glossary_name,
      'glossary_desc' : glossary_desc,
      'glossary_short' : glossary_short,
      'glossary_domain' : glossary_domain,
      'allow' : allow,
      'data_save_form' : data_save_form,
      'data_exprs_form' : data_exprs_form,
      'glossary_same' : glossary_same,
      'selected' : selected
    };
  }
}
