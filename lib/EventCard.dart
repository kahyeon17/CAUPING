import 'package:flutter/material.dart';
import 'EventInfo.dart';
import 'Colors.dart';

class EventCard extends StatelessWidget {
  final EventInfo event;
  final VoidCallback onTap; // 카드 클릭 콜백

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 카드 클릭 시 동작
      child: Card(
        key: ValueKey(event.eventId), // 각 카드에 고유 키를 부여
        color: Colors.white,
        elevation: 0,
        child: Stack(
          children: [
            // 메인 컨테이너
            Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 10),
                    Text(
                      event.description,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    // 사진 불러올 자리
                    if (event.images.isNotEmpty)
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true, // 부모 스크롤 안에서 동작하도록 설정
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 한 줄에 3개의 이미지
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: event.images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            event.images[index], // Firestore에서 가져온 이미지 URL
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailsCard extends StatelessWidget {
  final EventInfo event;
  const EventDetailsCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event!.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                '${event!.location.building} ${event!.location.detail}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${event!.time.start} ~ ${event!.time.end}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event!.description,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 10),
          //사진 불러올 자리
          if (event!.images.isNotEmpty)
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true, // 부모 스크롤 안에서 동작하도록 설정
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 3개의 이미지
                crossAxisSpacing: 10,
                mainAxisSpacing: 4,
              ),
              itemCount: event!.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  event!.images[index], // Firestore에서 가져온 이미지 URL
                  fit: BoxFit.cover,
                );
              },
            ),
          const SizedBox(height: 15),
          const Divider(
            color: CaupingLightGray, // 선 색상
            thickness: 5, // 선 두께
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '상세정보',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    '운영기간',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    '${event!.date.startDate} ~ ${event!.date.endDate}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text(
                    '운영주체',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    event!.host,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text(
                    '행사대상',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    event!.target,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text(
                    '행사유형',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    event!.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
