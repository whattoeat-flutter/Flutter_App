import 'package:flutter/material.dart';
import 'Algorithm/choosing_system.dart';
import 'package:pj/map/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'Algorithm/ShoplistProvider.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'MapPage.dart';
import 'dart:async';

/* [ 식당 세부정보 페이지 ]---------------------------------------
  식당 세부정보를 받아와서 보여주는 페이지
------------------------------------------------------------*/
List<Marker> _markers = [];

class RestaurantInfoPage extends StatefulWidget {
  const RestaurantInfoPage({Key? key, required this.shops}) : super(key: key);
  final Shop shops;
  @override
  State<RestaurantInfoPage> createState() => _RestaurantInfoPage();
}

class _RestaurantInfoPage extends State<RestaurantInfoPage> {
  //값 받아오기
  Completer<NaverMapController> _controller = Completer();
  //구분선
  Widget DividingLine(double i){
    return SizedBox(
      height: i,
      child: Container(
        color: Colors.black12,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {

    CurrLocation currLocation = Provider.of<CurrLocation>(context);
    _markers=currLocation.markers;


    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => MapPage(pos: currLocation.pos,
                            markers: currLocation.markers)
                    ), (route) => false);
              },
              icon: const Icon(Icons.home),
          ),
        ],
      ),


      body: SingleChildScrollView(
        child: Column(
          children: [
            //이미지파트
            Stack(
              children: [
                Image.network(
                  '${widget.shops.placeUrl}',
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                ),

                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 8,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.grey.withOpacity(0.0),
                            Colors.black12,
                          ],
                        )
                    ),
                  ),
                ),

              ],
            ),



            //첫번째칸(음식점이름, 분야, 별점, 리뷰수)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //음식점 이름과 분야
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.shops.name,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        widget.shops.category,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                  //음식점 평점과 리뷰수
                  Column(
                    children: [
                      Text(
                        '★ ${widget.shops.rating}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Text(
                        '(리뷰수 ${widget.shops.review_count})',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            //구분선=========================================================
            DividingLine(3),

            //두번째칸(음식점 주소, 지도, 영업시간, 전화번호)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //음식점 세부 정보
                  //주소
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_sharp,
                        color: Colors.grey,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          widget.shops.address,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(
                    height: 10,
                  ),

                  //지도
                  Container(
                    height: 130,
                    color: Colors.blue,
                    child:  _naverMap(),//Text('지도 자리입니다~'),
                  ),

                  //현재 위치에서의 거리
                  Text(
                    '   현재 위치에서 식당까지  ${widget.shops.distance}m',
                    style:const TextStyle(
                      fontSize: 12,
                    ),
                  ),


                  const SizedBox(
                    height: 10,
                  ),

                  //영업시간
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 18,
                      ),


                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${widget.shops.openhours}',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //전화번호
                  Row(
                    children: [
                      const Icon(
                        Icons.call,
                        color: Colors.grey,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        '${widget.shops.phonenum}',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //1인당 평균가격
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.grey,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        '1인당 평균 가격  ${widget.shops.price}원',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),


                  //추천도
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.grey,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Text(
                        '추천도 ${(widget.shops.priority*10).toInt()}%',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),

                ],
              ),
            ),

            //구분선=========================================================
            DividingLine(8),

            //세번째칸(메뉴)
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //제목Row
                  Row(
                    children: [
                      const Text(
                        '메뉴 ',
                        style: TextStyle(
                          fontSize: 18,
                            height: 1,
                        ),
                      ),
                      Text(
                        '${widget.shops.menulist.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.orangeAccent,
                          height: 1,
                        ),
                      ),
                    ],
                  ),

                  //메뉴
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    itemCount: widget.shops.menulist.length,
                    itemBuilder: (BuildContext context, int index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.shops.menulist[index],
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${widget.shops.menuprices[index]}원',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      );

                    },
                  ),

                  //구분선
                  const SizedBox(
                    height: 5,
                  ),
                  //구분선=========================================================
                  DividingLine(1),

                  //메뉴 더보기
                  TextButton(
                    style: const ButtonStyle(alignment: Alignment.centerRight),
                    child: const Text(
                      '메뉴 전체보기 >',
                      textAlign: TextAlign.right,
                    ),
                    onPressed: (){
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

                                  //메뉴전체보기
                                  return Container(
                                    height: 450,
                                    width: width - 60,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: [
                                          //메뉴제목
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  '메뉴 ',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    height: 1,
                                                  ),
                                                ),
                                                Text(
                                                  '${widget.shops.menulist.length}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    height: 1,
                                                    color: Colors.orangeAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          //구분선=================
                                          DividingLine(1),

                                          //메뉴목록
                                          ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                                            itemCount: widget.shops.menulist.length,
                                            itemBuilder: (BuildContext context, int index){
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 1),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      widget.shops.menulist[index],
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${widget.shops.menuprices[index]}원',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              insetPadding: const EdgeInsets.all(5),
                              contentPadding: const EdgeInsets.all(0),
                            );
                          }
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
                target: LatLng(double.parse(widget.shops.locY), double.parse(widget.shops.locX)),
                zoom: 17,
              ),
              //위치 버튼
              locationButtonEnable: true,
              indoorEnable: true,
              markers: one_marker(_markers),
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

  List<Marker> one_marker(List<Marker> markers){
    List<Marker> selected=[];

    for(int i=0;i<markers.length;i++){
      if(markers[i].captionText==widget.shops.name){
        selected.add(markers[i]);
      }

    }

    return selected;
  }


}