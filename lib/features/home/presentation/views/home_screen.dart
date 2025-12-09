import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:el3nab_admin/core/utils/app_colors/app_colors.dart';



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';




class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key, });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatefulWidget {

  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true; // Keep state alive when navigating away

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super when using AutomaticKeepAliveClientMixin
    final size = MediaQuery.of(context).size; // for responsive sizing
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;

    double textScale(double size) => size * (width / 400);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child:Center(child: Text('Hello admin'),)
      ),
    );
  }


  }

