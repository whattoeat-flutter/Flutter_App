/* [ 추천 알고리즘 ]---------------------------------------------
  ui는 없음.
  import해서 사용하는 함수 모음집.

------------------------------------------------------------*/
import 'dart:math';

import '../FilterPage_restapi.dart';
import 'package:flutter/material.dart';
import 'package:pj/map/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
//필터 객체

class Filter
{

  List<String> category=[];
  double emphasizedis=1;// 가중치
  double emphasizerev=1;
  List<bool> price=[false,false,false,false];


  Filter.init();
  Filter(List<bool> list,int dis_value,int rev_value,List<bool> prices)
  {
    if (list[0]==true) {
      category.add("한식");
    }
    if (list[1]==true){
      category.add("중식");
    }
    if (list[2]==true){
      category.add("일식");
    }
    if (list[3]==true){
      category.add("양식");
    }
    if (list[4]==true){
      category.add("디저트");
    }
    if (list[5]==true){
      category.add("패스트푸드");
    }
    if (list[6]==true){
      category.add("주점");
    }
    if (list[7]==true){
      category.add("기타");
    }

    if (dis_value==true){
      emphasizedis=1.5;
    }
    if (rev_value==true){
      emphasizerev=1.5;
    }

    if (prices[0]==true){
      price[0]=true;
    }
    if (prices[1]==true){
      price[1]=true;
    }
    if (prices[2]==true){
      price[2]=true;
    }
    if (prices[3]==true){
      price[3]=true;
    }

  }
}




//가게에 대한 객체
class Shop
{
  String id="12345678";
  String name="김가네";
  String category="분식";
  String phonenum="정보 없음";
  String address="흑석동";
  String locX="1232.232";
  String locY="132.232";
  String placeUrl="https://images.unsplash.com/photo-1614548539644-ef528186523a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80";
  List<String> menulist=[];
  List<int> menuprices=[];
  int review_count=35;
  double rating=3.5;
  int distance=300;
  int price=0; //평균 메뉴값
  int max=0;
  String openhours="정보 없음";


  double priority=1; //가게 추천도


  Shop(List<String> list, List<String> menulistss, List<int> priceslist)
  {id=list[0];
   name=list[1];
   category=list[2];
   if(list[3]!="") {
     phonenum = list[3];
   }
   address=list[4];
   locX=list[5];
   locY=list[6];
   if(list[7][0]!='h'){
     list[7]="https:"+list[7];
   }
   if(list[7]!="https://media.istockphoto.com/id/1216251206/ko/%EB%B2%A1%ED%84%B0/%EC%82%AC%EC%9A%A9%ED%95%A0-%EC%88%98-%EC%9E%88%EB%8A%94-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%97%86%EC%9D%8C-%EC%95%84%EC%9D%B4%EC%BD%98.jpg?s=170667a&w=0&k=20&c=4oSjH5ISBPZbUQ0JFdkkag7FL4Hy60JnAxOugt5g29g=") {
     placeUrl = list[7];
   }
   review_count=int.parse(list[8]);
   rating=double.parse(list[9]);
   distance=int.parse(list[10]);
  if(menulistss!=Null) {
    menulist = menulistss;
  }
  if(priceslist!=Null) {
    menuprices = priceslist;
  }
   if(menulist.length>0) {
     for (int i = 0; i < menuprices.length; i++) {
       max += menuprices[i];
     }
   }
    if(menulist.length>0) {
    price = (max / menuprices.length).toInt();
   }
  }

  //가게 정보 리턴
  String GetShop()
  {
    return name+category+review_count.toString()+rating.toString()+distance.toString()+price.toString()+priority.toString();
  }
}

//추천도 계산기 보조 함수
double LevelCal(Shop shop, Filter filter){
  double reliability=0,distance=0,price,category=0;
  int bonus=0;
  if(shop.review_count<=10){
    reliability=0.3*shop.rating;
  }
  else if(shop.review_count<=50){
    reliability=0.6*shop.rating;
  }
  else if(shop.review_count<=100){
    reliability=0.6*shop.rating;
  }
  else reliability=shop.rating;

  if(shop.distance<=100){
    distance=4;
  }
  else if(shop.review_count<=300){
    distance=3;
  }
  else if(shop.review_count<=500){
    distance=2;
  }
  else distance=1;

  if(filter.category.contains(shop.category)){
    category=5;
  }

  if(shop.menuprices.length==0){
    bonus=4;
  }

  return reliability*filter.emphasizerev+distance*filter.emphasizedis+category; //추천도 반환
}


