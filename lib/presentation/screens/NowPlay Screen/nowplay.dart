import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:mixpod/application/cubit/player_cubit/player_cubit.dart';
import 'package:mixpod/core/functions/functions.dart';
import 'package:mixpod/domine/db/hivemodel.dart';
import 'package:mixpod/presentation/screens/HomeScreen/home.dart';
import 'package:mixpod/presentation/screens/HomeScreen/playlistWidgets/add_to_playlist_from_home.dart';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ScreenNowplay extends StatefulWidget {
  Audio? song;
  List<Audio> myaudiosong = [];
  int index;
  ScreenNowplay({
    song,
    required this.myaudiosong,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenNowplay> createState() => _ScreenNowplayState();
}

class _ScreenNowplayState extends State<ScreenNowplay> {
  bool nextDone = true;
  bool preDone = true;

  int repeat = 0;
  List<dynamic> likedSongS = [];

  bool prevvisible = true;
  bool nxtvisible = true;

  buttondesable() {
    if (widget.index == 0) {
      prevvisible = false;
    } else {
      prevvisible = true;
    }

    if (widget.index == audiosongs.length - 1) {
      nxtvisible = false;
    } else {
      nxtvisible = true;
    }
  }

  @override
  void initState() {
    buttondesable();
    super.initState();
    databaseSong = box.get('musics') as List<LocalSongs>;

    assetsAudioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xff091127),
      appBar: AppBar(
        backgroundColor: const Color(0xff091127),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back)),
        title: GradientText("Now Playing",
            style: const TextStyle(
                fontFamily: "poppinz",
                fontSize: 20,
                letterSpacing: 1,
                fontWeight: FontWeight.w500),
            colors: const [
              Color(0xffffffff),
              Color(0xffffffff),
            ]),
        centerTitle: true,
      ),
      body: assetsAudioPlayer.builderCurrent(
          builder: (context, Playing? playing) {
        final myAudio = find(widget.myaudiosong, playing!.audio.assetAudioPath);
        final currentSong = databaseSong.firstWhere(
            (element) => element.id.toString() == myAudio.metas.id.toString());

        likedSongS = box.get("favorites")!;
        if (playing.audio.assetAudioPath.isEmpty) {
          return const Center(
            child: Text('Loading....!!!'),
          );
        } else {
          return Column(
            children: [
              Container(
                width: size.width * 1.5,
                height: size.height * 0.3,
                margin: const EdgeInsets.only(left: 80, top: 50, right: 80),
                child: QueryArtworkWidget(
                  id: int.parse(myAudio.metas.id!),
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: ClipRect(
                    child: Image.asset(
                      'assets/ArtMusicMen.jpg.jpg',
                      width: size.width * 0.5,
                      height: size.height * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  artworkBorder: BorderRadius.circular(10),
                ),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              SizedBox(
                height: size.height * 0.05,
                width: size.width * 0.7,
                child: Marquee(
                  text: myAudio.metas.title.toString(),
                  pauseAfterRound: const Duration(seconds: 3),
                  velocity: 30,
                  blankSpace: 50,
                  style: const TextStyle(
                      fontFamily: "poppinz",
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                myAudio.metas.artist.toString() == '<unknown>'
                    ? 'unknown Artist'
                    : myAudio.metas.artist.toString(),
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              SizedBox(
                height: size.height * 0.09,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: BlocBuilder<PlayerCubit, PlayerCubitState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        likedSongS
                                .where((element) =>
                                    element.id.toString() ==
                                    currentSong.id.toString())
                                .isEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.favorite_outline,
                                  size: 27,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  likedSongS.add(currentSong);
                                  box.put("favorites", likedSongS);
                                  context
                                      .read<PlayerCubit>()
                                      .changeIcon(Icons.favorite_outline);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                      "Added to Favourites",
                                      style: TextStyle(
                                        fontFamily: "poppinz",
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xffdd0021),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ));
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  size: 27,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  likedSongS.removeWhere((elemet) =>
                                      elemet.id.toString() ==
                                      currentSong.id.toString());
                                  box.put("favorites", likedSongS);
                                  context
                                      .read<PlayerCubit>()
                                      .changeIcon(Icons.favorite);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: const Text(
                                      "Removed From Favourites",
                                      style: TextStyle(
                                        fontFamily: "poppinz",
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xffdd0021),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ));
                                },
                              ),
                        IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20))),
                                  context: context,
                                  builder: (context) =>
                                      PlaylistNow(song: myAudio));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: const Text(
                                  "Added to Playlist",
                                  style: TextStyle(
                                    fontFamily: "poppinz",
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xffdd0021),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ));
                            },
                            icon: const Icon(
                              Icons.playlist_add,
                              color: Colors.white,
                              size: 35,
                            ))
                      ],
                    );
                  },
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: assetsAudioPlayer.builderRealtimePlayingInfos(
                      builder: (context, infos) {
                    Duration currentposition = infos.currentPosition;
                    Duration totalduration = infos.duration;
                    return ProgressBar(
                        timeLabelTextStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        thumbColor: Colors.white,
                        baseBarColor: Colors.grey,
                        progressBarColor: Colors.red,
                        bufferedBarColor: Colors.red,
                        thumbRadius: 10,
                        barHeight: 4,
                        progress: currentposition,
                        total: totalduration,
                        onSeek: ((to) {
                          assetsAudioPlayer.seek(to);
                        }));
                  })),
              SizedBox(
                height: size.height * 0.02,
              ),
              BlocBuilder<PlayerCubit, PlayerCubitState>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            assetsAudioPlayer.toggleShuffle();
                            assetsAudioPlayer.isShuffling.value
                                ? context
                                    .read<PlayerCubit>()
                                    .changeIcon(Icons.shuffle_on_rounded)
                                : context
                                    .read<PlayerCubit>()
                                    .changeIcon(Icons.shuffle);
                          },
                          icon: assetsAudioPlayer.isShuffling.value
                              ? const Icon(
                                  Icons.shuffle_on_outlined,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.shuffle,
                                  color: Colors.white,
                                )),
                      prevvisible
                          ? Visibility(
                              visible: prevvisible,
                              child:
                                  StatefulBuilder(builder: (context, setstate) {
                                return IconButton(
                                    onPressed: () async {
                                      // setState(() async {
                                      widget.index = widget.index + 1;
                                      if (widget.index !=
                                          audiosongs.length - 1) {
                                        nxtvisible = true;
                                      }

                                      if (preDone) {
                                        preDone = false;
                                        await assetsAudioPlayer.previous();
                                        preDone = true;
                                      }
                                      // assetsAudioPlayer.previous();
                                      //});
                                      addrecent(index: widget.index);
                                    },
                                    icon: const Icon(
                                      Icons.skip_previous_sharp,
                                      color: Colors.white,
                                      size: 30,
                                    ));
                              }),
                            )
                          : const SizedBox(
                              width: 50,
                            ),
                      PlayerBuilder.isPlaying(
                          player: assetsAudioPlayer,
                          builder: (context, isPlaying) {
                            return GestureDetector(
                              onTap: () async {
                                await assetsAudioPlayer.playOrPause();
                              },
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          }),
                      nxtvisible
                          ? Visibility(
                              visible: nxtvisible,
                              child:
                                  StatefulBuilder(builder: (context, setstate) {
                                return IconButton(
                                    onPressed: () async {
                                      widget.index = widget.index + 1;
                                      if (widget.index > 0) {
                                        prevvisible = true;
                                      }
                                      if (nextDone) {
                                        nextDone = false;
                                        await assetsAudioPlayer.next();
                                        nextDone = true;
                                      }
                                      //assetsAudioPlayer.next();

                                      addrecent(index: widget.index);
                                    },
                                    icon: const Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                      size: 30,
                                    ));
                              }),
                            )
                          : const SizedBox(
                              width: 50,
                            ),

                      assetsAudioPlayer.builderLoopMode(
                        builder: (context, loopMode) {
                          return IconButton(
                            onPressed: () {
                              if (loopMode == LoopMode.none) {
                                assetsAudioPlayer.setLoopMode(LoopMode.single);
                              } else {
                                assetsAudioPlayer.setLoopMode(LoopMode.none);
                              }
                            },
                            icon: (loopMode == LoopMode.none)
                                ? const Icon(
                                    Icons.repeat,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.repeat_on_outlined,
                                    color: Colors.white,
                                  ),
                          );
                        },
                      ),

                      // IconButton(
                      //     onPressed: () {
                      //       // setState(() {
                      //         if (repeat % 2 == 0) {
                      //           assetsAudioPlayer.setLoopMode(LoopMode.single);
                      //           repeat++;
                      //         } else {
                      //           assetsAudioPlayer.setLoopMode(LoopMode.none);
                      //           repeat++;
                      //         }
                      //       // });
                      //     },
                      //     icon: repeat % 2 == 0
                      //         ? const Icon(
                      //             Icons.repeat,
                      //             color: Colors.white,
                      //           )
                      //         : const Icon(
                      //             Icons.repeat_on_outlined,
                      //             color: Colors.white,
                      //           ))
                    ],
                  );
                },
              )
            ],
          );
        }
      }),
    );
  }
}
