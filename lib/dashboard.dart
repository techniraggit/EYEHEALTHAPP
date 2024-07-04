// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
//
// class Dashboard extends StatelessWidget {
//   const Dashboard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:  Colors.white,
//       body: PersistanceNavBar(
//         menuScreenContext: context,
//         hideStatus: false,
//       ),
//     );
//   }
// }
//
//
// class PersistanceNavBar extends StatefulWidget {
//   const PersistanceNavBar(
//       {super.key, this.menuScreenContext,});
//   final BuildContext? menuScreenContext;
//
//   @override
//   State<PersistanceNavBar> createState() => _PersistanceNavBarState();
// }
//
// class _PersistanceNavBarState extends State<PersistanceNavBar> {
//   final PersistentTabController _controller = PersistentTabController();
//   int selectedIndex = 0;
//
//   List<Widget> _buildScreens() => [
//     HomeView(controller: _controller),
//     const DownloadPage(),
//     FavoritePage(
//       controller: _controller,
//     ),
//     MyFavEpisodesPage(
//       controller: _controller,
//     ),
//     ProfilePage(
//       controller: _controller,
//     ),
//   ];
//
//   List<PersistentBottomNavBarItem> _navBarsItems() => [
//     PersistentBottomNavBarItem(
//       icon: Column(
//         children: [
//           PodcastimSvg(
//               imagePath: homeSvg,
//               widthOfImage: 20,
//               heightOfImage: 20,
//               color: selectedIndex == 0
//                   ? PodcastimColors.vividPurple
//                   : themeProvider.darkTheme
//                   ? Colors.white
//                   : Colors.black),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             AppLocalizations.of(context)?.home ?? "",
//             style: GoogleFonts.rubik(
//                 fontSize: 12,
//                 color: selectedIndex == 0
//                     ? PodcastimColors.vividPurple
//                     : themeProvider.darkTheme
//                     ? Colors.white
//                     : Colors.black),
//           )
//         ],
//       ),
//     ),
//     PersistentBottomNavBarItem(
//       icon: Column(
//         children: [
//           PodcastimSvg(
//               imagePath: downloadSvg,
//               widthOfImage: 20,
//               heightOfImage: 20,
//               color: selectedIndex == 1
//                   ? PodcastimColors.vividPurple
//                   : themeProvider.darkTheme
//                   ? Colors.white
//                   : Colors.black),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             AppLocalizations.of(context)?.downloads ?? "",
//             style: GoogleFonts.rubik(
//                 fontSize: 12,
//                 color: selectedIndex == 1
//                     ? PodcastimColors.vividPurple
//                     : themeProvider.darkTheme
//                     ? Colors.white
//                     : Colors.black),
//           )
//         ],
//       ),
//     ),
//     PersistentBottomNavBarItem(
//       icon: Column(
//         children: [
//           PodcastimSvg(
//               imagePath: startSvg,
//               widthOfImage: 20,
//               heightOfImage: 20,
//               color: !hasInternetConnected
//                   ? const Color(0XFF868E96)
//                   : selectedIndex == 2
//                   ? PodcastimColors.vividPurple
//                   : themeProvider.darkTheme
//                   ? Colors.white
//                   : Colors.black),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             AppLocalizations.of(context)?.favorites ?? "",
//             style: GoogleFonts.rubik(
//                 fontSize: 12,
//                 color: !hasInternetConnected
//                     ? const Color(0XFF868E96)
//                     : selectedIndex == 2
//                     ? PodcastimColors.vividPurple
//                     : themeProvider.darkTheme
//                     ? Colors.white
//                     : Colors.black),
//           )
//         ],
//       ),
//     ),
//     PersistentBottomNavBarItem(
//       icon: Column(
//         children: [
//           PodcastimSvg(
//               imagePath: myFavEpisodes,
//               widthOfImage: 22,
//               heightOfImage: 20,
//               color: !hasInternetConnected
//                   ? const Color(0XFF868E96)
//                   : selectedIndex == 3
//                   ? PodcastimColors.vividPurple
//                   : themeProvider.darkTheme
//                   ? Colors.white
//                   : Colors.black),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             AppLocalizations.of(context)?.myEpisodes ?? "",
//             style: GoogleFonts.rubik(
//                 fontSize: 11,
//                 color: !hasInternetConnected
//                     ? const Color(0XFF868E96)
//                     : selectedIndex == 3
//                     ? PodcastimColors.vividPurple
//                     : themeProvider.darkTheme
//                     ? Colors.white
//                     : Colors.black),
//           )
//         ],
//       ),
//     ),
//     PersistentBottomNavBarItem(
//       icon: Column(
//         children: [
//           PodcastimSvg(
//               imagePath: profileSvg,
//               widthOfImage: 22,
//               heightOfImage: 20,
//               color: !hasInternetConnected
//                   ? const Color(0XFF868E96)
//                   : selectedIndex == 4
//                   ? PodcastimColors.vividPurple
//                   : themeProvider.darkTheme
//                   ? Colors.white
//                   : Colors.black),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             AppLocalizations.of(context)?.profile ?? "",
//             style: GoogleFonts.rubik(
//                 fontSize: 11,
//                 color: !hasInternetConnected
//                     ? const Color(0XFF868E96)
//                     : selectedIndex == 4
//                     ? PodcastimColors.vividPurple
//                     : themeProvider.darkTheme
//                     ? Colors.white
//                     : Colors.black),
//           )
//         ],
//       ),
//     ),
//   ];
//
//   int lastSelectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() {
//       setState(() {
//         if (hasInternetConnected) {
//           selectedIndex = _controller.index;
//         } else if (_controller.index == 2 ||
//             _controller.index == 3 ||
//             _controller.index == 4) {
//           _controller.jumpToTab(0);
//         } else {
//           selectedIndex = _controller.index;
//         }
//         if (_controller.index == 1) {
//           onEditVisible = isEditingDown;
//         } else if (_controller.index == 2) {
//           onEditVisible = isEditingFavPod;
//         } else if (_controller.index == 3) {
//           onEditVisible = isEditingMyFavEpi;
//         } else {
//           onEditVisible = false;
//         }
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     themeProvider = Provider.of<DarkThemeProvider>(context);
//     return PersistentTabView(
//       context,
//       controller: _controller,
//       handleAndroidBackButtonPress: true,
//       backgroundColor:
//       themeProvider.darkTheme ? Colors.black : PodcastimColors.lightGrey,
//       screens: _buildScreens(),
//       padding: const NavBarPadding.all(8.0),
//       items: _navBarsItems(),
//       floatingActionButton: (audioHandler != null && isMusicPlayerShowing)
//           ? Container(
//         color: Colors.transparent,
//         height: 200,
//         margin: EdgeInsets.only(
//           bottom: onEditVisible ? 105 : 45,
//         ),
//         width: widthOfScreen,
//         child: Stack(
//           children: [
//             AnimatedPositioned(
//               duration: const Duration(milliseconds: 400),
//               bottom: 0,
//               child: Dismissible(
//                 key: Key('itemDismisal$dismissedId'),
//                 onDismissed: (direction) {
//                   podcastStorage.removeLastEpisodeData();
//                   dismissedId = dismissedId + 1;
//                   if (audioHandler != null) {
//                     audioHandler!.pause();
//                     audioHandler!.stop();
//                     audioHandler = null;
//                   }
//                   isMusicPlayerShowing = false;
//                   if (globalSetState != null) {
//                     globalSetState!(() {});
//                   }
//                 },
//                 child: InkWell(
//                   onTap: () {
//                     goToMusicPlayerPage(
//                       context,
//                       description: episodeDescriptionForPlaying!,
//                       epiosdeId: episodeIdForPlaying!,
//                       episodeUrl: episodeUrlForPlaying!,
//                       image: episodeImageForPlaying!,
//                       episodeTitle: episodeTitleForPlaying!,
//                       podcastTitle: podcastTitleForPlaying ?? '',
//                       podcastId: podcastIdForPlaying!,
//                       fromLocal: false,
//                       episodeLength: episodeLengthForPlaying,
//                       episodeLiked: episodeLikedForPlaying,
//                       episodePubDate: episodePubDateForPlaying!,
//                       inMyEpisodes: episodeInMyEpisodeForPlaying,
//                       heroTag: 'HeroFromPersistance',
//                       stateOfPlayer: 0,
//                     ).then((value) {
//                       if (value != null) {
//                         if (value['episodeLikedForPlaying'] != null) {
//                           episodeLikedForPlaying =
//                           value['episodeLikedForPlaying'];
//                         }
//                         if (value['episodeInMyEpisodeForPlaying'] !=
//                             null) {
//                           episodeInMyEpisodeForPlaying =
//                           value['episodeInMyEpisodeForPlaying'];
//                         }
//                       }
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 0, left: 20),
//                     child: audioHandler != null
//                         ? MusicNotificationInside()
//                         : const IgnorePointer(),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       )
//           : const IgnorePointer(),
//       hideNavigationBar: widget.hideStatus,
//       navBarStyle: NavBarStyle.simple,
//       resizeToAvoidBottomInset: false,
//       onItemSelected: (value) {
//         if (!isUserLogin) {
//           if (value == 3) {
//             showLoginBottomSheet(context);
//           }
//         }
//       },
//       navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
//           ? 0.0
//           : kBottomNavigationBarHeight,
//       bottomScreenMargin: 0,
//     );
//   }
// }
