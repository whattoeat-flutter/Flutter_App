import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'RestaurantListPage.dart';
import 'OneRestaurantPage.dart';
import 'MapPage.dart';


/* [ 결과뷰 유형 선택 페이지 ]----------------------------------
  필터 페이지 중 마지막
  결과 페이지를 하나씩 볼지, 리스트 형식으로 볼지 선택합니다
------------------------------------------------------------*/


class SelectResultViewTypePage extends StatefulWidget {
  const SelectResultViewTypePage({super.key, required this.pos, required this.markers});

  final Position pos;
  final List<Marker> markers;

  @override
  State<SelectResultViewTypePage> createState() => _SelectResultViewTypePage();
}

class _SelectResultViewTypePage extends State<SelectResultViewTypePage> {
  int ResultViewType = 0;

  Widget CustomRadioButton(String text, int index, String type){
    return TextButton(
      onPressed: (){
        setState(() {
          ResultViewType = index;
        });
      },
      child: Column(
        children: [
          Image.asset(
            (ResultViewType == index) ? 'assets/checked$type.png' : 'assets/unchecked$type.png',
            width: (MediaQuery.of(context).size.width-100)/2,
            height: (MediaQuery.of(context).size.width-100)/2,
            fit: BoxFit.fill,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: (ResultViewType == index) ? Colors.orange : Colors.grey,
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 80),
                  child: DividingLine(),
                ),


                const Text(
                  '어떤 형식으로 \n결과를 보시겠어요?',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  child: DividingLine(),
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRadioButton('하나씩 볼래요', 1, 'One'),
                    CustomRadioButton('한꺼번에 볼래요', 2, 'List'),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '뒤로가기',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: (){
                      //결과 페이지로 넘어가던... 로딩 페이지로 넘어가던...

                      //아무것도 선택하지 않은 상황이 아닐 때 =========================
                      if(ResultViewType != 0){
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => (ResultViewType == 1) ? const OneRestaurantPage() : RestaurantListPage(pos:widget.pos,markers:widget.markers)),
                                (route) => false
                        );
                        //----------------------------------- 수정함
                      }
                    },
                    child: const Text(
                      '결정',
                      style: TextStyle(
                        fontSize: 14,
                      ),
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
}