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
    name: "중앙도서관",
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
    name: "100주년 기념관",
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