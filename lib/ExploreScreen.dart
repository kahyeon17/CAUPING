import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'building.dart';

class ExploreScreen extends StatefulWidget {
  final bool isNaverMapInitialized;

  const ExploreScreen({super.key, required this.isNaverMapInitialized});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late NaverMapController _mapController;
  String? selectedLocation; // 선택된 마커의 위치

  @override
  Widget build(BuildContext context) {
    if (!widget.isNaverMapInitialized) {
      return const Scaffold(
        body: Center(
          child: Text(
            '네이버 지도 SDK가 초기화되지 않았습니다.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // 지도 영역
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5, // 상단 지도 높이
            child: NaverMap(
              options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(37.50413407, 126.95634038), // 첫 번째 건물 중심 좌표
                  zoom: 17, // 줌 레벨
                  bearing: 0, // 방향
                  tilt: 0, // 기울기
                ),
                indoorEnable: true, // 실내 맵 활성화
                locationButtonEnable: true, // 현재 위치 버튼 활성화
                consumeSymbolTapEvents: false, // 심볼 탭 이벤트 비활성화
              ),
              onMapReady: (controller) {
                _mapController = controller;

                // 모든 건물 데이터에 대해 마커와 다각형 오버레이 생성
                for (final building in buildings) {
                  // 마커 생성
                  final marker = NMarker(
                    id: building.id,
                    position: building.markerPosition,
                    caption: NOverlayCaption(
                      text: building.name, // 캡션 텍스트
                      textSize: 14, // 텍스트 크기
                      color: Colors.black, // 텍스트 색상
                    ),
                  );

                  // 마커 클릭 시 위치 선택 처리
                  marker.setOnMarkerClickListener((overlay, iconTapped) {
                    setState(() {
                      selectedLocation = building.location; // 해당 건물의 위치 설정
                    });
                    return true;
                  });

                  // 테두리(다각형) 생성
                  final polygon = NPolygonOverlay(
                    id: "${building.id}_polygon",
                    coords: building.polygonCoords,
                    color: Colors.blue.withOpacity(0), // 테두리 내부 투명
                    outlineColor: Colors.blue, // 테두리 색상
                    outlineWidth: 6, // 테두리 두께
                  );

                  // 지도에 마커와 다각형 추가
                  controller.addOverlay(marker);
                  controller.addOverlay(polygon);
                }
              },
            ),
          ),
          // 행사 정보 목록 영역
          Expanded(
            child: selectedLocation == null
                ? const Center(
              child: Text(
                '마커를 클릭해 위치를 선택하세요.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: buildings.length,
              itemBuilder: (context, index) {
                final building = buildings[index];
                // 선택된 위치와 일치하는 건물만 표시
                if (building.location == selectedLocation) {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // 선 색상
                            width: 1.0, // 선 두께
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              building.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              building.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink(); // 조건에 맞지 않는 항목 숨김
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on NMarker {
  void setOnMarkerClickListener(bool Function(dynamic overlay, dynamic iconTapped) param0) {}
}
