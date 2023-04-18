import 'dart:async';

//로그아웃 관련
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:pj/Algorithm/ShoplistProvider.dart';
import 'package:pj/LoginPage.dart';
import 'package:provider/provider.dart';
import 'FilterPage_restapi.dart';
import 'RestaurantListPage.dart';
import 'RestaurantInfoPage.dart';
import 'package:pj/Algorithm/choosing_system.dart';

import 'package:naver_map_plugin/naver_map_plugin.dart';
//사용자 현재 위치
import 'package:geolocator/geolocator.dart';

/* [ 지도 페이지 ]---------------------------------------------
  지도 보여주는 페이지
------------------------------------------------------------*/
List<Shop> alist=[];
class MapPage extends StatefulWidget {
  //const MapPage({Key? key}) : super(key: key);
  const MapPage({super.key, required this.pos, required this.markers});

  final Position pos;
  final List<Marker> markers;
  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {

  Completer<NaverMapController> _controller = Completer();
  final _formKey = GlobalKey<FormState>();

  void initState(){
    super.initState();
    for(int i=0;i<widget.markers.length;i++){
      widget.markers[i].onMarkerTab=_onMarkerTap;
    }

  }


  void _onMarkerTap(Marker marker, Map<String, int> iconSize){
    Shop marker_shop =temp(marker.markerId);


    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RestaurantInfoPage(shops: marker_shop))
    );

  }
  Shop temp(String marker_id) {
    //marker_id에 해당하는 객체 찾기
    List<String> list = [];
    List<String> menulistss = [];
    List<int> priceslist = [];
    for (int i = 0; i < alg_data.length; i++) { //alg_data.length

      if (alist[i].id == marker_id) {
        //id
        return alist[i];
      }
    }
      Shop marker_shop;
      marker_shop = Shop(list, menulistss,
          priceslist); //(List<String> list, List<String> menulistss, List<int> priceslist);
      return marker_shop;;

  }

  void _logoutDone(){
    showDialog(
        context: context,
        builder: (BuildContext context){

          //3초 뒤 자동으로 창 닫힘
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context);

          });

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            title: Text('로그아웃 되었습니다!'),
            content: Text('확인 버튼을 누르시거나, \n혹은 3초 뒤 자동으로 로그인 화면으로 돌아갑니다.'),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('확인'))
            ],
            actionsAlignment: MainAxisAlignment.end,
          );

        });
  }


  @override
  Widget build(BuildContext context) {
    SelectedShops selectshoplist = Provider.of<SelectedShops>(context);
    alist=shops;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -5,
        title: Text(
          '아, 뭐 먹지?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        leading: const Icon(
          Icons.dining_outlined,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_rounded),
            color: Colors.white,
            onPressed:(){

              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => RestaurantListPage(pos: widget.pos,markers:widget.markers)
                  ), (route) => false);
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: (){
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context){
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      content: Text(
                        '로그아웃하시겠습니까?',
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('아니오')
                        ),
                        SizedBox(
                          width: 40,
                        ),

                        TextButton(
                            onPressed: (){
                              FirebaseAuth.instance.signOut();
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) => const LoginPage()
                                  ), (route) => false);
                              _logoutDone();
                            },
                            child: Text('네')
                        ),
                      ],
                      actionsAlignment: MainAxisAlignment.center,
                    );
                  });
            },
          ),


        ],
      ),

      body:Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Container(
              color: Colors.blue,
              child:  _naverMap(),//Text('지도 자리입니다~'),
            ),
          ),

          Positioned(
            top: 5,
            left: 10,
            child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) => const FilterPage_rapi()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.menu),
                    Text(
                      ' 필터',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ),

        ],
      ),
    );
  }

  _naverMap(){
    return Expanded(
        child: Stack(
          children: <Widget>[
            NaverMap(
              //첫 화면 표시 위치
              initialCameraPosition: CameraPosition(
                //현재 위치
                target: LatLng(widget.pos.latitude, widget.pos.longitude),
                zoom: 17,
              ),
              //위치 버튼
              locationButtonEnable: true,
              indoorEnable: true,
              markers: widget.markers,
              //onMarkerTap: _onMapTap,
              onMapCreated: onMapCreated,
            ),
          ],
        )
    );
  }

  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}
