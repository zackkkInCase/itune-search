import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:itunes_clone/view/widget/music_bottom_bar.dart';
import 'package:itunes_clone/repository/search_repository.dart';
import 'package:itunes_clone/model/song.dart';
import 'package:logger/logger.dart';
import 'package:mvvm/mvvm.dart';

class HomePageViewModel extends ViewModel {
  final SearchRepository _searchRepository = GetIt.instance<SearchRepository>();
  final logger = GetIt.instance<Logger>();

  @override
  void init() {
    super.init();
    registerProperty(#songs, BindableProperty.$value<List<Song>>(initial: []));
    registerProperty(
        #selectedSong, BindableProperty.$value<Song?>(initial: null));
  }

  Future<void> searchMusic(String term) async {
    try {
      final songs = await _searchRepository.searchMusic(term);
      updateValue(#songs, (p0) => songs);
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void selectMusic(Song song) {
    updateValue<Song?>(
      #selectedSong,
      (p0) => song,
    );
  }

  void playMusic() {
    final song = getProperty<Song?>(#selectedSong)?.value?..play();
    updateValue<Song?>(#selectedSong, (p0) => song);
  }

  void pauseMusic() {
    final song = getProperty<Song?>(#selectedSong)?.value?..pause();
    updateValue<Song?>(#selectedSong, (p0) => song);
  }
}

class HomePage extends View<HomePageViewModel> {
  HomePage({super.key});

  final textController = TextEditingController();

  Timer? _debounce;

  @override
  HomePageViewModel createViewModel() => HomePageViewModel();

  void onTextFieldChange(String value, HomePageViewModel viewModel) {
    final term = value.trim().replaceAll(" ", "+");
    if (value.isEmpty) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
        const Duration(milliseconds: 500), () => viewModel.searchMusic(term));
  }

  Widget _buildSearchBar(HomePageViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        decoration: const InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          onTextFieldChange(value, viewModel);
        },
      ),
    );
  }

  Widget _buildSearchResults(HomePageViewModel viewModel) {
    return Expanded(
      child: viewModel.$watchFor<List<Song>>(#songs,
          builder: (context, value, child) {
        return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(value[index].trackName ?? ""),
              subtitle: Text(value[index].artistName ?? ""),
              onTap: () {
                viewModel.selectMusic(value[index]);
              },
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context, HomePageViewModel model) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          _buildSearchBar(model),
          _buildSearchResults(model),
          model.$watchFor<Song?>(
            #selectedSong,
            builder: (context, value, child) => MusicBottomBar(
              song: value,
              onPlay: () => model.playMusic(),
              onPause: () => model.pauseMusic(),
            ),
          ),
        ],
      ),
    );
  }
}
