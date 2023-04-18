import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class CurrLocation with ChangeNotifier{
  late Position pos;
  List<Marker> markers=[];

  void update(Position poss, List<Marker> marks){
    pos=poss;
    markers=marks;
  }

}