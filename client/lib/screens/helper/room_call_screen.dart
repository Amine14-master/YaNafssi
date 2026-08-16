import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'dart:math';

class RoomCallScreen extends StatefulWidget {
  final String roomId;
  final String roomTitle;

  const RoomCallScreen({
    super.key,
    required this.roomId,
    required this.roomTitle,
  });

  @override
  State<RoomCallScreen> createState() => _RoomCallScreenState();
}

class _RoomCallScreenState extends State<RoomCallScreen> {
  final _jitsiMeetPlugin = JitsiMeet();
  bool _hasJoined = false;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  void _joinMeeting() async {
    final String localUserId = Random().nextInt(10000).toString();
    final String localUserName = 'User_$localUserId';

    var options = JitsiMeetConferenceOptions(
      room: widget.roomId,
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
      },
      userInfo: JitsiMeetUserInfo(
          displayName: localUserName,
      ),
    );

    var listener = JitsiMeetEventListener(
      conferenceTerminated: (url, error) {
        debugPrint("conferenceTerminated: url: $url, error: $error");
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );

    setState(() {
      _hasJoined = true;
    });

    await _jitsiMeetPlugin.join(options, listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _hasJoined ? 'Joining room...' : 'Initializing video call...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
