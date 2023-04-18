import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:pj/map/LocationProvider.dart';
import 'package:pj/Algorithm/ShoplistProvider.dart';
import 'package:pj/RestaurantInfoPage.dart';
import 'MapPage.dart';
import 'SelectResultViewTypePage.dart';
import 'Algorithm/choosing_system.dart';
import 'package:provider/provider.dart';
//사용자 현재 위치
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
/* [ 필터 페이지 ]---------------------------------------
  필터페이지 중 첫번째
  식당 종류, 1인당 가격, 거리, 별점 및 리뷰를 선택하고
  선택값들을 추천함수로 넘겨줍니다
------------------------------------------------------------*/
List<Shop> alist=[];
bool loaded=false;


late Position position_map;
List<Map> alg_data = [{}];
class FilterPage_rapi extends StatefulWidget {
  const FilterPage_rapi({Key? key}) : super(key: key);
  @override
  State<FilterPage_rapi> createState() => _FilterPage_rapi();
}

class _FilterPage_rapi extends State<FilterPage_rapi> {
  bool showSpinner = false;
  bool koreanFood = false;
  bool chineseFood = false;
  bool japaneseFood = false;
  bool westernFood = false;
  bool dessert = false;
  bool fastFood = false;
  bool alcohol = false;
  bool other = false;

  bool price0 = false;  //만원 이하
  bool price1 = false;  //1만원대
  bool price2 = false;  //2만원대
  bool price3 = false;  //3만원 이상

  bool review = false;
  bool distance = false;
  int dis_value = 0;
  int rev_value = 0;

  //사용자 위치
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  void _checked(String type){
    setState(() {
      switch(type){
        case 'koreanFood' :
          koreanFood = !koreanFood;
          break;
        case 'chineseFood' :
          chineseFood = !chineseFood;
          break;
        case 'japaneseFood':
          japaneseFood = !japaneseFood;
          break;
        case 'westernFood':
          westernFood = !westernFood;
          break;
        case 'dessert' :
          dessert = !dessert;
          break;
        case 'fastFood' :
          fastFood = !fastFood;
          break;
        case 'alcohol':
          alcohol = !alcohol;
          break;
        case 'other':
          other = !other;
          break;
        case 'price0':
          price0 = !price0;
          break;
        case 'price1':
          price1 = !price1;
          break;
        case 'price2':
          price2 = !price2;
          break;
        case 'price3':
          price3 = !price3;
          break;
      }
    });


  }


