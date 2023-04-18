import 'package:flutter/material.dart';
import 'choosing_system.dart';

class SelectedShops with ChangeNotifier{
  List<Shop> _shoplist =[Shop(["232","김가네","한식","010-1234-5678","흑석","32","34",
    "https://scontent-gmp1-1.xx.fbcdn.net/v/t1.6435-9/80229271_1354028604800221_969893994433609728_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=-F1x2bzA9C4AX8epbbt&_nc_ht=scontent-gmp1-1.xx&oh=00_AfBOkSexfS5WA6lfPgmhJtZpjKIOv5QLRcpfh8-37W1ovg&oe=639A9FCC"
    ,"153","2.7","100"],["김밥","김치볶음밥"],[4000,7000]),
    Shop(["232","카우버거","패스트푸드",
      "010-1234-5678","흑석","32","34",
      "https://img.etoday.co.kr/pto_db/2019/07/20190703153929_1343708_1200_900.JPG"
      ,"300","4.0","50"],
        ["치즈버거","햄버거"],[600, 500]),
    Shop(["232","서브웨이","양식","010-1234-5678","흑석","32","34",
      "https://mblogthumb-phinf.pstatic.net/MjAyMDA1MjFfNjUg/MDAxNTkwMDUwMzQwNDIz.xqWzenpIuIwhPZpesda-oks2ZrVCyHYnDC0TarD3nW8g.B2wKAXIiwz1SMcHREDVD6_FFq94feHlwye-J1jRL_OAg.JPEG.kueric12/%25EC%2584%259C%25EB%25B8%258C%25EC%259B%25A8%25EC%259D%25B42016-now.jpg?type=w800",
      "450","3.8","200"],["이탈리안비엠티","풀드포크"],[20000,18000])];
  List<Shop> get shoplist => _shoplist;

  void addshop(Shop shop){
    _shoplist.add(shop);
    notifyListeners();
  }

  void addshoplist(List<Shop> shops){
    _shoplist=shops;
    notifyListeners();
  }

  void removeshop(Shop shop){
    _shoplist.remove(shop);
    notifyListeners();
  }

  void filtering(Filter filter) {
    _shoplist=Algorithm(_shoplist,filter);
    notifyListeners();
  }





}