//유튜브 추천 알고리즘 할 때의 그 알고리즘 맞음.
List<Shop> Algorithm(List<Shop> shops,Filter filter)  //shops는 근처 가게 30개 정도 받아온, 가게들의 리스트
{
  List<Shop> choosed=[];
  for(int i=0; i<shops.length;i++)
  {
    if (shops[i].price==0) {
      shops[i].priority=LevelCal(shops[i],filter);
      choosed.add(shops[i]);
    }
    if(filter.price[0]==true) {
      if (shops[i].price > 0 && shops[i].price <= 10000) {
        shops[i].priority=LevelCal(shops[i],filter);
        choosed.add(shops[i]);
      }
    }
    if(filter.price[1]==true) {
      if (shops[i].price > 10000 && shops[i].price <= 20000) {
        shops[i].priority=LevelCal(shops[i],filter);
        choosed.add(shops[i]);
      }
    }
    if(filter.price[2]==true) {
      if (shops[i].price > 20000 && shops[i].price <= 30000) {
        shops[i].priority=LevelCal(shops[i],filter);
        choosed.add(shops[i]);
      }
    }
    if(filter.price[3]==true) {
      if (shops[i].price > 30000) {
        shops[i].priority=LevelCal(shops[i],filter);
        choosed.add(shops[i]);
      }
    }
  }
  choosed.sort((b,a) => a.priority.compareTo(b.priority));

  return choosed;
}

double cal_distance(double locx, double locy,String s_x, String s_y)
{
  String distance="";
  double dis=sqrt(pow((locx-double.parse(s_x)),2)+pow(locy-double.parse(s_y),2))*133.33*1000;


  return dis;
}

Future<List<Shop>> map_to_shop(List<Map> alg_data,Position position) async
{
  double locx=position.longitude;
  double locy=position.latitude;
  List<Shop> shoplist=[];
  //marker_id에 해당하는 객체 찾기
  List<String> list=[];
  List<String> menulistss=[];
  List<int> priceslist=[];
  for(int i=0;i<alg_data.length;i++){//alg_data.length
      //id
      list.insert(0,alg_data[i]['id'].toString());
      //name
      list.insert(1,alg_data[i]['name'].toString());
      //category
      if(alg_data[i]['category'][6]=='한'&&alg_data[i]['category'][7]=='식'){
        list.insert(2,"한식");
      }
      else if(alg_data[i]['category'][6]=='치'&&alg_data[i]['category'][7]=='킨'){
        list.insert(2,"패스트푸드");
      }
      else if(alg_data[i]['category'][6]=='일'&&alg_data[i]['category'][7]=='식'){
        list.insert(2,"일식");
      }
      else if(alg_data[i]['category'][6]=='중'&&alg_data[i]['category'][7]=='식'){
        list.insert(2,"중식");
      }
      else if(alg_data[i]['category'][6]=='양'&&alg_data[i]['category'][7]=='식'){
        list.insert(2,"양식");
      }
      else if(alg_data[i]['category'][6]=='간'&&alg_data[i]['category'][7]=='식'){
        list.insert(2,"디저트");
      }
      else if(alg_data[i]['category'][6]=='주'&&alg_data[i]['category'][7]=='점'){
        list.insert(2,"주점");
      }
      else{
        list.insert(2,"기타");
      }
      //phonenum
      list.insert(3,alg_data[i]['phonenum'].toString());
      //address
      list.insert(4,alg_data[i]['address'].toString());
      //locx
      list.insert(5,alg_data[i]['locX'].toString());
      //locy
      list.insert(6,alg_data[i]['locY'].toString());
      //placeUrl
      list.insert(7,alg_data[i]['placeUrl'].toString());
      //review_count
      list.insert(8,alg_data[i]['review_count']);

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
      shoplist.add(Shop(list, menulistss, priceslist));
      list=[];
      menulistss=[];
      priceslist=[];
  }
  for(int i=0;i<shoplist.length;i++){
      shoplist[i].distance=alg_data[i]['distance'];
      if(alg_data[i]['operation'].length!=0) {
        shoplist[i].openhours = alg_data[i]['operation'].toString();
        shoplist[i].openhours=shoplist[i].openhours.substring(1,shoplist[i].openhours.indexOf(']'));
      }
      shoplist[i].address=shoplist[i].address.substring(0,shoplist[i].address.indexOf('('));
  }
  //print(alg_data[0]['menulist'][0]);

  return shoplist;
}



