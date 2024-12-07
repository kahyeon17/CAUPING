import 'package:flutter/material.dart';
import 'Colors.dart';
import 'ExplorePage.dart';
import 'EventInfo.dart';
import 'EventCard.dart';
import 'EventDetailsPage.dart';

class SavedEvents extends StatefulWidget {
  //final Map<String, EventInfo> bookmarkedEvents;
  const SavedEvents({super.key});

  @override
  State<SavedEvents> createState() => _SavedEventsState();
}

class _SavedEventsState extends State<SavedEvents> {
  @override
  Widget build(BuildContext context) {
    // 북마크된 이벤트 필터링
    List<EventInfo> savedEvents = bookmarkedEvents.values.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '행사 저장 목록',
          style: TextStyle(
              color: CaupingBlack,
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: savedEvents.isEmpty
          ? const Center(
              child: Text(
                '북마크된 이벤트가 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: savedEvents.length,
              itemBuilder: (context, index) {
                EventInfo event = savedEvents[index];
                return Stack(
                  children: [
                    EventCard(
                      event: event,
                      onTap: () {
                        // Navigator를 사용하여 상세 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsPage(event: event),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 5, // 상단으로부터의 거리
                      right: 5, // 우측으로부터의 거리
                      child: IconButton(
                        icon: Icon(
                          bookmarkedEvents.containsKey(event.eventId)
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
