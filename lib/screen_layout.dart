import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_dictionary/tab_convert.dart';
import 'package:word_dictionary/tab_domain.dart';
import 'package:word_dictionary/tab_glossary.dart';
import 'package:word_dictionary/tab_word.dart';

class LayoutScreen extends StatelessWidget {

  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(
                text: '단어사전',
              ),
              Tab(
                text: '도메인사전',
              ),
              Tab(
                text: '용어사전',
              ),
              Tab(
                text: '용어변환',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TabWord(key: PageStorageKey('word')),
            TabDomain(key: PageStorageKey('domain')),
            TabGlossary(key: PageStorageKey('glossary')),
            TabConvert(key: PageStorageKey('convert')),
          ]
        ),
      ),
    );
  }
}
