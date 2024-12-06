import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EventInfo.dart';
import 'BuildingInfo.dart';

class ExploreScreen extends StatefulWidget {
  final bool isNaverMapInitialized;

  const ExploreScreen({super.key, required this.isNaverMapInitialized});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late NaverMapController _mapController;
  String? selectedLocation; // 선택된 마커의 위치
  late Future<List<EventInfo>> _eventsByBuilding = fetchMatchingBuildings();
  late Future<List<EventInfo>> _eventsList = fetchEvents();
  String _selectedStatus = '진행 중';
  String _selectedCollege = '소속 대학';
  String _selectedEventType = '행사 유형';

  final List<String> _statusList = [
    '진행 중',
    '진행 예정',
    '전체',
  ];

  final List<String> _deptList = [
    '인문대학',
    '사회과학대학',
    '사범대학',
    '자연과학대학',
    '생명공학대학',
    '공과대학',
    '창의ICT공과대학',
    '소프트웨어대학',
    '경영경제대학',
    '의과대학',
    '약학대학',
    '적십자간호대학',
    '예술대학',
    '예술공학대학',
    '체육대학',
    '전체'
  ];

  final List<String> _optList = [
    '간식 행사',
    '강연',
    '공연',
    '취업',
    '전시',
    '학술제',
    '부스',
    '기타',
    '전체',
  ];

  Future<List<EventInfo>> fetchEvents() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Firestore에서 모든 EventInfo 가져오기
      QuerySnapshot snapshot = await firestore.collection('events').get();
      List<EventInfo> allEvents =
          snapshot.docs.map((doc) => EventInfo.fromFirestore(doc)).toList();

      // 현재 날짜 가져오기
      DateTime now = DateTime.now();

      // 필터링 조건에 따라 이벤트 필터링
      List<EventInfo> filteredEvents = allEvents.where((event) {
        // 진행 상태 필터
        bool matchesStatus = true; // 기본값
        if (_selectedStatus == '전체') {
          matchesStatus = true; // '전체'를 선택하면 모든 조건을 허용
        } else if (_selectedStatus == '진행 중') {
          matchesStatus = event.date.isOngoing(now);
        } else if (_selectedStatus == '진행 예정') {
          matchesStatus = event.date.isUpcoming(now);
        }

        // "전체"를 선택하면 해당 필터를 무시
        bool matchesCollege = _selectedCollege == '소속 대학' ||
            _selectedCollege == '전체' ||
            event.dept == _selectedCollege;
        bool matchesEventType = _selectedEventType == '행사 유형' ||
            _selectedEventType == '전체' ||
            event.category == _selectedEventType;

        // 모든 조건이 만족하는 경우 true 반환
        return matchesStatus && matchesCollege && matchesEventType;
      }).toList();

      return filteredEvents; // 필터링된 이벤트 반환
    } catch (e) {
      print('파이어스토어 데이터를 가져오는 중 오류 발생: $e');
      return [];
    }
  }

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
      body: Stack(
        children: [
          // 지도 영역
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.504872, 126.958013), // 첫 번째 건물 중심 좌표
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
          // 행사 정보 목록 영역
          DraggableScrollableSheet(
            initialChildSize: 0.3, // 초기 높이 (화면의 30%)
            minChildSize: 0.3, // 최소 높이 (화면의 30%)
            maxChildSize: 0.8, // 최대 높이 (화면의 80%)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 슬라이드 핸들
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    // 필터링 영역
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 진행 상태 필터
                          DropdownButton<String>(
                            value: _selectedStatus,
                            items: _statusList
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                                _eventsList = fetchEvents();
                              });
                            },
                          ),
                          const SizedBox(width: 5),
                          // 소속 대학 필터
                          DropdownButton<String>(
                            value: _selectedCollege == '소속 대학'
                                ? null
                                : _selectedCollege, // 선택되지 않았을 때 null로 설정
                            hint: const Text(
                              '소속 대학', // 초기 힌트 텍스트
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            items: _deptList
                                .map((college) => DropdownMenuItem(
                                      value: college,
                                      child: Text(
                                        college,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCollege = value;
                                  _eventsList = fetchEvents();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 5),
                          // 행사 유형 필터
                          DropdownButton<String>(
                            value: _selectedEventType == '행사 유형'
                                ? null
                                : _selectedEventType,
                            hint: const Text(
                              '행사 유형', // 초기 힌트 텍스트
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            items: _optList
                                .map((eventType) => DropdownMenuItem(
                                      value: eventType,
                                      child: Text(
                                        eventType,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEventType = value!;
                                _eventsList = fetchEvents();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: FutureBuilder<List<EventInfo>>(
                        future: _eventsList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print('${snapshot.error}');
                            return const Center(child: Text('오류가 발생했습니다.'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('등록된 행사가 없습니다.'));
                          } else {
                            final events = snapshot.data!;
                            return ListView.builder(
                              padding: EdgeInsets.zero, // 리스트 패딩 제거
                              shrinkWrap: true, // 리스트 높이를 컨텐츠 크기로 설정
                              physics:
                                  const ClampingScrollPhysics(), // 리스트 스크롤 제어
                              controller: scrollController,
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey, // 선 색상
                                          width: 0.5, // 선 두께
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${event.location.building} ${event.location.detail}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        '${event.time.start} ~ ${event.time.end}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            event.description,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          const SizedBox(height: 10),
                                          //사진 불러올 자리
                                          if (event.images.isNotEmpty)
                                            GridView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap:
                                                  true, // 부모 스크롤 안에서 동작하도록 설정
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    3, // 한 줄에 3개의 이미지
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 4,
                                              ),
                                              itemCount: event.images.length,
                                              itemBuilder: (context, index) {
                                                return Image.network(
                                                  event.images[
                                                      index], // Firestore에서 가져온 이미지 URL
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

extension on NMarker {
  void setOnMarkerClickListener(
      bool Function(dynamic overlay, dynamic iconTapped) param0) {}
}
