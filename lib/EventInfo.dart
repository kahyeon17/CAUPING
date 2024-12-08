import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventInfo {
  final String eventId;
  String name;
  String description;
  String host;
  String target;
  String dept;
  String category;
  DateRange date;
  TimeRange time;
  Location location;
  List<String> images; // 이미지 URL 리스트 추가
  final DateTime? timestamp;

  EventInfo(
    this.eventId,
    this.name,
    this.description,
    this.host,
    this.target,
    this.dept,
    this.category,
    this.date,
    this.time,
    this.location,
    this.images, // 이미지 리스트 초기화
    this.timestamp,
  );

  // Firestore 데이터를 EventInfo로 변환하는 메서드
  factory EventInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventInfo(
      doc.id,
      data['name'].toString() ?? '',
      data['description'].toString() ?? '',
      data['host'].toString() ?? '',
      data['target'].toString() ?? '',
      data['dept'].toString() ?? '',
      data['category'].toString() ?? '',
      DateRange.fromMap(data['date']),
      TimeRange.fromMap(data['time']),
      Location.fromMap(data['location']),
      List<String>.from(data['images'] ?? []), // 이미지 리스트 처리
      (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // 데이터를 Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'host': host,
      'target': target,
      'dept': dept,
      'category': category,
      'date': date.toMap(),
      'time': time.toMap(),
      'location': location.toMap(),
      'images': images, // 이미지 리스트 추가
    };
  }
}

class Location {
  String building;
  String detail;

  Location(this.building, this.detail);

  // Firestore 데이터를 Location 객체로 변환
  factory Location.fromMap(Map<String, dynamic>? map) {
    return Location(
      map?['building'].toString() ?? '', // 건물
      map?['detail'].toString() ?? '', // 상세 위치
    );
  }

  // 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'building': building,
      'detail': detail,
    };
  }
}

class DateRange {
  String startDate; // 시작 날짜
  String endDate; // 종료 날짜

  DateRange(this.startDate, this.endDate);

  // Firestore 데이터를 DateRange로 변환
  factory DateRange.fromMap(Map<String, dynamic> map) {
    return DateRange(
      map['startDate'].toString() ?? '',
      map['endDate'].toString() ?? '',
    );
  }

  // 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // String을 DateTime으로 변환 (사용자 정의 형식 지원)
  DateTime? getStartDateTime() {
    return _parseDate(startDate);
  }

  DateTime? getEndDateTime() {
    return _parseDate(endDate);
  }

  // 날짜 변환 로직 (맞춤 파싱)
  DateTime? _parseDate(String date) {
    try {
      // "yyyy/MM/dd" 형식으로 변환
      return DateFormat('yyyy/MM/dd').parse(date);
    } catch (e) {
      print('Invalid date format: $date');
      return null; // 잘못된 형식일 경우 null 반환
    }
  }

  // 진행 상태 확인 메서드
  bool isOngoing(DateTime now) {
    final start = getStartDateTime();
    final end = getEndDateTime();
    return start != null &&
        end != null &&
        start.isBefore(now) &&
        end.isAfter(now);
  }

  bool isUpcoming(DateTime now) {
    final start = getStartDateTime();
    return start != null && start.isAfter(now);
  }
}

class TimeRange {
  String start; // 시작 시간
  String end; // 종료 시간

  TimeRange(this.start, this.end);

  // Firestore 데이터를 TimeRange로 변환
  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      map['start'].toString() ?? '',
      map['end'].toString() ?? '',
    );
  }

  // 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
    };
  }
}

// Firebase에서 데이터를 가져오는 함수
Future<List<EventInfo>> fetchEvents() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return [];
  }

  final uid = user.uid;
  final snapshot = await FirebaseFirestore.instance
      .collection('events')
      .where('uid', isEqualTo: uid) // uid 필터링
      .orderBy('timestamp', descending: true) // 시간 순으로 정렬
      .get();

  return snapshot.docs.map((doc) => EventInfo.fromFirestore(doc)).toList();
}
