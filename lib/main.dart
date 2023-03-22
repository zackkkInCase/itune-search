import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:itunes_clone/view/page/page_home.dart';
import 'package:itunes_clone/repository/search_repository.dart';
import 'package:logger/logger.dart';

void main() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<SearchRepository>(SearchRepository());
  getIt.registerSingleton<Logger>(Logger());
  runApp(const ItunesClone());
}

class ItunesClone extends StatelessWidget {
  const ItunesClone({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Itunes Clone',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
      ],
    );
  }
}
