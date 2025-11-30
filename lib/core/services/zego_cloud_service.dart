import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCloudService {
  static String getShortID(String userID) {
    String shortUserID = userID.replaceAll('-', '');
    if (shortUserID.length > 20) {
      shortUserID = shortUserID.substring(0, 20);
    }
    return shortUserID;
  }

  static void init({
    required String userID,
    required String userName,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    final shortUserID = getShortID(userID);
    
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 2061629251,
      appSign: 'b691c774af97766d7fc3bfcfd63aa1fd8b17e31b999986c33e5c4114c40a0f89',
      userID: shortUserID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
    
    if (navigatorKey != null) {
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    }
    
    print("ZegoCloud Service Initialized for user: $shortUserID");
  }

  static void uninit() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
