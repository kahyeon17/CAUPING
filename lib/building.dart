import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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
    location: "204관(중앙도서관)",
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
    location: "310관(100주년기념관)",
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
    name: "208관(제2공학관)",
    location: "208관(제2공학관)",
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
    name: "자이언트구장",
    location: "자이언트구장",
    markerPosition: const NLatLng(37.504202, 126.957385),
    polygonCoords: [
      const NLatLng(37.504338, 126.957191),
      const NLatLng(37.504337, 126.957537),
      const NLatLng(37.504096, 126.957530),
      const NLatLng(37.504099, 126.957184),
      const NLatLng(37.504338, 126.957191),
    ],
  ),
  BuildingInfo(
    id: "blueDragonPond",
    name: "청룡연못",
    location: "청룡연못",
    markerPosition: const NLatLng(37.505636, 126.957298),
    polygonCoords: [
      const NLatLng(37.505804, 126.957239),
      const NLatLng(37.505674, 126.957518),
      const NLatLng(37.505474, 126.957365),
      const NLatLng(37.505604, 126.957081),
      const NLatLng(37.505804, 126.957239),
    ],
  ),
  BuildingInfo(
    id: "mainBuilding",
    name: "201관(본관)",
    location: "201관(본관)",
    markerPosition: const NLatLng(37.505183, 126.956958),
    polygonCoords: [
      const NLatLng(37.505405, 126.956843),
      const NLatLng(37.505181, 126.957274),
      const NLatLng(37.504974, 126.957106),
      const NLatLng(37.505202, 126.956669),
      const NLatLng(37.505405, 126.956843),
    ],
  ),
  BuildingInfo(
    id: "graduateSchool",
    name: "302관(대학원)",
    location: "302관(대학원)",
    markerPosition: const NLatLng(37.504887, 126.955026),
    polygonCoords: [
      const NLatLng(37.505097, 126.954871),
      const NLatLng(37.504887, 126.955349),
      const NLatLng(37.504740, 126.955261),
      const NLatLng(37.504956, 126.954767),
      const NLatLng(37.505097, 126.954871),
    ],
  ),
  BuildingInfo(
    id: "yeongsinBldg",
    name: "101관(영신관)",
    location: "101관(영신관)",
    markerPosition: const NLatLng(37.505957, 126.957997),
    polygonCoords: [
      const NLatLng(37.506069, 126.957746),
      const NLatLng(37.506059, 126.958283),
      const NLatLng(37.505870, 126.958283),
      const NLatLng(37.505877, 126.957737),
      const NLatLng(37.506069, 126.957746),
    ],
  ),
  BuildingInfo(
    id: "NaturalSciencesBldg",
    name: "104관(수림과학관)",
    location: "104관(수림과학관)",
    markerPosition: const NLatLng(37.505700, 126.958050),
    polygonCoords: [
      const NLatLng(37.505852, 126.957740),
      const NLatLng(37.505841, 126.958349),
      const NLatLng(37.505532, 126.958335),
      const NLatLng(37.505701, 126.957732),
      const NLatLng(37.505852, 126.957740),
    ],
  ),
  BuildingInfo(
    id: "StudentUnionBldg",
    name: "107관(학생회관)",
    location: "107관(학생회관)",
    markerPosition: const NLatLng(37.506317, 126.957453),
    polygonCoords: [
      const NLatLng(37.506569, 126.957627),
      const NLatLng(37.506497, 126.957749),
      const NLatLng(37.506040, 126.957280),
      const NLatLng(37.506124, 126.957164),
      const NLatLng(37.506569, 126.957627),
    ],
  ),
  BuildingInfo(
    id: "centralSquare",
    name: "중앙광장",
    location: "중앙광장",
    markerPosition: const NLatLng(37.506401, 126.958015),
    polygonCoords: [
      const NLatLng(37.506697, 126.957889),
      const NLatLng(37.506710, 126.958296),
      const NLatLng(37.506192, 126.958288),
      const NLatLng(37.506198, 126.957716),
      const NLatLng(37.506697, 126.957889),
    ],
  ),
  BuildingInfo(
    id: "peperoSquare",
    name: "중앙마루(빼빼로광장)",
    location: "중앙마루(빼빼로광장)",
    markerPosition: const NLatLng(37.505974, 126.957545),
    polygonCoords: [
      const NLatLng(37.5060744, 126.95765438), // 꼭지점 1
      const NLatLng(37.5058192, 126.95765183), // 꼭지점 2
      const NLatLng(37.50591886, 126.95744287), // 꼭지점 3
      const NLatLng(37.5060744, 126.95765438), // 닫힘
    ],
  ),
  BuildingInfo(
    id: "seorabeolHall",
    name: "203관(서라벌홀)",
    location: "203관(서라벌홀)",
    markerPosition: const NLatLng(37.504716, 126.956597),
    polygonCoords: [
      const NLatLng(37.505068, 126.956188), // 꼭지점 1
      const NLatLng(37.504803, 126.956689), // 꼭지점 2
      const NLatLng(37.504652, 126.957271), // 꼭지점 3
      const NLatLng(37.504525, 126.957229), // 꼭지점 4
      const NLatLng(37.504606, 126.956632), // 꼭지점 5
      const NLatLng(37.504920, 126.956055), // 꼭지점 6
      const NLatLng(37.505068, 126.956188), // 닫힘
    ],
  ),
  BuildingInfo(
    id: "blueMireholDomitory308",
    name: "308관(블루미르홀308관)",
    location: "308관(블루미르홀308관)",
    markerPosition: const NLatLng(37.502651, 126.957095),
    polygonCoords: [
      const NLatLng(37.502898, 126.956944), // 꼭지점 1
      const NLatLng(37.502700, 126.956953), // 꼭지점 2
      const NLatLng(37.502469, 126.956785), // 꼭지점 3
      const NLatLng(37.502373, 126.957002), // 꼭지점 4
      const NLatLng(37.502892, 126.957432), // 꼭지점 5
      const NLatLng(37.502898, 126.956944), // 닫힘
    ],
  ),
  BuildingInfo(
    id: "blueMireholDomitory309",
    name: "309관(블루미르홀309관)",
    location: "309관(블루미르홀309관)",
    markerPosition: const NLatLng(37.50254452, 126.95629744),
    polygonCoords: [
      const NLatLng(37.5026408, 126.95625652), // 꼭지점 1
      const NLatLng(37.50228438, 126.95595546), // 꼭지점 2
      const NLatLng(37.50222107, 126.95608922), // 꼭지점 3
      const NLatLng(37.50248452, 126.95630924), // 꼭지점 4
      const NLatLng(37.50230726, 126.95667456), // 꼭지점 5
      const NLatLng(37.50241166, 126.95674886), // 꼭지점 6
      const NLatLng(37.5026408, 126.95625652), // 닫힘
    ],
  ),
  BuildingInfo(
    id: "pharmaceutical",
    name: "102관(약학대학 및 R&D센터)",
    location: "102관(약학대학 및 R&D센터)",
    markerPosition: const NLatLng(37.50656436, 126.95900371),
    polygonCoords: [
      const NLatLng(37.50680734, 126.9587483), // 꼭지점 1
      const NLatLng(37.50641246, 126.9587478), // 꼭지점 2
      const NLatLng(37.50640769, 126.95885505), // 꼭지점 3
      const NLatLng(37.50633195, 126.95885898), // 꼭지점 4
      const NLatLng(37.50633195, 126.95859856), // 꼭지점 5
      const NLatLng(37.50609561, 126.9585907), // 꼭지점 6
      const NLatLng(37.50608314, 126.95885627), // 꼭지점 7
      const NLatLng(37.50617446, 126.95885119), // 꼭지점 8
      const NLatLng(37.5061754, 126.95907863), // 꼭지점 9
      const NLatLng(37.50632113, 126.95908215), // 꼭지점 10
      const NLatLng(37.50633048, 126.95921418), // 꼭지점 11
      const NLatLng(37.50696893, 126.95922687), // 꼭지점 12
      const NLatLng(37.50696893, 126.95900179), // 꼭지점 13
      const NLatLng(37.50686804, 126.95899424), // 꼭지점 14
      const NLatLng(37.50685869, 126.95887128), // 꼭지점 15
      const NLatLng(37.50681411, 126.95887128), // 꼭지점 16
      const NLatLng(37.50680734, 126.9587483), // 닫힘
    ],
  ),
  BuildingInfo(
    id: "lawBldg",
    name: "303관(법학관)",
    location: "303관(법학관)",
    markerPosition: const NLatLng(37.50470085, 126.95591959),
    polygonCoords: [
      const NLatLng(37.50508231, 126.95536485), // 꼭지점 1
      const NLatLng(37.50500857, 126.95531254), // 꼭지점 2
      const NLatLng(37.50492159, 126.95548844), // 꼭지점 3
      const NLatLng(37.50471557, 126.95537991), // 꼭지점 4
      const NLatLng(37.50440243, 126.95610476), // 꼭지점 5
      const NLatLng(37.50466353, 126.95626059), // 꼭지점 6
      const NLatLng(37.50508231, 126.95536485), // 닫힘
    ],
  ),
];
