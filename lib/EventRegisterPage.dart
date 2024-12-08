import 'dart:io';
import 'package:cauping/UpdatedEvents.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'Colors.dart';
import 'EventInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.title,
    this.initialEventInfo,
    this.showCancelButton = true, // 기본값은 true
    this.isEditing = false,
    this.docId, // 수정할 문서의 ID
  });
  final String title;
  final EventInfo? initialEventInfo;
  final bool showCancelButton;
  final bool isEditing;
  final String? docId;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late EventInfo eventInfo;
  final List<bool> _selected = List.generate(8, (index) => false); // 초기 상태 설정
  final _formKey = GlobalKey<FormState>();
  bool saving = false;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<File> _images = []; // 업로드된 이미지를 저장하는 리스트
  final List<String> _imageUrls = []; // Firestore에서 불러온 이미지 URL 리스트
  final int _maxImages = 5; // 최대 업로드 가능 이미지 수

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  //final TextEditingController _categoryController = TextEditingController();
  //final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  //final TextEditingController _imageController = TextEditingController();

  DateTime? parseDate(String date) {
    final parts = date.split('/');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  void initState() {
    super.initState();

    eventInfo = widget.initialEventInfo ??
        EventInfo(
          '',
          '', // name
          '', // description
          '', // host
          '', // target
          '', // dept
          '', // category
          DateRange('', ''), // date
          TimeRange('', ''), // time
          Location('', ''), // location
          [], //images
          null, // timestamp
        );

    _nameController.text = eventInfo.name;
    _descriptionController.text = eventInfo.description;
    _hostController.text = eventInfo.host;
    _targetController.text = eventInfo.target;
    _locationController.text = eventInfo.location.detail;

    _startDate = parseDate(eventInfo.date.startDate);
    _endDate = parseDate(eventInfo.date.endDate);
    _startTime = eventInfo.time.start;
    _endTime = eventInfo.time.end;

    // 행사유형 초기화
    if (eventInfo.category.isNotEmpty) {
      int index = _optList.indexOf(eventInfo.category);
      if (index != -1) {
        _selected[index] = true;
      }
    }

    // 이미지 초기화
    if (eventInfo.images.isNotEmpty) {
      _imageUrls.addAll(eventInfo.images);
      // 이미지 URL을 File 형태로 로드 (옵션)
      // for (String imageUrl in eventInfo.images) {
      //   // File 객체 대신 URL만 리스트에 추가 (화면에서 Image.network 사용)
      //   _images.add(File(imageUrl));
      // }
    }
  }

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
              const SizedBox(height: 10),
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

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      // 디버깅: 파일 경로 확인
      print('업로드할 파일 경로: ${imageFile.path}');
      print('파일 존재 여부: ${await imageFile.exists()}');
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      final uploadTask = await storageRef.putFile(imageFile);
      print('업로드 상태: ${uploadTask.state}');

      final downloadURL = await storageRef.getDownloadURL();
      print('이미지 업로드 성공: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  Future<void> _showSuccessDialog(
      BuildContext context, String eventName, bool isEdit) async {
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
                Text(
                  isEdit ? '행사 수정 완료' : '행사 등록 완료',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$eventName 행사가\n성공적으로 ${isEdit ? '수정' : '등록'}되었습니다.',
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

  Future<void> _showCancelDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 배경 클릭으로 닫지 못하도록 설정
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: SecondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // 다이얼로그의 모서리를 둥글게
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.72, // 화면의 80% 너비
            height: MediaQuery.of(context).size.height * 0.2, // 화면의 25% 높이
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '행사 등록 삭제',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '지금 돌아가시면 행사 등록이 삭제됩니다.\n삭제하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 취소 버튼
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(fontSize: 13.0, color: Colors.black),
                        ),
                      ),
                      // 삭제 버튼
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          setState(() {
                            _resetForm();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PrimaryColor,
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(fontSize: 13.0, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 폼 초기화 함수
  void _resetForm() {
    // 폼 초기화
    _formKey.currentState?.reset();

    eventInfo.dept = '';
    eventInfo.category = '';

    // GridView 선택 초기화
    for (int i = 0; i < _selected.length; i++) {
      _selected[i] = false; // 모든 버튼 선택 해제
    }

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

    // 이벤트 정보 초기화
    eventInfo = EventInfo(
      '',
      '', // name
      '', // description
      '', // host
      '', // target
      '', // dept
      '', // category
      DateRange('', ''), // date
      TimeRange('', ''), // time
      Location('', ''), // location
      [], //images
      null, // timestamp
    );
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
        centerTitle: true,
        elevation: 0.5,
        //leading: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        actions: widget.showCancelButton
            ? [
                TextButton(
                  onPressed: () {
                    _showCancelDialog(context);
                  },
                  child: const Text('취소',
                      style: TextStyle(
                        color: PrimaryColor,
                      )),
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          Padding(
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
                        eventInfo.name = value ?? '';
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
                        eventInfo.description = value ?? '';
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
                          eventInfo.dept = value ?? '';
                        });
                      },
                      onSaved: (value) {
                        eventInfo.dept = value ?? ''; // 최종 저장 시 반영
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
                                        for (int i = 0;
                                            i < _selected.length;
                                            i++) {
                                          _selected[i] = false; // 모든 버튼을 선택 해제
                                        }
                                        _selected[index] = true; // 현재 버튼만 선택
                                        eventInfo.category =
                                            _optList[index]; // 선택된 값 저장
                                        state.didChange(
                                            eventInfo.category); // 상태 변경
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
                                        borderRadius: BorderRadius.circular(
                                            5.0), // 둥근 모서리
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
                        if (_startTime == "Start Time" ||
                            _endTime == "End time") {
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          _startTime.isEmpty
                                              ? "Start Time"
                                              : _startTime, // 빈 문자열 처리
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
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          _endTime.isEmpty
                                              ? "End Time"
                                              : _endTime, // 빈 문자열 처리
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
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: CaupingGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: PrimaryColor),
                        ),

                        isDense: true,
                        //contentPadding: EdgeInsets.all(10),
                      ),
                      hint: const Text(
                        '행사 위치를 선택해주세요.',
                        style: TextStyle(fontSize: 12.0),
                      ),
                      value: _locList.contains(eventInfo.location.building)
                          ? eventInfo.location.building
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
                          eventInfo.location.building = value ?? '';
                        });
                      },
                      onSaved: (value) {
                        eventInfo.location.building = value ?? '';
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
                        eventInfo.location.detail = value ?? '';
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
                          // Firestore에서 불러온 이미지 URL 표시
                          ..._imageUrls.map((imageUrl) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _imageUrls.remove(imageUrl); // 이미지 삭제
                                      });

                                      try {
                                        // Firestore 문서 업데이트 (옵션)
                                        if (widget.docId != null &&
                                            widget.docId!.isNotEmpty) {
                                          await FirebaseFirestore.instance
                                              .collection('events')
                                              .doc(widget.docId)
                                              .update({
                                            'images':
                                                _imageUrls, // 업데이트된 URL 리스트 저장
                                          });
                                        }
                                      } catch (e) {
                                        // 삭제 실패 시 다시 복원
                                        setState(() {
                                          print(_imageUrls);
                                          _imageUrls.add(imageUrl);
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          // 로컬에서 새로 업로드된 이미지 표시
                          ..._images.map((imageFile) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: FileImage(imageFile), // 로컬 파일 이미지
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
                                        _images.remove(imageFile); // 로컬 파일 삭제
                                      });
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.grey,
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
                          onPressed: saving
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    print(
                                        "Saving Event Info: ${eventInfo.toMap()}");

                                    try {
                                      setState(() {
                                        saving = true;
                                      });

                                      // 현재 로그인된 사용자의 uid 가져오기
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      final uid = user?.uid;

                                      // 이미지 업로드 및 URL 생성
                                      List<String> uploadedImageUrls =
                                          List.from(_imageUrls);
                                      for (File image in _images) {
                                        try {
                                          final imageUrl =
                                              await _uploadImageToFirebase(
                                                  image);
                                          uploadedImageUrls.add(imageUrl);
                                          print('이미지 업로드 성공: $imageUrl');
                                        } catch (e) {
                                          print(
                                              '이미지 업로드 실패: $e, 파일 경로: ${image.path}');
                                        }
                                      }

                                      if (widget.isEditing &&
                                          widget.docId!.isNotEmpty) {
                                        // 행사 수정
                                        await FirebaseFirestore.instance
                                            .collection('events')
                                            .doc(widget.docId) // 기존 문서 ID로 업데이트
                                            .update({
                                          ...eventInfo.toMap(),
                                          'uid': uid,
                                          'images':
                                              uploadedImageUrls, // 이미지 URL 리스트
                                        });

                                        // 행사수정 성공 메시지
                                        await _showSuccessDialog(
                                            context, eventInfo.name, true);

                                        // 이전 페이지로 돌아가기
                                        Navigator.pop(context, true);
                                      } else {
                                        // 행사 등록
                                        await FirebaseFirestore.instance
                                            .collection('events')
                                            .add({
                                          ...eventInfo.toMap(),
                                          'uid': uid, // 로그인된 사용자의 UID
                                          'images':
                                              uploadedImageUrls, // 이미지 URL 리스트 (없으면 빈 리스트)
                                          'timestamp': FieldValue
                                              .serverTimestamp(), // 현재 시간을 저장
                                        });

                                        // 행사 등록 성공 메시지 다이얼로그 호출
                                        await _showSuccessDialog(
                                            context, eventInfo.name, false);

                                        // 필드 초기화
                                        setState(() {
                                          _resetForm();
                                        });

                                        // 행사 리스트 페이지로 이동
                                      }
                                    } catch (e) {
                                      print('Firestore 수정 실패: $e');
                                      //saving = false;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('수정 실패: $e')),
                                      );
                                    } finally {
                                      // 로딩 종료
                                      setState(() {
                                        saving = false;
                                      });
                                    }
                                  }
                                },
                          child: Text(widget.isEditing ? '수정' : '등록',
                              style: const TextStyle(
                                color: PrimaryColor,
                              ))),
                    ),
                    const SizedBox(height: 16),
                    // 로딩 인디케이터 표시
                  ],
                ),
              ),
            ),
          ),
          if (saving)
            Container(
              color: Colors.black.withOpacity(0.5), // 반투명 배경
              child: const Center(
                child: CircularProgressIndicator(), // 로딩 인디케이터
              ),
            ),
        ],
      ),
    );
  }
}
