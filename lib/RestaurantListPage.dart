import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'FilterPage_restapi.dart';
import 'MapPage.dart';
import 'RestaurantInfoPage.dart';

import 'LoginPage.dart';
import 'Algorithm/choosing_system.dart';
import 'package:provider/provider.dart';
import 'package:pj/Algorithm/ShoplistProvider.dart';
import 'package:pj/map/LocationProvider.dart';

import 'package:firebase_auth/firebase_auth.dart';

/* [ 결과 리스트 페이지 ]----------------------------------------
  식당 리스트를 받아 리스트 형식으로 표시합니다~
------------------------------------------------------------*/
List<Shop> shops=[];

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key, required this.pos, required this.markers});

  final Position pos;
  final List<Marker> markers;
  @override
  State<RestaurantListPage> createState() => _RestaurantListPage();
}

class _RestaurantListPage extends State<RestaurantListPage> {

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
    CurrLocation currLocation = Provider.of<CurrLocation>(context);
    shops=selectshoplist.shoplist;

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
            icon: const Icon(Icons.map_outlined),
            color: Colors.white,
            onPressed:(){

             Navigator.pushAndRemoveUntil(context,
                 MaterialPageRoute(
                     builder: (BuildContext context) => MapPage(pos: currLocation.pos,
                         markers: currLocation.markers)
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


      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Container(
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(0),
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
                  )

                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                itemCount: shops.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2/2.9,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (BuildContext context, int index){
                  return InkWell(
                    onTap: (){
                      //해당 상세 페이지로 연결

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RestaurantInfoPage(shops: shops[index]))
                      );
                    },

                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            '${shops[index].placeUrl}',
                            width: MediaQuery.of(context).size.width/2 -24,
                            height: MediaQuery.of(context).size.width/2 -24,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width/2 -30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //가게이름
                              Text(
                                '${index+1}. ${shops[index].name}',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              //음식점 분야
                              Text(
                                '${shops[index].category}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              //가격 별점등
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '★ ${shops[index].rating}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Text(
                                        '(리뷰수 ${shops[index].review_count})',
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),

                                  //현재 위치에서 거리
                                  Text(
                                    '${shops[index].distance}m',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
