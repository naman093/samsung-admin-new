import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/app_theme/app_colors.dart';
import 'package:samsung_admin_main_new/app/common/widgets/network_image_widget.dart';
import 'package:samsung_admin_main_new/app/modules/chat/controllers/chat_controller.dart';

class LeftSidebar extends StatelessWidget {
  LeftSidebar({super.key});

  final ChatController _controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.dashboardContainerBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final filtered = _controller.filteredUsers;
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _controller.searchQuery.value.trim().isEmpty
                        ? 'No users found'
                        : 'No matching users',
                    style: TextStyle(color: AppColors.greyColor, fontSize: 13),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 10),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return Obx(() {
                    final isSelected =
                        _controller.selectedUser.value?.id == user.id;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _controller.selectUser(user),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.cardColor : null,
                            // border: isSelected
                            //     ? Border.all(
                            //         color: isSelected
                            //             ? AppColors.primaryColor
                            //             : AppColors.cardColor,
                            //         width: 1,
                            //       )
                            //     : null,
                            // boxShadow: [
                            //   if (!isSelected)
                            //     BoxShadow(
                            //       color: Colors.grey.withOpacity(0.1),
                            //       blurRadius: 4,
                            //       offset: Offset(0, 2),
                            //     ),
                            // ],
                          ),
                          child: Row(
                            children: [
                              NetworkImageWidget(
                                imageUrl: user.profilePictureUrl ?? '',
                                height: 40,
                                width: 40,
                                radius: 100,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'Unknown User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user.role.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
                separatorBuilder: (context, index) => SizedBox(height: 8),
                itemCount: filtered.length,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkGreyColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dashboardContainerBorder),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: _controller.searchController,
          onChanged: (value) => _controller.searchQuery.value = value,
          style: TextStyle(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            hintText: 'Search users...',
            hintStyle: TextStyle(
              color: AppColors.greyColor.withOpacity(0.8),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.greyColor,
              size: 20,
            ),
            suffixIcon: _controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.searchController.clear();
                      _controller.searchQuery.value = '';
                    },
                    child: Icon(
                      Icons.clear,
                      color: AppColors.greyColor,
                      size: 18,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    });
  }
}
