import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/common/widgets/common_widget.dart';
import 'package:samsung_admin_main_new/app/modules/chat/controllers/chat_controller.dart';
import 'package:samsung_admin_main_new/app/modules/chat/local_widgets/left_sidebar.dart';
import 'package:samsung_admin_main_new/app/modules/chat/local_widgets/chat_area.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonWidget.commonCardView(
      // title: 'chat'.tr,
      // subTitle: 'chatDescription'.tr,
      shouldHaveTopSpace: false,
      isScrollable: false,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar: Fixed width, takes full height
              SizedBox(
                width: 260,
                height: constraints.maxHeight,
                child: LeftSidebar(),
              ),
              // Chat Area: Expands to fill remaining width and takes full height
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: ChatArea(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
