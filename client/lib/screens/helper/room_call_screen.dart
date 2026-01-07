import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:math';

class RoomCallScreen extends StatelessWidget {
  final String roomId;
  final String roomTitle;

  const RoomCallScreen({
    super.key,
    required this.roomId,
    required this.roomTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a random user ID and name for testing
    final String localUserId = Random().nextInt(10000).toString();
    final String localUserName = 'User_$localUserId';

    return ZegoUIKitPrebuiltCall(
      appID: 123456789, // Replace with your AppID
      appSign: 'YOUR_APP_SIGN_HERE', // Replace with your AppSign
      callID: roomId,
      userID: localUserId,
      userName: localUserName,
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall(),
    );
  }
}
