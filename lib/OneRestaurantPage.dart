import 'package:flutter/material.dart';
import 'package:pj/RestaurantInfoPage.dart';
import 'Algorithm/choosing_system.dart';
import 'package:provider/provider.dart';
import 'Algorithm/ShoplistProvider.dart';

/* [ 하나의 식당만 보여주는 페이지 ]----------------------------------
  필터의 결과로 하나의 식당만 보여주는 페이지
  SelectResultViewPage에서 하나씩 볼래요 선택 후 결정 버튼 눌렀을 시 진입
----------------------------------------------------------------*/
List<Shop> shops=[];
int index=0;

class OneRestaurantPage extends StatefulWidget {
  const OneRestaurantPage({Key? key}) : super(key: key);

  @override
  State<OneRestaurantPage> createState() => _OneRestaurantPage();
}

class _OneRestaurantPage extends State<OneRestaurantPage> {
  //-- 여기서부터 --------------------------
  String RestaurantInfoName = '음식점 이름';
  String RestaurantInfoField = '음식점 분야';
  String RestaurantInfoGrade = '4.5';
  int RestaurantInfoReviewNum = 50;
  int RestaurantInfoNemuNum = 10;
  String RestaurantExplanation = '음식점설명어저구어쩌구';

  String ImgLink = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSo3EvtoELv_W5IoiYUsPvIpt7u8B-atj3PCA&usqp=CAU';

  final List<String> nemu = <String>['A', 'B', 'C'];
  final List<int> price = <int>[600, 500, 100];
  //-- 여기까지 ------------------------------
  //넘겨받을 레스토랑 데이터

  //마지막 페이지
  void _isLastPage(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            content: Text('마지막 페이지입니다.'),
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
    shops=selectshoplist.shoplist;

    return Scaffold(
      body:Column(
        children:[

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const SizedBox(
                  height: 100,
                ),

                const Text(
                  '여긴 어때요?',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Column(
                  children: [
                    Image.network(
                      shops[index].placeUrl,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),

                //음식점 이름
                Text(
                  shops[index].name,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),

                //음식점 분야
                Text(
                  shops[index].category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                //별점, 리뷰수
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '★ ${shops[index].rating}',
                      style: const TextStyle(
                        fontSize: 16,
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

                const SizedBox(
                  height: 18,
                ),

                //영업시간
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      shops[index].openhours,
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

                //현재 위치에서의 거리
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '현재 위치에서 식당까지 ',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1,
                      ),
                    ),

                    Text(
                      '${shops[index].distance}m',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.orangeAccent,
                        height: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),

          //하단 버튼 영역
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){

                      index++;

                      if(index >= shops.length){
                        index--;
                        _isLastPage();
                      } else {
                        setState(() {

                        });
                      }

                    },
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        )
                    ),
                    child: const Text('다른 곳이 좋아요'),
                  ),

                  ElevatedButton(
                    onPressed: (){
                      //해당 식당 세부페이지로 이동
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RestaurantInfoPage(shops: shops[index]))
                      );
                    },
                    child: const Text(
                      '여기로 갈래요',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]
      )
    );
  }
}