import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itunes_clone/model/song.dart';

class SearchRepository {
  // Create a singleton instance of the SearchRepository
  static final SearchRepository _instance = SearchRepository._internal();
  factory SearchRepository() => _instance;
  SearchRepository._internal();

  Future<List<Song>> searchMusic(String term) async {
    final url =
        "https://itunes.apple.com/search?term=$term&country=&entity=song";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final map = json.decode(response.body);
      return map['results'].map<Song>((json) => Song.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
