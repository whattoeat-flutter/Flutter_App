import 'dart:async';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:pj/Algorithm/ShoplistProvider.dart';
import 'package:pj/RestaurantInfoPage.dart';
import 'package:pj/Algorithm/choosing_system.dart';
//사용자 현재 위치
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//사용자 위치
bool servicestatus = false;
bool haspermission = false;
late LocationPermission permission;
String long = "", lat = "";
late StreamSubscription<Position> positionStream;
List<Marker> _markers = [];

late Position position_map;
List<Map> alg_data = [{}];

checkGps() async {
  //late Position gps_position;
  servicestatus = await Geolocator.isLocationServiceEnabled();
  if(servicestatus){

    print('1');
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      }else if(permission == LocationPermission.deniedForever){
        print("'Location permissions are permanently denied");
      }else{
        haspermission = true;
      }
    }else{
      haspermission = true;
    }

    if(haspermission){
      //사용자 위치 파악
      getLocation();
    }
  }else{
    print("GPS Service is not enabled, turn on GPS location");
  }

}

getLocation() async {
  late Position position;

  LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high, //accuracy of the location data
    distanceFilter: 100, //minimum distance (measured in meters) a
    //device must move horizontally before an update event is generated;
  );

  position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  position_map=position;
  searchID(position);
}
searchID(Position w_pos) async {
  //w_pos.
  int page=1;
  String str_url_1="https://dapi.kakao.com/v2/local/search/category.json?" +
      "category_group_code=FD6"+
      "&page="+page.toString()+
      "&size=15&sort=distance"+
      "&y="+w_pos.latitude.toString()+
      "&x="+w_pos.longitude.toString()
  ;
  String API_key="KakaoAK d73a05d9aa0d601170d3de05ae441263";

  var url = Uri.parse(str_url_1);
  var response_1 = await http.get(url, headers: {"Authorization": API_key});

  parsing(response_1);
}

parsing(var response_json){
  List data = [];
  var dataConvertedToJSON = json.decode(response_json.body);
  Map result_map = {};
  List result = dataConvertedToJSON["documents"];
  result= result.sublist(0,10);
  //카카오에서 받아온 카페정보 10개에 대해, id가 key값이 되도록 맵(result_map) 생성
  for (int i = 0; i<result.length;i++){
    result_map.addAll({result[i]['id']: result[i]});
  }

  //마커 추가
  make_marker_list(result_map);
  //id를 서버로 넘김
  send2server(result_map);

}
make_marker_list(Map data_kko){
  data_kko.forEach((key, value) {
    _markers.add(Marker(
      markerId: key,//DateTime.now().toIso8601String(),
      position: LatLng(double.parse(value['y']), double.parse(value['x'])),//pos_marker,
      //infoWindow: '테스트',
      captionText: value['place_name'],
      onMarkerTab: _onMarkerTap,
    ));
  });
}
void _onMarkerTap(Marker marker, Map<String, int> iconSize){
  Shop marker_shop =temp(marker.markerId);


}
Shop temp(String marker_id){
  //marker_id에 해당하는 객체 찾기
  List<String> list=[];
  List<String> menulistss=[];
  List<int> priceslist=[];
  for(int i=0;i<alg_data.length;i++){//alg_data.length

    if(alg_data[i]['id'] == marker_id){
      //id
      list.insert(0,alg_data[i]['id']);
      //name
      list.insert(1,alg_data[i]['name']);
      //category
      list.insert(2,alg_data[i]['category']);
      //phonenum
      list.insert(3,alg_data[i]['phonenum']);
      //address
      list.insert(4,alg_data[i]['address']);
      //locx
      list.insert(5,alg_data[i]['locX']);
      //locy
      list.insert(6,alg_data[i]['locY']);
      //placeUrl
      list.insert(7,alg_data[i]['placeUrl']);
      //review_count
      list.insert(8,alg_data[i]['reveiw_count']);
      /*if(alg_data[i]['reveiw_count'] == null){
          list[8]="";
        }else{
          list[8]=alg_data[i]['reveiw_count'];
        }*/
      //
      //rating
      list.insert(9,alg_data[i]['rating'].toString());
      /*if(alg_data[i]['rating'] == null){
          list[9]="0";
        }else{
          list[9]=alg_data[i]['rating'].toString();
        }*/

      //distance
      list.insert(10,"0");//distance는 없어서 0으로 가정

      //menulistss
      for(int ml=0;ml<alg_data[i]['menulist'].length;ml++){
        menulistss.add(alg_data[i]['menulist'][ml]);
      }
      for(int mp = 0;mp<alg_data[i]['menuprices'].length;mp++){
        priceslist.add(int.parse(alg_data[i]['menuprices'][mp]));
      }

    }
  }

  //print(alg_data[0]['menulist'][0]);
  Shop marker_shop;
  marker_shop = Shop(list, menulistss, priceslist);//(List<String> list, List<String> menulistss, List<int> priceslist);
  return marker_shop;;

}
send2server(Map data_kko) async {
  List<String> id_list=[];

  data_kko.forEach((key, value) {
    id_list.add(key.toString());
  });

  Map request_id = {
    'ids' : id_list
  };

  var body_id = json.encode(request_id);
  //string맞는지 확인 부탁드립니다.
  String str_url_server='http://35.243.115.214:8080/parse/';
  var url_server = Uri.parse(str_url_server);
  http.Response response_server = await http.post(
      url_server,
      headers: //<String, String>
      {
        'Content-Type': 'application/json',
      },
      body: body_id
  );

  var responseBody = utf8.decode(response_server.bodyBytes);
  var dataConvertedToJSON_server = jsonDecode(responseBody);//json.utf8.decode(response_server.body);
  //List<Map> alg_data;
  alg_data = send2choosing(dataConvertedToJSON_server, data_kko);

}
//파싱함수
send2choosing(var dataConvertedToJSON_server, Map data_kko){
  List<Map> shop_list = [];

  dataConvertedToJSON_server.forEach((key, value) {
    Map shop = {};
    Map kakao={};
    //id
    shop['id']=key;
    //name kko
    //서버에서 받아온 id와 일치하는 id를 가진 kakao_response
    kakao = data_kko[key];
    shop['name'] = kakao['place_name'];
    //category kko
    shop['category'] = kakao['category_name'];
    //phonenum
    shop['phonenum'] = value['phone'].toString();
    //address
    shop['address']  = value['address'].toString();
    //locX kko
    shop['locX'] = kakao['x'];
    //locY kko
    shop['locY'] = kakao['y'];
    //placeUrl
    shop['placeUrl'] = value['picture'].toString();
    //menulist, menuprices
    Map menu = {};
    List menulist=[];
    List menuprices=[];
    menu = value['menus'];
    if(menu.length > 0){
      menu.forEach((key, value) {
        menulist.add(key);
        menuprices.add(value);
      });
    }else{
      print("\'menus\' is empty.");
    }
    shop['menulist'] = menulist;
    shop['menuprices'] = menuprices;

    //review_count
    shop['review_count']  = int.parse(value['number_of_ratings']);
    //rating
    shop['rating']  = double.parse(value['number_of_ratings']);

    shop_list.add(shop);
  });
  //shop_list가 algorithm에 전송할 map입니다.
  return shop_list;
}