  //text - 버튼 하단 텍스트, type - 버튼on/off 이미지 변경을 위한,
  //selectType - 해당 조건의 선택유무를 저장함, 추천함수에 넘겨줄 값
  Widget CustomButton(String text, String type, bool selectType){
    return TextButton(
      onPressed: (){
        _checked(type);
      },
      child: Column(
        children: [
          Image.asset(
            selectType ? 'assets/checked$type.png' : 'assets/unchecked$type.png',
            width: 61,
            height: 61,
            fit: BoxFit.fill,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: selectType ? Colors.orange : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  //거리
  Widget CustomRadioButton_dis(String text, int index){
    return OutlinedButton(
      onPressed: (){
        setState(() {
          dis_value = index;
        });
      },

      style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: (dis_value == index) ? Colors.orange : Colors.grey,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(30)
              )
          )
      ),
      child: Text(
        text,
        style: TextStyle(
          color: (dis_value == index) ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }
  Widget CustomRadioButton_rev(String text, int index){
    return OutlinedButton(
      onPressed: (){
        setState(() {
          rev_value = index;
        });
      },

      style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: (rev_value == index) ? Colors.orange : Colors.grey,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(30)
              )
          )
      ),
      child: Text(
        text,
        style: TextStyle(
          color: (rev_value == index) ? Colors.orange : Colors.grey,
        ),
      ),
    );
  }

  Widget DividingLine(){
    return SizedBox(
      height: 1,
      child: Container(
        color: Colors.grey,
      ),
    );
  }

  List<Marker> _markers = [];




  Future checkGps() async {
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
        await getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }
    return true;
  }

  Future getLocation() async {
    late Position position;

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position_map=position;
    await searchID(position);
  }
  Future searchID(Position w_pos) async {
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

    await parsing(response_1);
  }

  Future parsing(var response_json) async{
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
    await make_marker_list(result_map);
    //id를 서버로 넘김
    await send2server(result_map);

  }
  Future make_marker_list(Map data_kko) async{
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


      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RestaurantInfoPage(shops: marker_shop))
      );

  }
  Shop temp(String marker_id){
    //marker_id에 해당하는 객체 찾기
    List<String> list=[];
    List<String> menulistss=[];
    List<int> priceslist=[];
    for(int i=0;i<alg_data.length;i++){//alg_data.length

      if(alist[i].id == marker_id){
        //id
        return alist[i];

      }

    }

    //print(alg_data[0]['menulist'][0]);
    Shop marker_shop;
    marker_shop = Shop(list, menulistss, priceslist);//(List<String> list, List<String> menulistss, List<int> priceslist);
    return marker_shop;;

  }
  Future send2server(Map data_kko) async {
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
    alg_data = await send2choosing(dataConvertedToJSON_server, data_kko);
    alist = await map_to_shop(alg_data,position_map);
    loaded=true;
    return true;
  }
  //파싱함수
  Future send2choosing(var dataConvertedToJSON_server, Map data_kko) async{
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
      shop['operation'] = value['operation'];
      shop['distance'] = int.parse(kakao['distance']);
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
      shop['review_count']  = value['number_of_ratings'].toString();
      //rating
      shop['rating']  = value['rating'].toString();

      shop_list.add(shop);
    });
    //shop_list가 algorithm에 전송할 map입니다.
    return shop_list;
  }

  @override
  Widget build(BuildContext context) {
    SelectedShops selectshoplist = Provider.of<SelectedShops>(context);
    CurrLocation curr_location = Provider.of<CurrLocation>(context);
    return Scaffold(
      body:CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '원하는 조건을 설정하세요!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
              background: null, //이미지 넣으면 좋을듯..
            ),
          ),

          //조건 선택 부분
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                    //음식 종류 제목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          '음식 종류',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    //음식종류선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton('한식', 'koreanFood', koreanFood),
                        CustomButton('중식', 'chineseFood', chineseFood),
                        CustomButton('일식', 'japaneseFood', japaneseFood),
                        CustomButton('양식', 'westernFood', westernFood),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton('디저트', 'dessert', dessert),
                        CustomButton('패스트푸트', 'fastFood', fastFood),
                        CustomButton('주점', 'alcohol', alcohol),
                        CustomButton('기타', 'other', other),
                      ],
                    ),


                    const SizedBox(
                      height: 15,
                    ),

                    //구분선 -----------------------------------------
                    DividingLine(),

                    const SizedBox(
                      height: 20,
                    ),

                    //가격대 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          '1인당 가격',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),

                        Text(
                          '중복선택가능',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //가격대 선택
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton('~만원', 'price0', price0),
                        CustomButton('1만원 대', 'price1', price1),
                        CustomButton('2만원 대', 'price2', price2),
                        CustomButton('3만원~', 'price3', price3),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //구분선 --------------------------------------------
                    DividingLine(),

                    const SizedBox(
                      height: 20,
                    ),

                    //거리
                    const Text(
                      '거리',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomRadioButton_dis('상관없음', 0),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomRadioButton_dis('근거리 우선', 1),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //구분선 --------------------------------------------
                    DividingLine(),

                    const SizedBox(
                      height: 20,
                    ),

                    //리뷰
                    const Text(
                      '별점 및 리뷰',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomRadioButton_rev('상관없음', 0),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomRadioButton_rev('좋은 평가 우선', 1),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                  ],
                ),
              ),
            ),
          ),

          //하단버튼
          SliverToBoxAdapter(
            child:  Container(
              height: 50,
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async{
                        //로딩창
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            content: Container(
                              height: 300,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: SizedBox(
                                        height: 50,
                                        width: 50,
                                        child:
                                          new CircularProgressIndicator(
                                            valueColor: new AlwaysStoppedAnimation(Colors.amber),
                                            strokeWidth: 5.0
                                          ),
                                      )
                                    ),
                                  ),

                                  const Text(
                                    '추천 순위 계산 중 ...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),

                                  const Text(
                                    '잠시만 기다려주세요!',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        await checkGps();
                        //선택된 필터값들 추천함수로 전달
                        Filter filterr = Filter(
                            [koreanFood, chineseFood, japaneseFood,
                              westernFood, dessert, fastFood, alcohol, other],
                            dis_value, rev_value
                            , [price0, price1, price2, price3]);
                        selectshoplist.addshoplist(alist);
                        selectshoplist.filtering(filterr);
                        curr_location.update(position_map, _markers);
                        //결과뷰 유형 선택 페이지로 이동
                        //const SelectResultViewTypePage()));



                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Builder(
                                  builder: (context) {
                                    var height = MediaQuery
                                        .of(context)
                                        .size
                                        .height;
                                    var width = MediaQuery
                                        .of(context)
                                        .size
                                        .width;

                                    return Container(
                                      height: 450,
                                      width: width - 60,
                                      child: SelectResultViewTypePage(pos: position_map,markers: _markers),
                                    );
                                  },
                                ),
                                insetPadding: const EdgeInsets.all(5),
                                contentPadding: const EdgeInsets.all(0),
                              );
                            }
                        );

                      },
                      child: const Text(
                        '다음',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}