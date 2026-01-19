import 'package:flutter/material.dart';

/// 트레이너 메시지 화면
class TrainerMessagesScreen extends StatelessWidget {
  const TrainerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
      ),
      body: ListView.builder(
        itemCount: _dummyChats.length,
        itemBuilder: (context, index) {
          final chat = _dummyChats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(chat['name'][0]),
            ),
            title: Text(chat['name']),
            subtitle: Text(
              chat['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (chat['unread'] > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // TODO: 채팅 상세 화면으로 이동
            },
          );
        },
      ),
    );
  }
}

// 임시 데이터
final List<Map<String, dynamic>> _dummyChats = [
  {'name': '김민수', 'lastMessage': '오늘 수업 감사합니다!', 'time': '오후 2:30', 'unread': 2},
  {'name': '이수진', 'lastMessage': '내일 수업 시간 변경 가능할까요?', 'time': '오전 11:20', 'unread': 1},
  {'name': '박지영', 'lastMessage': '식단 사진 보내드릴게요', 'time': '어제', 'unread': 0},
];
