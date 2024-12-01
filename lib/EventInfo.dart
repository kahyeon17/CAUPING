class EventInfo {
  String name;
  String discription;
  String host;
  String target;
  String dept;
  String category;
  DateRange date;
  TimeRange time;
  String location;
  String image;

  EventInfo(
    this.name,
    this.discription,
    this.host,
    this.target,
    this.dept,
    this.category,
    this.date,
    this.time,
    this.location,
    this.image,
  );

  // 데이터를 Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': discription,
      'host': host,
      'target': target,
      'dept': dept,
      'category': category,
      'date': date.toMap(),
      'time': time.toMap(),
      'location': location,
      'image': image,
    };
  }
}

class DateRange {
  String startDate; // 시작 날짜
  String endDate; // 종료 날짜

  DateRange(this.startDate, this.endDate);

  // 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class TimeRange {
  String start; // 시작 시간
  String end; // 종료 시간

  TimeRange(this.start, this.end);

  // 데이터를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
    };
  }
}
