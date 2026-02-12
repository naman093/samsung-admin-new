import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/modules/events/controllers/events_controller.dart';
import 'package:samsung_admin_main_new/app/modules/events/local_widget/eventer_event_card.dart';

class EventerEventsDialog extends StatelessWidget {
  final EventsController controller;
  final VoidCallback? onImportEvent;

  const EventerEventsDialog({
    super.key,
    required this.controller,
    this.onImportEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.externalEvents.length;

      return controller.isLoadingEventerEvents.value
          ? const Center(child: CircularProgressIndicator())
          : controller.eventerEvents.isEmpty
          ? Center(
              child: Text(
                'noFilesFound'.tr,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SizedBox(
              // padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12,
                  children: [
                    ...controller.eventerEvents
                        .where((eventerEvent) {
                          // Check if event exists in DB
                          final existsInDb = controller.externalEvents.any(
                            (event) => event.eventerId == eventerEvent.id,
                          );

                          // Filter out if exists in DB AND status is inactive
                          if (existsInDb) {
                            final event = controller.externalEvents.firstWhere(
                              (event) => event.eventerId == eventerEvent.id,
                            );
                            return event.status?.toLowerCase() != 'inactive';
                          }

                          return true;
                        })
                        .map((eventerEvent) {
                          final isImported = controller.externalEvents.any(
                            (event) => event.eventerId == eventerEvent.id,
                          );
                          return EventerEventCard(
                            eventerEvent: eventerEvent,
                            isImported: isImported,
                            onImport: () {
                              if (!isImported) {
                                Get.back();
                                controller.prefillFormFromEventerEvent(
                                  eventerEvent,
                                );
                                onImportEvent?.call();
                              }
                            },
                          );
                        })
                        .toList(),
                  ],
                ),
              ),
            );
    });
  }
}
