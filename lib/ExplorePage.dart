import 'package:cauping/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EventInfo.dart';
import 'BuildingInfo.dart';
import 'EventCard.dart';

Map<String, EventInfo> bookmarkedEvents = {}; // 이벤트 ID별 북마크 상태를 저장하는 Map

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool isNaverMapInitialized = false;
  String? errorMessage; // 오류 메시지
  //late NaverMapController _mapController;
  String? selectedLocation; // 선택된 마커의 위치
  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();
  late Future<List<EventInfo>> _eventsList = fetchEvents();
  String _selectedStatus = '진행 중';
  String _selectedCollege = '소속 대학';
  String _selectedEventType = '행사 유형';
  EventInfo? selectedEvent; // 선택된 행사를 관리

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
  }

  Future<void> _initializeNaverMap() async {
    try {
      await NaverMapSdk.instance.initialize(
        clientId: '4jfm9e2by4',
        onAuthFailed: (error) {
          setState(() {
            errorMessage = "네이버맵 인증 오류: ${error.message}";
          });
        },
      );
      setState(() {
        isNaverMapInitialized = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = "네이버 지도 초기화 실패: $e";
      });
    }
  }

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
      QuerySnapshot snapshot = await firestore
          .collection('events')
          .orderBy('date.startDate', descending: false)
          .get();
      List<EventInfo> allEvents =
          snapshot.docs.map((doc) => EventInfo.fromFirestore(doc)).toList();

      // 현재 날짜 가져오기
      DateTime now = DateTime.now();

      // 필터링 조건에 따라 이벤트 필터링
      List<EventInfo> filteredEvents = allEvents.where((event) {
        // 마커 클릭 시 선택된 위치와 일치하는 건물의 이벤트만 표시
        bool matchesLocation = selectedLocation == null ||
            event.location.building == selectedLocation;

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
        return matchesLocation &&
            matchesStatus &&
            matchesCollege &&
            matchesEventType;
      }).toList();

      return filteredEvents; // 필터링된 이벤트 반환
    } catch (e) {
      print('파이어스토어 데이터를 가져오는 중 오류 발생: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isNaverMapInitialized) {
      return const Scaffold(
        body: Center(
          child: Text(
            '네이버 지도 SDK가 초기화되지 않았습니다.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      // 초기화 실패 시 에러 메시지 표시
      return Scaffold(
        body: Center(
          child: Text(errorMessage!),
        ),
      );
    }

    if (!isNaverMapInitialized) {
      // 초기화 중 로딩 표시
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 지도 영역
          NaverMap(
            onMapTapped: (point, latLng) {
              setState(() {
                selectedLocation = null; // 선택된 위치 초기화
                _eventsList = fetchEvents(); // 필터링을 다시 적용
              });
            },
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
              //_mapController = controller;
              // 모든 건물 데이터에 대해 마커와 다각형 오버레이 생성
              for (final building in buildings) {
                // 마커 생성
                final marker = NMarker(
                  id: building.id,
                  size: const Size(30.0, 40.0),
                  position: building.markerPosition,
                  caption: NOverlayCaption(
                    text: building.name, // 캡션 텍스트
                    textSize: 14, // 텍스트 크기
                    color: Colors.black, // 텍스트 색상
                  ),
                );

                marker.setOnTapListener((clickedMarker) {
                  setState(() {
                    selectedLocation = building.location; // 상태 업데이트
                    _eventsList = fetchEvents(); // 데이터 갱신
                  });
                  return true; // 이벤트 소비
                });

                // 테두리(다각형) 생성
                final polygon = NPolygonOverlay(
                  id: "${building.id}_polygon",
                  coords: building.polygonCoords,
                  color: Colors.blue.withOpacity(0), // 테두리 내부 투명
                  outlineColor: PrimaryColor, // 테두리 색상
                  outlineWidth: 1.8, // 테두리 두께
                );

                // 지도에 마커와 다각형 추가
                controller.addOverlay(marker);
                controller.addOverlay(polygon);
              }
            },
          ),
          // 행사 정보 목록 영역
          DraggableScrollableSheet(
            controller: _scrollableController, // Controller 추가
            initialChildSize: 0.35, // 초기 높이 (화면의 30%)
            minChildSize: 0.35, // 최소 높이 (화면의 30%)
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
                  mainAxisSize: MainAxisSize.min,
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
                    ...(selectedEvent == null
                        ? [
                            // 필터링 영역
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 60, top: 10, bottom: 10),
                              //width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              child: IntrinsicWidth(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // 진행 상태 필터
                                    Flexible(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedStatus, // 선택된 값
                                        decoration: InputDecoration(
                                          filled: true, // 배경색 활성화
                                          fillColor: const Color.fromARGB(
                                              255, 236, 242, 253),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // 테두리 둥글게
                                            borderSide: const BorderSide(
                                                color: CaupingLightGray),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: PrimaryColor),
                                          ),
                                        ),

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
                                          if (value != null) {
                                            setState(() {
                                              _selectedStatus =
                                                  value; // 선택된 상태 업데이트
                                              _eventsList =
                                                  fetchEvents(); // 이벤트 목록 업데이트
                                            });
                                          }
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 2),
                                    const VerticalDivider(
                                      color: CaupingLightGray, // 선 색상
                                      thickness: 2, // 선 두께
                                    ),
                                    const SizedBox(width: 2),

                                    // 소속 대학 필터
                                    Flexible(
                                      flex: 4,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCollege == '소속 대학'
                                            ? null
                                            : _selectedCollege,
                                        isExpanded: false,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // 테두리 둥글게
                                            borderSide: const BorderSide(
                                                color: CaupingLightGray),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: PrimaryColor),
                                          ),
                                        ),
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
                                    ),

                                    const SizedBox(width: 7),
                                    // 행사 유형 필터
                                    Flexible(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedEventType == '행사 유형'
                                            ? null
                                            : _selectedEventType,
                                        decoration: InputDecoration(
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 3),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                8), // 테두리 둥글게
                                            borderSide: const BorderSide(
                                                color: CaupingLightGray),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: PrimaryColor),
                                          ),
                                        ),
                                        hint: const Text(
                                          '행사 유형', // 초기 힌트 텍스트
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        items: _optList
                                            .map(
                                                (eventType) => DropdownMenuItem(
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FutureBuilder<List<EventInfo>>(
                                future: _eventsList,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    print('${snapshot.error}');
                                    return const Center(
                                        child: Text('오류가 발생했습니다.'));
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('등록된 행사가 없습니다.'));
                                  } else {
                                    final events = snapshot.data!;
                                    return ListView.builder(
                                      padding: const EdgeInsets.only(
                                          left: 3.0, right: 3.0),
                                      shrinkWrap: true, // 리스트 높이를 컨텐츠 크기로 설정
                                      physics:
                                          const ClampingScrollPhysics(), // 리스트 스크롤 제어
                                      controller: scrollController,
                                      itemCount: events.length,
                                      itemBuilder: (context, index) {
                                        final event = events[index];
                                        // 북마크 상태 가져오기 (초기값 false)
                                        bool isBookmarked = bookmarkedEvents
                                            .containsKey(event.eventId);
                                        return Stack(
                                          children: [
                                            EventCard(
                                              event: event,
                                              onTap: () {
                                                // 조건문을 사용하여 animateTo 숫자를 다르게 설정
                                                final targetHeight =
                                                    event.images.isNotEmpty
                                                        ? 0.65
                                                        : 0.4;
                                                _scrollableController
                                                    .animateTo(
                                                  targetHeight, // 상세 페이지를 표시할 때 최대 높이로 확장
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                )
                                                    .then((_) {
                                                  setState(() {
                                                    selectedEvent = event;
                                                  });
                                                });
                                              },
                                            ),
                                            Positioned(
                                              top: 2, // 상단으로부터의 거리
                                              right: 5, // 우측으로부터의 거리
                                              child: IconButton(
                                                icon: Icon(
                                                  isBookmarked
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                ),
                                                onPressed: () {
                                                  // 북마크 추가/제거
                                                  toggleBookmark(event);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ]
                        : [
                            // 이벤트 상세 페이지
                            Stack(
                              children: [
                                EventDetailsCard(event: selectedEvent!),
                                Positioned(
                                  right: 40,
                                  child: IconButton(
                                    icon: Icon(
                                      bookmarkedEvents.containsKey(
                                              selectedEvent!.eventId)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                    ),
                                    onPressed: () {
                                      // 북마크 추가/제거
                                      toggleBookmark(selectedEvent!);
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  child: // X 버튼
                                      IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        selectedEvent = null; // 선택된 이벤트 해제
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void toggleBookmark(EventInfo event) {
    setState(() {
      if (bookmarkedEvents.containsKey(event.eventId)) {
        bookmarkedEvents.remove(event.eventId);
      } else {
        bookmarkedEvents[event.eventId] = event;
      }
    });
  }
}
