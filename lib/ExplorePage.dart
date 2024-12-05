import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class ExploreScreen extends StatelessWidget {
  final bool isNaverMapInitialized; // 초기화 상태를 받는 변수

  const ExploreScreen({super.key, required this.isNaverMapInitialized});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색'),
      ),
      body: NaverMap(
        options: const NaverMapViewOptions(
          indoorEnable: true,             // 실내 맵 활성화
          locationButtonEnable: true,     // 현재 위치 버튼 활성화
          consumeSymbolTapEvents: false,  // 심볼 탭 이벤트 비활성화
        ),
        onMapReady: (controller) {
          debugPrint('Naver Map is ready');
        },
      ),
    );
  }
}
