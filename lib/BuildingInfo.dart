import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EventInfo.dart';

final List<String> _locList = [
  '101관(영신관)',
  '102관(약학대학 및 R&D센터)',
  '103관(파이퍼홀)',
  '104관(수림과학관)',
  '105관(제1의학관)',
  '106관(제2의학관)',
  '107관(학생회관)',
  '108관',
  '201관(본관)',
  '202관(전산정보관)',
  '203관(서라벌홀)',
  '204관(중앙도서관)',
  '207관(봅스트홀)',
  '208관(제2공학관)',
  '209관(창업보육관)',
  '301관(중앙문화예술관)',
  '302관(대학원)',
  '303관(법학관)',
  '304관(미디어공영영상관)',
  '305관(교수연구동 및 체육관)',
  '307관(글로벌 하우스)',
  '308관(블루미르홀308관)',
  '309관(블루미르홀309관)',
  '310관(100주년기념관)',
  '청룡연못',
  '자이언트구장',
  '중앙마루(빼빼로광장)',
  '중앙광장',
  '의혈탑',
];

// 건물 정보를 나타내는 클래스
class BuildingInfo {
  final String id;
  final String name;
  final String location;
  final NLatLng markerPosition; // 마커 중심 좌표
  final List<NLatLng> polygonCoords; // 테두리 좌표

  BuildingInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.markerPosition,
    required this.polygonCoords,
  });
}

// 건물 데이터 목록
final List<BuildingInfo> buildings = [
  BuildingInfo(
    id: "central_library",
    name: "204관(중앙도서관)",
    location: "중앙도서관",
    markerPosition: const NLatLng(37.504681, 126.957884),
    polygonCoords: [
      const NLatLng(37.505069, 126.957735), // 좌측 상단
      const NLatLng(37.504816, 126.958372), // 우측 상단
      const NLatLng(37.504408, 126.958134), // 우측 하단
      const NLatLng(37.504663, 126.957479), // 좌측 하단
      const NLatLng(37.505069, 126.957735), // 시작점과 동일
    ],
  ),
  BuildingInfo(
    id: "memorial_hall",
    name: "310관(100주년기념관)",
    location: "100주년 기념관 (310관)",
    markerPosition: const NLatLng(37.503595, 126.955997),
    polygonCoords: [
      const NLatLng(37.504255, 126.955707),
      const NLatLng(37.503917, 126.956300),
      const NLatLng(37.503007, 126.956314),
      const NLatLng(37.503306, 126.955715),
      const NLatLng(37.504255, 126.955707),
    ],
  ),
  BuildingInfo(
    id: "bldg",
    name: "제2공학관 (208관)",
    location: "제2공학관 (208관)",
    markerPosition: const NLatLng(37.503629, 126.957062),
    polygonCoords: [
      const NLatLng(37.503950, 126.956942),
      const NLatLng(37.503950, 126.957136),
      const NLatLng(37.503208, 126.957149),
      const NLatLng(37.503209, 126.956960),
      const NLatLng(37.503950, 126.956942),
    ],
  ),
  BuildingInfo(
    id: "basketball",
    name: "농구장",
    location: "농구장",
    markerPosition: const NLatLng(37.504202, 126.957385),
    polygonCoords: [
      const NLatLng(37.504338, 126.957191),
      const NLatLng(37.504337, 126.957537),
      const NLatLng(37.504096, 126.957530),
      const NLatLng(37.504099, 126.957184),
      const NLatLng(37.504338, 126.957191),
    ],
  ),
];

Future<List<EventInfo>> fetchMatchingBuildings() async {
  try {
    // Firestore 인스턴스 가져오기
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 결과를 저장할 리스트
    List<EventInfo> eventsAtBuildings = [];

    // Firestore에서 모든 EventInfo 가져오기
    QuerySnapshot snapshot = await firestore.collection('events').get();
    List<EventInfo> allEvents =
        snapshot.docs.map((doc) => EventInfo.fromFirestore(doc)).toList();

    // 모든 EventInfo 객체를 순회하며 BuildingInfo의 name과 일치하는 데이터를 필터링
    // for (EventInfo event in allEvents) {
    //   for (BuildingInfo building in buildings) {
    //     if (event.location.building == building.name) {
    //       eventsAtBuildings.add(event);
    //       break; // 일치하는 건물 발견 시 더 이상 반복 필요 없음
    //     }
    //   }
    // }

    //return eventsAtBuildings; // 결과 반환
    return allEvents;
  } catch (e) {
    print('파이어스토어 데이터를 가져오는 중 오류 발생: $e');
    return [];
  }
}
