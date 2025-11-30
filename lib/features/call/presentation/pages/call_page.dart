import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


class CallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final bool isVideoCall;

  const CallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    this.isVideoCall = true,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with your actual AppID and AppSign from ZegoCloud Console
    // https://console.zegocloud.com/
    const int appID = 2061629251; 
    const String appSign = 'b691c774af97766d7fc3bfcfd63aa1fd8b17e31b999986c33e5c4114c40a0f89';

    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: appID,
        appSign: appSign,
        userID: userID,
        userName: userName,
        callID: callID,
        config: isVideoCall
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : (ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
              ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
                style: ZegoMenuBarStyle.dark,
              )),
      ),
    );
  }
}
