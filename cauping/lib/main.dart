import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '행사 등록'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  EventInfo eventInfo = EventInfo('', '', '', '', '', '', '', '', '');
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
    '기타'
  ];
  List<bool> _selected = List.generate(8, (index) => false); // 초기 상태 설정
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('등록'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('행사 기본 정보(필수)'),
              const Text('행사명'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '행사명을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  eventInfo.target = value!;
                },
              ),
              const Text('행사 설명'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '행사 설명을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  eventInfo.target = value!;
                },
              ),
              const Text('행사 주제'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '행사 주제 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  eventInfo.target = value!;
                },
              ),
              const Text('행사 대상'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '행사 대상을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  eventInfo.target = value!;
                },
              ),
              const Text('소속 대학'),
              DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: _deptList.contains(eventInfo.dept)
                      ? eventInfo.dept
                      : null,
                  items: _deptList
                      .map((dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      eventInfo.dept = value!;
                    });
                  }),
              const Text('행사 유형'),
              Wrap(
                spacing: 4.0,
                runSpacing: 8.0,
                children: List.generate(8, (index) {
                  return SizedBox(
                      width: MediaQuery.of(context).size.width / 4 - 20,
                      child: ChoiceChip(
                        label: Text(_optList[index]),
                        selected: _selected[index],
                        onSelected: (isSelected) {
                          setState(() {
                            _selected[index] = isSelected;
                          });
                        },
                      ));
                }),
              ),
              const Text('행사 기간'),
              const Text('행사 위치'),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '행사 대상을 입력하세요';
                  }
                  return null;
                },
                onSaved: (value) {
                  eventInfo.target = value!;
                },
              ),
              const Text('사진 첨부 (선택)'),
              const Text('최대 5개까지 업로드 가능합니다.'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.place_outlined),
            label: 'Pin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class EventInfo {
  String name;
  String discription;
  String host;
  String target;
  String dept;
  String category;
  String date;
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
    this.location,
    this.image,
  );
}
