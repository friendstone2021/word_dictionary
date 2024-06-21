class ModelWord {
  int? id;
  String? word;
  String? word_eng;
  String? word_short;
  String? word_desc;
  String? is_form_word;
  String? domain;
  String? word_same;
  bool selected = false;
  bool error = false;

  ModelWord({
    this.id,
    required this.word,
    required this.word_eng,
    required this.word_short,
    required this.word_desc,
    required this.is_form_word,
    this.domain,
    this.word_same
  });

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'word' : word,
      'word_eng' : word_eng,
      'word_short' : word_short,
      'word_desc' : word_desc,
      'is_form_word' : is_form_word,
      'domain' : domain,
      'word_same' : word_same,
      'selected' : selected,
      'error' : error
    };
  }
}
