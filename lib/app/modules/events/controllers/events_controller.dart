import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:samsung_admin_main_new/app/common/common_dialogs/confirmation_dialog.dart';
import 'package:samsung_admin_main_new/app/common/common_snackbar.dart';
import 'package:samsung_admin_main_new/app/common/constant/types.dart';
import 'package:samsung_admin_main_new/app/common/core/utils/result.dart';
import 'package:samsung_admin_main_new/app/common/services/user_service.dart';
import 'package:samsung_admin_main_new/app/models/event_model.dart';
import 'package:samsung_admin_main_new/app/models/event_registration_model.dart';
import 'package:samsung_admin_main_new/app/models/eventer_event_model.dart';
import 'package:samsung_admin_main_new/app/repository/events_repo.dart';

class EventsController extends GetxController {
  //TODO: Implement EventsController

  final count = 0.obs;

  final isLoading = true.obs;
  final eventList = <EventModel>[].obs;

  // Categorized events storage
  final internalEvents = <EventModel>[].obs;
  final externalEvents = <EventModel>[].obs;

  // Eventer events (external events from Eventer API)
  final eventerEvents = <EventerEventModel>[].obs;
  final isLoadingEventerEvents = false.obs;

  final currentPage = 1.obs;
  final perPage = 8.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  late ScrollController scrollController;
  final eventDate = TextEditingController();
  final endDate = TextEditingController();
  final validity = TextEditingController();
  final creditCost = TextEditingController();
  final costInPoints = TextEditingController();
  final maxTickets = TextEditingController();
  final Rxn<EventModel> selectedEvent = Rxn<EventModel>();
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> explanatoryVideoOptionalFile = Rx<PlatformFile?>(
    null,
  );
  final imageError = ''.obs;
  final videoError = ''.obs;
  final title = TextEditingController();
  final description = TextEditingController();
  final explanatoryVideoOptional = TextEditingController();
  final titleError = ''.obs;
  final eventDateError = ''.obs;
  final endDateError = ''.obs;
  final creditCostError = ''.obs;
  final costInPointsError = ''.obs;
  final maxTicketsError = ''.obs;
  final descriptionError = ''.obs;
  final isAlreadyFileUploaded = false.obs;
  final isAlreadyExplanatoryVideoOptionalFileUploaded = false.obs;
  final _hadVideoInitially = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  final eventRepo = Get.find<EventsRepo>();
  final UserService _userService = UserService();

  final isCreateEventBtnValue = false.obs;
  final isEditing = false.obs;
  final editingContentId = ''.obs;
  final selectedCategory =
      'All'.obs; // 'All', 'External Events', 'Internal Events'
  final currentEventerId = ''.obs;

  final eventRegistrations = <EventRegistrationModel>[].obs;
  final isLoadingRegistrations = false.obs;

  // Get filtered events based on selected category
  List<EventModel> get filteredEventList {
    List<EventModel> events;
    switch (selectedCategory.value) {
      case 'External Events':
        events = externalEvents.toList();
        break;
      case 'Internal Events':
        events = internalEvents.toList();
        break;
      case 'All':
      default:
        events = [...internalEvents, ...externalEvents];
        break;
    }
    // Sort by created_at in descending order (latest first)
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }

