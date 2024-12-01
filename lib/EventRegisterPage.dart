import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'Colors.dart';
import 'EventInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.title});
  final String title;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  EventInfo eventInfo = EventInfo(
    '', // name
    '', // description
    '', // host
    '', // target
    '', // dept
    '', // category
    DateRange('', ''), // date
    TimeRange('', ''),
    '', // location
    '', // image
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  //final TextEditingController _categoryController = TextEditingController();
  //final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  //final TextEditingController _imageController = TextEditingController();

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

  final List<String> _locList = [
    '101관(영신관)',
    '102관(약학대학 및 R&D센터)',
    '103관(파이퍼홀)',
    '104관(수림과학관)',
    '105관(제1의학관)',
    '106관(제2의학관)',
    '107관(학생회관)',
    '108관',
    '201관(본관)',
    '202관(전산정보관)',
    '203관(서라벌홀)',
    '204관(중앙도서관)',
    '207관(봅스트홀)',
    '208관(제2공학관)',
    '209관(창업보육관)',
    '301관(중앙문화예술관)',
    '302관(대학원)',
    '303관(법학관)',
    '304관(미디어공영영상관)',
    '305관(교수연구동 및 체육관)',
    '307관(글로벌 하우스)',
    '308관(블루미르홀308관)',
    '309관(블루미르홀309관)',
    '310관(100주년기념관)',
    '청룡연못',
    '자이언트구장',
    '중앙마루(빼빼로광장)',
    '중앙광장',
    '의혈탑',
  ];

  String? _deptLocValue;
  String? _detailLocValue;

  final List<bool> _selected = List.generate(8, (index) => false); // 초기 상태 설정
  final _formKey = GlobalKey<FormState>();
  bool saving = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<File> _images = []; // 업로드된 이미지를 저장하는 리스트
  final int _maxImages = 5; // 최대 업로드 가능 이미지 수

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final formattedDate = "${picked.year}/${picked.month}/${picked.day}";
        if (isStart) {
          _startDate = picked;
          eventInfo.date.startDate = formattedDate;
        } else {
          _endDate = picked;
          eventInfo.date.endDate = formattedDate;
        }
      });
    }
  }

  String _startTime = "Start Time";
  String _endTime = "End Time";

  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  Future<void> _showCustomTimePicker(
      BuildContext context, bool isStartTime) async {
    _hourController.clear();
    _minuteController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // 키보드 높이에 따라 패딩 적용
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "시간 입력",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 시 입력
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: TextFormField(
                      controller: _hourController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: "시",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const Text(" : ", style: TextStyle(fontSize: 20)),
                  // 분 입력
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: TextFormField(
                      controller: _minuteController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: "분",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final String hour = _hourController.text.padLeft(2, '0');
                  final String minute = _minuteController.text.padLeft(2, '0');

                  if (hour.isEmpty || minute.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("시와 분을 모두 입력하세요.")),
                    );
                    return;
                  }

                  final int? hourInt = int.tryParse(hour);
                  final int? minuteInt = int.tryParse(minute);

                  if (hourInt == null ||
                      minuteInt == null ||
                      hourInt < 0 ||
                      hourInt > 23 ||
                      minuteInt < 0 ||
                      minuteInt > 59) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("유효한 시와 분을 입력하세요.")),
                    );
                    return;
                  }

                  setState(() {
                    if (isStartTime) {
                      _startTime = "$hour:$minute";
                      eventInfo.time.start = _startTime;
                    } else {
                      _endTime = "$hour:$minute";
                      eventInfo.time.end = _endTime;
                    }
                  });
                  Navigator.pop(context);
                },
                child: const Text("확인"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("최대 $_maxImages개의 이미지만 업로드할 수 있습니다.")),
      );
      return;
    }

    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _images.add(File(pickedImage.path));
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
    }
  }

  Future<void> _showSuccessDialog(
      BuildContext context, String eventName) async {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 배경 클릭으로 닫지 못하도록 설정
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: SecondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // 다이얼로그의 모서리를 둥글게
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '행사 등록 완료',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$eventName 행사가\n성공적으로 등록되었습니다.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            )),
        //leading: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // FormField 상태 초기화
                _formKey.currentState?.reset();

                eventInfo.dept = '';

                // TextEditingController 초기화
                _nameController.clear();
                _descriptionController.clear();
                _hostController.clear();
                _targetController.clear();
                _locationController.clear();

                // 날짜 및 시간 초기화
                _startDate = null;
                _endDate = null;
                _startTime = "Start Time";
                _endTime = "End time";

                // 카테고리 초기화
                for (int i = 0; i < _selected.length; i++) {
                  _selected[i] = false;
                }
                eventInfo.category = '';

                // 이미지 초기화
                _images.clear();

                // 기타 상태 초기화
                eventInfo = EventInfo(
                  '', // name
                  '', // description
                  '', // host
                  '', // target
                  '', // dept
                  '', // category
                  DateRange('', ''), // date
                  TimeRange('', ''), // time
                  '', // location
                  '', // image
                );
              });
            },
            child: const Text('취소',
                style: TextStyle(
                  color: PrimaryColor,
                )),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                const Text('행사 기본 정보(필수)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 16),
                const Text('행사명',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '행사명을 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventInfo.name = value!;
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 설명',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '행사 설명을 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventInfo.discription = value!;
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 주체',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '행사 주체를 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventInfo.host = value!;
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 대상',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
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
                const SizedBox(height: 12),
                const Text('소속 대학',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  hint: const Text(
                    '소속 대학을 선택해주세요.',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  value: _deptList.contains(eventInfo.dept)
                      ? eventInfo.dept
                      : null,
                  items: _deptList
                      .map((dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)))
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '소속 대학을 선택하세요';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      eventInfo.dept = value!;
                    });
                  },
                  onSaved: (value) {
                    eventInfo.dept = value!; // 최종 저장 시 반영
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 유형',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                FormField(
                  validator: (value) {
                    if (eventInfo.category.isEmpty) {
                      return '행사 유형을 선택해주세요.';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          shrinkWrap: true, // GridView가 스크롤하지 않도록 설정
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4, // 한 줄에 4개의 버튼
                          mainAxisSpacing: 8.0, // 세로 간격
                          crossAxisSpacing: 8.0, // 가로 간격
                          childAspectRatio: 2.2, // 버튼의 가로 세로 비율
                          children: List.generate(8, (index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width /
                                  4, // 화면 너비를 4등분
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    for (int i = 0; i < _selected.length; i++) {
                                      _selected[i] = false; // 모든 버튼을 선택 해제
                                    }
                                    _selected[index] = true; // 현재 버튼만 선택
                                    eventInfo.category =
                                        _optList[index]; // 선택된 값 저장
                                    state
                                        .didChange(eventInfo.category); // 상태 변경
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0), // 버튼 내부 패딩
                                  alignment: Alignment.center, // 텍스트 중앙 정렬
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selected[index]
                                          ? PrimaryColor
                                          : state.hasError &&
                                                  eventInfo.category.isEmpty
                                              ? Colors.red // 에러 시 빨간 테두리
                                              : Colors.grey, // 기본 테두리
                                      width: _selected[index]
                                          ? 1.5
                                          : 1.0, // 테두리 굵기
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(5.0), // 둥근 모서리
                                  ),
                                  child: Text(_optList[index]),
                                ),
                              ),
                            );
                          }),
                        ),
                        if (state.hasError &&
                            eventInfo.category.isEmpty) // 에러 메시지 출력
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.errorText!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 기간 및 시간',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                FormField(
                  validator: (value) {
                    // 날짜와 시간이 모두 비어 있을 경우
                    if ((_startDate == null || _endDate == null) &&
                        (_startTime == "Start Time" ||
                            _endTime == "End time")) {
                      return '날짜 및 시간을 입력해주세요.';
                    }
                    if (_startDate == null || _endDate == null) {
                      return '날짜를 입력해주세요.';
                    }
                    if (_startTime == "Start Time" || _endTime == "End time") {
                      return '시간을 입력해주세요.';
                    }
                    return null; // 유효성 검사가 통과되면 null 반환
                  },
                  builder: (state) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _startDate != null
                                          ? "${_startDate!.year}/${_startDate!.month}/${_startDate!.day}"
                                          : "Start Date",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _endDate != null
                                          ? "${_endDate!.year}/${_endDate!.month}/${_endDate!.day}"
                                          : "End date",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showCustomTimePicker(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _startTime != null
                                          ? _startTime!
                                          : "Start Time",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showCustomTimePicker(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _endTime != null ? _endTime! : "End time",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (state.hasError) // 에러 메시지 출력
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ]);
                  },
                ),
                const SizedBox(height: 12),
                const Text('행사 위치',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 5),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  hint: const Text(
                    '행사 위치를 선택해주세요.',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  value: _locList.contains(eventInfo.location)
                      ? eventInfo.location
                      : null,
                  items: _locList
                      .map((loc) =>
                          DropdownMenuItem(value: loc, child: Text(loc)))
                      .toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '행사 위치를 선택하세요';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      eventInfo.location = value!;
                    });
                  },
                  onSaved: (value) {
                    _deptLocValue = value;
                    //eventInfo.location = value!;
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: '상세 위치를 입력해주세요.',
                    hintStyle: TextStyle(fontSize: 12.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상세 위치를 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _detailLocValue = value;
                    //eventInfo.location = value!;
                  },
                ),
                const SizedBox(height: 20),
                const Text('사진 첨부 (선택)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                const Text('최대 5개까지 업로드 가능합니다.',
                    style: TextStyle(
                      fontSize: 10,
                    )),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 가로 스크롤 활성화
                  child: Row(
                    children: [
                      // 업로드된 이미지 표시
                      ..._images.map((image) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: FileImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.remove(image); // 이미지 삭제
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      // + 버튼
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          eventInfo.location =
                              '$_deptLocValue $_detailLocValue';

                          print("Saving Event Info: ${eventInfo.toMap()}");

                          try {
                            setState(() {
                              saving = true;
                            });

                            // 현재 로그인된 사용자의 uid 가져오기
                            final user = FirebaseAuth.instance.currentUser;
                            final uid = user?.uid;

                            await FirebaseFirestore.instance
                                .collection('events')
                                .add({
                              ...eventInfo.toMap(),
                              'uid': uid // 로그인된 사용자의 UID 추가
                            });

                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //       content: Text('행사가 성공적으로 등록되었습니다.')),
                            // );

                            // 성공 메시지 다이얼로그 호출
                            await _showSuccessDialog(context, eventInfo.name);

                            // 필드 초기화
                            setState(() {
                              // 폼 초기화
                              eventInfo.dept = '';

                              // GridView 선택 초기화
                              for (int i = 0; i < _selected.length; i++) {
                                _selected[i] = false; // 모든 버튼 선택 해제
                              }
                              eventInfo.category = ''; // 카테고리 초기화

                              // 텍스트 필드 초기화
                              _nameController.clear();
                              _descriptionController.clear();
                              _hostController.clear();
                              _targetController.clear();
                              _locationController.clear();

                              _startDate = null;
                              _endDate = null;
                              _startTime = "Start Time";
                              _endTime = "End Time";

                              // 이미지 초기화
                              _images.clear();

                              eventInfo = EventInfo(
                                '', // name
                                '', // description
                                '', // host
                                '', // target
                                '', // dept
                                '', // category
                                DateRange('', ''), // date
                                TimeRange('', ''), // time
                                '', // location
                                '', // image
                              );
                            });
                          } catch (e) {
                            saving = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('등록 실패: $e')),
                            );
                          } finally {
                            // 로딩 종료
                            setState(() {
                              saving = false;
                            });
                          }
                        }
                      },
                      child: const Text('등록',
                          style: TextStyle(
                            color: PrimaryColor,
                          ))),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
