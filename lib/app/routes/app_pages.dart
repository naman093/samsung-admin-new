import 'package:get/get.dart';
import 'package:samsung_admin_main_new/app/modules/chat/binding/chat_view_binding.dart';
import 'package:samsung_admin_main_new/app/modules/chat/views/chat_view.dart';

import '../modules/academy/bindings/academy_binding.dart';
import '../modules/academy/views/academy_view.dart';
import '../modules/community/bindings/community_binding.dart';
import '../modules/community/views/community_view.dart';
import '../modules/events/bindings/events_binding.dart';
import '../modules/events/views/events_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/point-store/bindings/point_store_binding.dart';
import '../modules/point-store/views/point_store_view.dart';
import '../modules/profile-details/bindings/profile_details_binding.dart';
import '../modules/profile-details/views/profile_details_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/users_view.dart';
import '../modules/verify-code/bindings/verify_code_binding.dart';
import '../modules/verify-code/views/verify_code_view.dart';
import '../modules/vod-podcasts/bindings/vod_podcasts_binding.dart';
import '../modules/vod-podcasts/views/vod_podcasts_view.dart';
import '../modules/weekly-riddle/bindings/weekly_riddle_binding.dart';
import '../modules/weekly-riddle/views/weekly_riddle_view.dart';
import '../modules/edit-profile/bindings/edit_profile_binding.dart';
import '../modules/edit-profile/views/edit_profile_view.dart';
import '../modules/prod-orders/bindings/prod_orders_binding.dart';
import '../modules/prod-orders/views/prod_orders_view.dart';
import '../modules/promotions/bindings/promotions_binding.dart';
import '../modules/promotions/views/promotions_view.dart';
import 'auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    GetPage(
      name: _Paths.ACADEMY,
      page: () => AcademyView(),
      binding: AcademyBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.COMMUNITY,
      page: () => CommunityView(),
      binding: CommunityBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => ChatView(),
      binding: ChatBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.USERS,
      page: () => UsersView(),
      binding: UsersBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.VOD_PODCASTS,
      page: () => VodPodcastsView(),
      binding: VodPodcastsBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: _Paths.VERIFY_CODE,
      page: () => const VerifyCodeView(),
      binding: VerifyCodeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_DETAILS,
      page: () => const ProfileDetailsView(),
      binding: ProfileDetailsBinding(),
    ),
    GetPage(
      name: _Paths.POINT_STORE,
      page: () => const PointStoreView(),
      binding: PointStoreBinding(),
    ),
    GetPage(
      name: _Paths.EVENTS,
      page: () => const EventsView(),
      binding: EventsBinding(),
    ),
    GetPage(
      name: _Paths.WEEKLY_RIDDLE,
      page: () => const WeeklyRiddleView(),
      binding: WeeklyRiddleBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_ORDERS,
      page: () => const ProdOrdersView(),
      binding: ProdOrdersBinding(),
    ),
    GetPage(
      name: _Paths.PROMOTIONS,
      page: () => const PromotionsView(),
      binding: PromotionsBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
  ];
}
