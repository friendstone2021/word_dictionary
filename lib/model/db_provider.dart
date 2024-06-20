import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:word_dictionary/model/model_domain.dart';
import 'package:word_dictionary/model/model_glossary.dart';
import 'package:word_dictionary/model/model_word.dart';
import 'package:path_provider/path_provider.dart';

class DbProvider {
  Database? _database;

  Future<Database?> get database async {
    _database ??= await initDB();
    return _database;
  }

  initDB() async {
    debugPrint('application document directory : ${await getApplicationDocumentsDirectory()}');
    debugPrint('>>initDb : ${await getDatabasesPath()}');
    String path = join(await getDatabasesPath(), 'dictionary.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE WORD(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            word_eng TEXT NOT NULL,
            word_short TEXT NOT NULL,
            word_desc TEXT NOT NULL,
            is_form_word TEXT NOT NULL,
            domain TEXT,
            word_same TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE DOMAIN(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            domain_grp TEXT NOT NULL,
            domain_type TEXT NOT NULL,
            domain_name TEXT NOT NULL,
            domain_desc TEXT NOT NULL,
            data_type TEXT NOT NULL,
            data_length1 INTEGER,
            data_length2 INTEGER,
            data_save_form TEXT,
            data_exprs_form TEXT,
            unit TEXT,
            allow TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE GLOSSARY(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            glossary_name TEXT NOT NULL,
            glossary_desc TEXT NOT NULL,
            glossary_short TEXT NOT NULL,
            glossary_domain TEXT NOT NULL,
            allow TEXT,
            data_save_form TEXT,
            data_exprs_form TEXT,
            glossary_same TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  Future<String?> getConvertWord(String keyword) async {
    final db = await database;
    List<Map<String, dynamic>> word = await db!.rawQuery("SELECT word, word_short FROM WORD WHERE word = ?", [keyword]);
    if(word.isEmpty){
      List<Map<String, dynamic>> word_same = await db!.rawQuery('SELECT word, word_same, word_short FROM WORD WHERE word_same like ?',['%$keyword%']);

      int index = -1;
      for(var i=0;i<word_same.length;i++){
        var same = word_same.elementAt(i);
        var sameList = same['word_same'].toString().split(',');
        for(var t in sameList){
          if(keyword == t.trim()){
            index = i;
            break;
          }
        }
      }

      if(index>=0){
        return word_same.elementAt(index)['word_short'];
      }else{
        return null;
      }

    }else{
      return word.elementAt(0)['word_short'];
    }
  }

  Future<List<ModelWord>> getWordList(String keyword, bool isDownload) async {
    debugPrint('>>getWordList');
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if(keyword.isEmpty){
      if(isDownload){
        maps = await db!.query('WORD');
      }else {
        maps = await db!.query('WORD',
            limit: 100
        );
      }
    }else{
      maps = await db!.query('WORD',
        where: "word like ? or word_eng like ? or word_short like ? or word_desc like ? or word_same like ? ",
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%']
      );
    }

    if(maps.isEmpty) return [];
    List<ModelWord> list = List.generate(maps.length, (index){
      return ModelWord(
        id: maps[index]['id'] ?? '',
        word: maps[index]['word'] ?? '',
        word_eng: maps[index]['word_eng'] ?? '',
        word_short: maps[index]['word_short'] ?? '',
        word_desc: maps[index]['word_desc'] ?? '',
        is_form_word: maps[index]['is_form_word'] ?? '',
        domain: maps[index]['domain'] ?? '',
        word_same: maps[index]['word_same'] ?? ''
      );
    });

    return list;
  }

  Future<List<ModelDomain>> getDomainList(String keyword, bool isDownload) async {
    debugPrint('>>getDomainList');
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if(keyword.isEmpty){
      if(isDownload){
        maps = await db!.query('DOMAIN');
      }else {
        maps = await db!.query('DOMAIN',
            limit: 100
        );
      }
    }else{
      maps = await db!.query('DOMAIN',
        where: "domain_grp like ? or domain_type like ? or domain_name like ? or domain_desc like ? ",
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%']
      );
    }

    if(maps.isEmpty) return [];
    List<ModelDomain> list = List.generate(maps.length, (index){
      return ModelDomain(
        id: maps[index]['id'] ?? '',
        domain_grp: maps[index]['domain_grp'] ?? '',
        domain_type: maps[index]['domain_type'] ?? '',
        domain_name: maps[index]['domain_name'] ?? '',
        domain_desc: maps[index]['domain_desc'] ?? '',
        data_type: maps[index]['data_type'] ?? '',
        data_length1: maps[index]['data_length1'].toString().isEmpty?null:int.parse(maps[index]['data_length1'].toString()),
        data_length2: maps[index]['data_length2'].toString().isEmpty?null:int.parse(maps[index]['data_length2'].toString()),
        data_save_form: maps[index]['data_save_form'] ?? '',
        data_exprs_form: maps[index]['data_exprs_form'] ?? '',
        unit: maps[index]['unit'] ?? '',
        allow: maps[index]['allow'] ?? '',
      );
    });

    return list;
  }

  Future<List<ModelGlossary>> getGlossaryList(String keyword, bool isDownload) async {
    debugPrint('>>getGlossaryList');
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if(keyword.isEmpty){
      if(isDownload){
        maps = await db!.query('GLOSSARY');
      }else {
        maps = await db!.query('GLOSSARY',
            limit: 100
        );
      }
    }else{
      maps = await db!.query('GLOSSARY',
        where: "glossary_name like ? or glossary_desc like ? or glossary_short like ? or glossary_domain like ? or glossary_same like ? ",
        whereArgs: ['%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%', '%$keyword%']
      );
    }

    if(maps.isEmpty) return [];
    List<ModelGlossary> list = List.generate(maps.length, (index){
      return ModelGlossary(
        id: maps[index]['id'] ?? '',
        glossary_name: maps[index]['glossary_name'] ?? '',
        glossary_desc: maps[index]['glossary_desc'] ?? '',
        glossary_short: maps[index]['glossary_short'] ?? '',
        glossary_domain: maps[index]['glossary_domain'] ?? '',
        allow: maps[index]['allow'] ?? '',
        data_save_form: maps[index]['data_save_form'] ?? '',
        data_exprs_form: maps[index]['data_exprs_form'] ?? '',
        glossary_same: maps[index]['glossary_same'] ?? ''
      );
    });

    return list;
  }

  Future<bool> checkDuplicateWord(ModelWord model, BuildContext context) async{
    final db = await database;
    List<Map<String, dynamic>> word = await db!.rawQuery('SELECT word FROM WORD WHERE word = ?',[model.word]);
    List<Map<String, dynamic>> word_same = await db!.rawQuery('SELECT word_same FROM WORD WHERE word_same like ?',['%${model.word}%']);

    bool existSame = false;
    for(var same in word_same){
      var sameList = same['word_same'].toString().split(',');
      for(var t in sameList){
        if(model.word == t.trim()){
          existSame = true;
          break;
        }
      }
    }

    if(word.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('이미 같은 단어가 존재합니다.'),
              actions: [
                new ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return false;
    }else if(existSame){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('이음동의어에 같은 단어가 존재합니다.'),
              actions: [
                new ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return false;
    }else{
      return true;
    }
  }

  Future<bool> checkDuplicateDomain(ModelDomain model, BuildContext context) async{
    final db = await database;
    List<Map<String, dynamic>> word = await db!.rawQuery('SELECT domain_name FROM DOMAIN WHERE domain_name = ?',[model.domain_name]);

    if(word.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('이미 같은 도메인이 존재합니다.'),
              actions: [
                new ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return false;
    }else{
      return true;
    }

  }

  Future<bool> checkDuplicateGlossary(ModelGlossary model, BuildContext context) async{
    final db = await database;
    List<Map<String, dynamic>> word = await db!.rawQuery('SELECT glossary_name FROM GLOSSARY WHERE glossary_name = ?',[model.glossary_name]);
    List<Map<String, dynamic>> word_same = await db!.rawQuery('SELECT glossary_same FROM GLOSSARY WHERE glossary_same like ?',['%${model.glossary_name}%']);

    bool existSame = false;
    for(var same in word_same){
      var sameList = same['glossary_same'].toString().split(',');
      for(var t in sameList){
        if(model.glossary_name == t.trim()){
          existSame = true;
          break;
        }
      }
    }

    if(word.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('이미 같은 용어가 존재합니다.'),
              actions: [
                new ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return false;
    }else if(existSame){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text('이음동의어에 같은 단어가 존재합니다.'),
              actions: [
                new ElevatedButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return false;
    }else{
      return true;
    }
  }

  Future<bool> insertWord(ModelWord model, BuildContext context) async {
    final db = await database;

    bool duplicateCheck = await checkDuplicateWord(model, context);

    if(!duplicateCheck) {
      return false;
    }else {
      db!.insert('WORD',
        {
          'word': model.word,
          'word_eng': model.word_eng,
          'word_short': model.word_short,
          'word_desc': model.word_desc,
          'is_form_word': model.is_form_word,
          'domain': model.domain,
          'word_same': model.word_same
        },
      );
      return true;
    }
  }

  Future<bool> updateWord(ModelWord model, BuildContext context) async {
    debugPrint(model.toMap().toString());
    final db = await database;

    bool duplicateCheck = await checkDuplicateWord(model, context);

    if(!duplicateCheck) {
      return false;
    }else {
      db!.update('WORD',
          {
            'word': model.word,
            'word_eng': model.word_eng,
            'word_short': model.word_short,
            'word_desc': model.word_desc,
            'is_form_word': model.is_form_word,
            'domain': model.domain,
            'word_same': model.word_same
          },
          where: 'ID = ?',
          whereArgs: [model.id]
      );
      return true;
    }
  }

  deleteWord(ModelWord model) async {
    final db = await database;
    db!.delete('WORD',
      where: 'ID = ?',
      whereArgs: [model.id]
    );
  }

  Future<bool> insertDomain(ModelDomain model, BuildContext context) async {
    final db = await database;

    bool duplicateCheck = await checkDuplicateDomain(model, context);

    if(!duplicateCheck){
      return false;
    }else {
      db!.insert('DOMAIN',
        {
          'domain_grp': model.domain_grp,
          'domain_type': model.domain_type,
          'domain_name': model.domain_name,
          'domain_desc': model.domain_desc,
          'data_type': model.data_type,
          'data_length1': model.data_length1,
          'data_length2': model.data_length2,
          'data_save_form': model.data_save_form,
          'data_exprs_form': model.data_exprs_form,
          'unit': model.unit,
          'allow': model.allow,
        },
      );
      return true;
    }
  }

  Future<bool> updateDomain(ModelDomain model, BuildContext context) async {
    final db = await database;

    bool duplicateCheck = await checkDuplicateDomain(model, context);

    if(!duplicateCheck){
      return false;
    }else {
      db!.update('DOMAIN',
          {
            'domain_grp': model.domain_grp,
            'domain_type': model.domain_type,
            'domain_name': model.domain_name,
            'domain_desc': model.domain_desc,
            'data_type': model.data_type,
            'data_length1': model.data_length1,
            'data_length2': model.data_length2,
            'data_save_form': model.data_save_form,
            'data_exprs_form': model.data_exprs_form,
            'unit': model.unit,
            'allow': model.allow,
          },
          where: 'ID = ?',
          whereArgs: [model.id]
      );
      return true;
    }
  }

  deleteDomain(ModelDomain model) async {
    final db = await database;
    db!.delete('DOMAIN',
      where: 'ID = ?',
      whereArgs: [model.id]
    );
  }

  Future<bool> insertGlossary(ModelGlossary model, BuildContext context) async {
    final db = await database;

    bool duplicateCheck = await checkDuplicateGlossary(model, context);

    if(!duplicateCheck){
      return false;
    }else {
      db!.insert('GLOSSARY',
        {
          'glossary_name': model.glossary_name,
          'glossary_desc': model.glossary_desc,
          'glossary_short': model.glossary_short,
          'glossary_domain': model.glossary_domain,
          'allow': model.allow,
          'data_save_form': model.data_save_form,
          'data_exprs_form': model.data_exprs_form,
          'glossary_same': model.glossary_same
        },
      );
      return true;
    }
  }

  Future<bool> updateGlossary(ModelGlossary model, BuildContext context) async {
    final db = await database;

    bool duplicateCheck = await checkDuplicateGlossary(model, context);

    if(!duplicateCheck){
      return false;
    }else {
      db!.update('GLOSSARY',
          {
            'glossary_name': model.glossary_name,
            'glossary_desc': model.glossary_desc,
            'glossary_short': model.glossary_short,
            'glossary_domain': model.glossary_domain,
            'allow': model.allow,
            'data_save_form': model.data_save_form,
            'data_exprs_form': model.data_exprs_form,
            'glossary_same': model.glossary_same
          },
          where: 'ID = ?',
          whereArgs: [model.id]
      );
      return true;
    }
  }

  deleteGlossary(ModelGlossary model) async {
    final db = await database;
    db!.delete('GLOSSARY',
      where: 'ID = ?',
      whereArgs: [model.id]
    );
  }
}
