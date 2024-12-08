import 'package:cauping/EventRegisterPage.dart';
import 'package:flutter/material.dart';
import 'Colors.dart';
import 'EventInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EventCard.dart';

class UpdatedEvents extends StatefulWidget {
  const UpdatedEvents({super.key});

  @override
  State<UpdatedEvents> createState() => _UpdatedEventsState();
}

class _UpdatedEventsState extends State<UpdatedEvents> {
  late Future<List<EventInfo>> _events;

  @override
  void initState() {
    super.initState();
    _events = fetchEvents(); // Firebase 데이터 가져오기
  }

  Future<void> deleteEvent(String eventId, String eventName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SecondaryColor,
          titlePadding: const EdgeInsets.only(top: 20.0), // 제목 패딩 조정
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0), // 내용 패딩 조정
          actionsPadding: const EdgeInsets.only(bottom: 20.0),
          title: const Text(
            '행사 삭제',
            textAlign: TextAlign.center, // 제목을 가운데 정렬
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          content: Text(
            '$eventName 행사를\n삭제하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimaryColor,
                  ),
                  child: const Text(
                    '삭제',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .delete();
        setState(() {
          _events = fetchEvents(); // 삭제 후 목록 갱신
        });
        // 행사삭제 성공 메시지 다이얼로그 호출
        await _showSuccessDialog(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 배경 클릭으로 닫지 못하도록 설정
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: SecondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // 다이얼로그의 모서리를 둥글게
          ),
          child: const Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '행사 삭제 완료',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '행사가 성공적으로 삭제되었습니다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    // 다이얼로그가 2초 후 자동으로 닫히도록 설정
    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop(); // 다이얼로그 닫기
  }

  void _editEvent(EventInfo currentEvent, String eventId) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          title: '행사 수정',
          initialEventInfo: currentEvent,
          showCancelButton: false,
          isEditing: true, // 수정 여부
          docId: eventId, // 수정할 문서 ID
        ),
      ),
    );
    if (updatedEvent == true) {
      // Firestore에서 최신 데이터를 다시 가져옴
      setState(() {
        _events = fetchEvents(); // fetchEvents는 Firestore에서 데이터를 가져오는 함수
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '행사 등록 목록',
          style: TextStyle(
              color: CaupingBlack,
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<EventInfo>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('${snapshot.error}');
            return const Center(child: Text('오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 행사가 없습니다.'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Stack(
                  children: [
                    EventCard(event: event, onTap: () {}),
                    Positioned(
                      top: 5, // 상단으로부터의 거리
                      right: 5, // 우측으로부터의 거리
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              // 수정 페이지로 이동
                              _editEvent(event, event.eventId);
                              break;
                            case 'delete':
                              // 삭제 동작
                              deleteEvent(event.eventId, event.name);
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('수정'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          ];
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
    );
  }
}
