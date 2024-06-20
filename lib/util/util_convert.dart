import 'package:flutter/cupertino.dart';
import 'package:word_dictionary/model/model_glossary.dart';

import '../model/db_provider.dart';

class UtilConvert {

  DbProvider db = DbProvider();

  Future<List<ModelGlossary>> convertGlossary(List<ModelGlossary> originList) async {

    List<ModelGlossary> result = [];

    for(var item in originList){
      // item['glossary_name']
      String originWord = item.glossary_name!;
      String convertWord = '';
      int lastIndex = 0;

      debugPrint('originWord:$originWord');

      // while(lastIndex < originWord.length) {
      for(var c = 0; c < originWord.length; c++){
        for (var i = originWord.length; i >= lastIndex; i--) {
          String tmp = originWord.substring(lastIndex, i);
          if(tmp.isNotEmpty) {
            String? result = await changeWord(tmp);
            if (result != null) {
              if (convertWord != '') {
                convertWord += '_';
              }
              convertWord += result;
              lastIndex = i;
              break;
            }
          }
        }
        if(lastIndex == originWord.length){
          break;
        }
      }
      if(lastIndex != originWord.length){
        convertWord += '_${originWord.substring(lastIndex)}';
      }

      debugPrint('convertWord:$convertWord');

      item.glossary_short = convertWord;
      result.add(item);
    }
    return result;
  }

  Future<String?> changeWord(String glossary) async {
    String? word = await db!.getConvertWord(glossary);
    return word;
  }
}