  @override
  void onReady() {
    super.onReady();
    fetchEventList();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        !isLoading.value &&
        hasMore.value) {
      loadMore();
    }
  }

  void resetPage() {
    currentPage.value = 1;
    hasMore.value = true;
    eventList.clear();
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value ||
        !hasMore.value ||
        currentPage.value >= totalPages.value) {
      return;
    }
    currentPage.value++;
    await fetchEventList(append: true);
  }

  void setSelectedEvent(EventModel event) {
    selectedEvent.value = event;
  }

  void clickOnDeleteBtn(String contentId) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToDeleteThisPost'.tr,
      onPressed: isLoading.value ? null : () => deleteContent(contentId),
    );
  }

  int getWordCount(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> fetchEventList({
    String? searchTerm,
    String? shortBy,
    bool append = false,
  }) async {
    try {
      if (append) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        eventList.clear();
        currentPage.value = 1;
        hasMore.value = true;
      }

      EventListResponse response = await eventRepo.fetchEventListWithPagination(
        pageNumber: currentPage.value,
        searchTerm: searchTerm ?? '',
        perPage: perPage.value,
      );
      totalCount.value = response.totalCount;
      totalPages.value = response.totalPages;

      // Separate events by type
      final internalEventsList = <EventModel>[];
      final externalEventsList = <EventModel>[];

      for (final event in response.data) {
        if (event.type == 'external') {
          externalEventsList.add(event);
        } else {
          internalEventsList.add(event);
        }
      }

      if (append) {
        eventList.addAll(response.data);
        internalEvents.addAll(internalEventsList);
        externalEvents.addAll(externalEventsList);
      } else {
        eventList.value = response.data;
        internalEvents.value = internalEventsList;
        externalEvents.value = externalEventsList;
        if (eventList.isNotEmpty) {
          selectedEvent.value = eventList.first;
        }
      }
      hasMore.value = currentPage.value < totalPages.value;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  String formatEventDate(DateTime? dob) {
    if (dob == null) return '-';
    return '${dob.day.toString().padLeft(2, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.year}';
  }

  void setSelectedFile(PlatformFile? file) {
    selectedFile.value = file;
    if (file != null) {
      isAlreadyFileUploaded.value = true;
      imageError.value = '';
    } else {
      isAlreadyFileUploaded.value = false;
    }
  }

  void setExplanatoryVideoOptionalFile(PlatformFile? file) {
    explanatoryVideoOptionalFile.value = file;
    if (file != null) {
      isAlreadyExplanatoryVideoOptionalFileUploaded.value = true;
      videoError.value = '';
      _hadVideoInitially.value = false;
    } else {
      isAlreadyExplanatoryVideoOptionalFileUploaded.value = false;
    }
  }

  Future<void> deleteContent(String id) async {
    debugPrint('called: $id');
    try {
      isLoading.value = true;
      final success = await eventRepo.deleteEvent(id);
      Get.back();
      if (success) {
        resetPage();
        await fetchEventList();
        CommonSnackbar.success('contentDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteContent'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleEventStatus(String id, String currentStatus) async {
    try {
      isLoading.value = true;
      final success = await eventRepo.toggleEventStatus(id, currentStatus);
      if (success) {
        await fetchEventList();
        final newStatus = currentStatus.toLowerCase() == 'active'
            ? 'inactive'
            : 'active';
        CommonSnackbar.success('Event status changed to $newStatus');
      } else {
        CommonSnackbar.error('Failed to toggle event status');
      }
    } catch (e) {
      debugPrint('Error toggling event status: $e');
      CommonSnackbar.error('Failed to toggle event status');
    } finally {
      isLoading.value = false;
    }
  }

  void clearErrors() {
    titleError.value = '';
    eventDateError.value = '';
    endDateError.value = '';
    creditCostError.value = '';
    costInPointsError.value = '';
    maxTicketsError.value = '';
    descriptionError.value = '';
    imageError.value = '';
    videoError.value = '';
  }

  bool validateForm() {
    clearErrors();
    bool hasError = false;
    if (title.text.isEmpty) {
      titleError.value = 'titleIsRequired'.tr;
      hasError = true;
    }
    if (eventDate.text.isEmpty) {
      eventDateError.value = 'eventDateIsRequired'.tr;
      hasError = true;
    }
    if (endDate.text.isEmpty) {
      endDateError.value = 'endDateIsRequired'.tr;
      hasError = true;
    }
    if (description.text.isEmpty) {
      descriptionError.value = 'descriptionIsRequired'.tr;
      hasError = true;
    } else {
      final words = getWordCount(description.text);
      if (words > 1000) {
        descriptionError.value = "Description can't exceed 1000 words";
        hasError = true;
      }
    }
    if (selectedFile.value == null && !isAlreadyFileUploaded.value) {
      imageError.value = 'imageRequired'.tr;
      hasError = true;
    }
    if (getWordCount(description.text) < 20 && description.text.isNotEmpty) {
      descriptionError.value = 'descriptionShouldHaveAtLeast20Words'.tr;
      hasError = true;
    }
    if (costInPoints.text.isEmpty) {
      costInPointsError.value = 'costInPointsIsRequired'.tr;
      hasError = true;
    }
    if (maxTickets.text.isEmpty) {
      maxTicketsError.value = 'maxTicketsIsRequired'.tr;
      hasError = true;
    }
    return !hasError;
  }

  Future<void> createEvent() async {
    if (!validateForm()) {
      return;
    }

    final date = DateFormat('dd-MM-yyyy').parse(eventDate.text);
    final parsedEndDate = DateFormat('dd-MM-yyyy').parse(endDate.text);
    isCreateEventBtnValue.value = true;
    try {
      isLoading.value = true;

      final isEventerEvent = currentEventerId.value.isNotEmpty;

      final result = await EventsRepo.createEvent(
        title.text,
        date.toIso8601String(),
        description.text,
        parsedEndDate.toIso8601String(),
        creditCost.text,
        costInPoints.text,
        maxTickets.text,
        selectedFile.value?.bytes ?? Uint8List(0),
        selectedFile.value?.name ?? '',
        explanatoryVideoOptionalFile.value?.bytes,
        explanatoryVideoOptionalFile.value?.name,
        eventerId: isEventerEvent ? currentEventerId.value : null,
        eventType: isEventerEvent ? 'external' : 'internal',
        status: isEventerEvent ? 'active' : null,
      );
      if (result.isSuccess) {
        Get.back();
        resetPage();
        await fetchEventList();
        CommonSnackbar.success('eventCreatedSuccessfully'.tr);
        currentEventerId.value = '';
      } else {
        CommonSnackbar.error('failedToCreateEvent'.tr);
        Get.back();
      }
    } finally {
      isLoading.value = false;
      isCreateEventBtnValue.value = false;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      isLoading.value = true;
      final success = await eventRepo.deleteEvent(id);
      Get.back();
      if (success) {
        await fetchEventList();
        CommonSnackbar.success('eventDeletedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToDeleteEvent'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent() async {
    if (!validateForm()) {
      return;
    }

    final date = DateFormat('dd-MM-yyyy').parse(eventDate.text);
    final duration = DateFormat('dd-MM-yyyy').parse(endDate.text);

    final shouldRemoveVideo =
        _hadVideoInitially.value && explanatoryVideoOptionalFile.value == null;

    isCreateEventBtnValue.value = true;
    try {
      isLoading.value = true;
      final result = await EventsRepo.updateEvent(
        editingContentId.value,
        title.text,
        description.text,
        duration.toIso8601String(),
        creditCost.text,
        costInPoints.text,
        maxTickets.text,
        date.toIso8601String(),
        selectedFile.value?.bytes ?? Uint8List(0),
        selectedFile.value?.name ?? '',
        explanatoryVideoOptionalFile.value?.bytes,
        explanatoryVideoOptionalFile.value?.name,
        shouldRemoveVideo,
      );
      if (result.isSuccess) {
        Get.back();
        resetPage();
        await fetchEventList();
        CommonSnackbar.success('eventUpdatedSuccessfully'.tr);
      } else {
        CommonSnackbar.error('failedToUpdateEvent'.tr);
        Get.back();
      }
    } finally {
      isLoading.value = false;
      isCreateEventBtnValue.value = false;
    }
  }

  void clearAllFields() {
    title.text = '';
    description.text = '';
    isEditing.value = false;
    selectedFile.value = null;
    editingContentId.value = '';
    endDate.text = '';
    eventDate.text = '';
    creditCost.text = '';
    costInPoints.text = '';
    maxTickets.text = '';
    isAlreadyExplanatoryVideoOptionalFileUploaded.value = false;
    isAlreadyFileUploaded.value = false;
    _hadVideoInitially.value = false;
    currentEventerId.value = '';
  }

  void prefillFormForEdit(EventModel event) {
    isEditing.value = true;
    editingContentId.value = event.id;
    title.text = event.title;
    eventDate.text = formatEventDate(event.eventDate);
    description.text = event.description.toString();
    isAlreadyFileUploaded.value = event.imageUrl.isNotEmpty;
    final hadVideo = event.video_url != null && event.video_url!.isNotEmpty;
    isAlreadyExplanatoryVideoOptionalFileUploaded.value = hadVideo;
    _hadVideoInitially.value = hadVideo;
    endDate.text = formatEventDate(event.end_date);
    creditCost.text = event.costCreditCents.toString();
    costInPoints.text = event.costPoints.toString();
    maxTickets.text = event.maxTickets?.toString() ?? '';
    clearErrors();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> fetchEventRegistrations(String eventId) async {
    try {
      isLoadingRegistrations.value = true;
      final registrations = await eventRepo.fetchEventRegistrations(eventId);
      eventRegistrations.value = registrations;
    } catch (e) {
      debugPrint('Error fetching event registrations: $e');
      eventRegistrations.clear();
    } finally {
      isLoadingRegistrations.value = false;
    }
  }

  void clickOnCancelRegistration(String registrationId, String eventTitle) {
    CMDialogs.showConfirmationDialog(
      title: 'confirmDeletion'.tr,
      subtitle: 'areYouSureYouWantToCancelThisRegistration'.tr,
      onPressed: isLoading.value
          ? null
          : () => cancelRegistration(registrationId, eventTitle),
    );
  }

  Future<void> cancelRegistration(
    String registrationId,
    String eventTitle,
  ) async {
    try {
      isLoading.value = true;

      final registration = await eventRepo.getEventRegistrationById(
        registrationId,
      );

      if (registration == null) {
        CommonSnackbar.error('Registration not found');
        return;
      }

      Get.back();

      if (registration.paymentMethod == PaymentMethod.points &&
          (registration.pointsPaid ?? 0) > 0) {
        final refundResult = await _userService.addPoints(
          registration.userId,
          registration.pointsPaid!,
          TransactionType.earned,
          description:
              'Points refunded for cancelled event registration: $eventTitle',
        );

        if (!refundResult.isSuccess) {
          CommonSnackbar.error('Failed to refund points');
          return;
        }
      }

      final success = await eventRepo.cancelEventRegistration(registrationId);
      if (success) {
        eventRegistrations.removeWhere((r) => r.id == registrationId);
        CommonSnackbar.success('Registration cancelled successfully');
      } else {
        CommonSnackbar.error('Failed to cancel registration');
      }
    } catch (e) {
      debugPrint('Error cancelling registration: $e');
      CommonSnackbar.error('Failed to cancel registration');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pullEventsFromEventer() async {
    try {
      isLoadingEventerEvents.value = true;

      final events = await eventRepo.fetchEventsFromEventer();

      eventerEvents.value = events;

      if (events.isEmpty) {
        CommonSnackbar.info('No events found from Eventer');
      } else {
        CommonSnackbar.success('Events fetched successfully');
      }
    } catch (e) {
      debugPrint('Error fetching Eventer events: $e');
      CommonSnackbar.error('Failed to fetch events from Eventer');
    } finally {
      isLoadingEventerEvents.value = false;
    }
  }

  void prefillFormFromEventerEvent(EventerEventModel eventerEvent) {
    clearAllFields();
    clearErrors();
    isEditing.value = false;

    currentEventerId.value = eventerEvent.id;

    title.text = eventerEvent.name;
    description.text = _stripHtmlTags(eventerEvent.eventDesc);

    final startDate = eventerEvent.schedule.start;
    final endDate = eventerEvent.schedule.end;
    eventDate.text = formatEventDate(startDate);
    this.endDate.text = formatEventDate(endDate);

    costInPoints.text = '0';
    creditCost.text = '0';
    maxTickets.text = '100';
    isAlreadyFileUploaded.value = false;
    selectedFile.value = null;

    if (eventerEvent.background != null || eventerEvent.thumbnail != null) {
      debugPrint(
        'Eventer event image URL: ${eventerEvent.background ?? eventerEvent.thumbnail}',
      );
    }
  }

  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }
}
