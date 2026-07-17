import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mma_flutter/app_status/screen/app_maintenance_alert_screen.dart';
import 'package:mma_flutter/common/firebase/analytics.dart';
import 'package:mma_flutter/common/screen/root_tab.dart';
import 'package:mma_flutter/common/screen/splash_screen.dart';
import 'package:mma_flutter/event/common/screen/active_event_screen.dart';
import 'package:mma_flutter/event/promotion/screen/promotion_detail_screen.dart';
import 'package:mma_flutter/fighter/screen/fighter_detail_screen.dart';
import 'package:mma_flutter/game/model/game_args.dart';
import 'package:mma_flutter/game/screen/game_description_screen.dart';
import 'package:mma_flutter/game/screen/game_end_screen.dart';
import 'package:mma_flutter/game/screen/game_main_screen.dart';
import 'package:mma_flutter/game/screen/game_screen.dart';
import 'package:mma_flutter/search/screen/search_screen.dart';
import 'package:mma_flutter/setting/account/account_deletion_screen.dart';
import 'package:mma_flutter/setting/account/account_setting_screen.dart';
import 'package:mma_flutter/setting/account/change_password_screen.dart';
import 'package:mma_flutter/setting/account/verify_password_screen.dart';
import 'package:mma_flutter/setting/announcement/screen/announcement_screen.dart';
import 'package:mma_flutter/setting/inquiry/faq/faq_screen.dart';
import 'package:mma_flutter/setting/notification/notification_setting_screen.dart';
import 'package:mma_flutter/setting/setting_selection_screen.dart';
import 'package:mma_flutter/user/provider/auth_change_provider.dart';
import 'package:mma_flutter/user/screen/init_nickname_screen.dart';
import 'package:mma_flutter/user/screen/login_screen.dart';

import '../../screen/home_splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final provider = ref.read(authChangeProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      // after login succeed
      GoRoute(
        path: '/',
        name: RootTab.routeName,
        builder: (context, state) => RootTab(),
        routes: [
          GoRoute(
            path: ActiveEventScreen.routeName,
            name: ActiveEventScreen.routeName,
            builder: (context, state) {
              return ActiveEventScreen();
            },
            routes: [
              GoRoute(
                path: '${PromotionDetailScreen.routeName}/:id',
                name: PromotionDetailScreen.routeName,
                builder: (context, state) {
                  return PromotionDetailScreen(id: int.parse(state.pathParameters['id']!));
                },
              ),
            ]
          ),
          GoRoute(
            path: '${FighterDetailScreen.routeName}/:id',
            name: FighterDetailScreen.routeName,
            builder: (context, state) {
              return FighterDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              );
            },
          ),
          GoRoute(
            path: GameMainScreen.routeName,
            name: GameMainScreen.routeName,
            builder: (context, state) {
              return GameMainScreen();
            },
          ),
          GoRoute(
            path: 'game/:seq',
            name: GameScreen.routeName,
            builder: (context, state) {
              final gameType = GameType.values.byName(
                state.queryParameters['gameType']!,
              );
              return GameScreen(
                seq: int.parse(state.pathParameters['seq']!),
                isNormal: state.queryParameters['isNormal'] == 'true',
                gameType: gameType,
              );
            },
          ),
          GoRoute(
            path: 'game_desc',
            name: GameDescriptionScreen.routeName,
            builder: (context, state) {
              final gameType = GameType.values.byName(
                state.queryParameters['gameType']!,
              );
              return GameDescriptionScreen(gameType: gameType);
            },
          ),
          GoRoute(
            path: GameEndScreen.routeName,
            name: GameEndScreen.routeName,
            builder: (context, state) {
              final gameType = GameType.values.byName(
                state.queryParameters['gameType']!,
              );
              return GameEndScreen(
                isNormal: state.queryParameters['isNormal'] == 'true',
                gameType: gameType,
              );
            },
          ),
          GoRoute(
            path: SearchScreen.routeName,
            name: SearchScreen.routeName,
            builder: (context, state) {
              return SearchScreen();
            },
          ),
          // setting
          GoRoute(
            path: SettingSelectionScreen.routeName,
            name: SettingSelectionScreen.routeName,
            builder: (context, state) {
              return SettingSelectionScreen();
            },
            routes: [
              // account
              GoRoute(
                path: AccountSettingScreen.routeName,
                name: AccountSettingScreen.routeName,
                builder: (context, state) {
                  return AccountSettingScreen();
                },
                routes: [
                  GoRoute(
                    path: VerifyPasswordScreen.routeName,
                    name: VerifyPasswordScreen.routeName,
                    builder: (context, state) {
                      return VerifyPasswordScreen();
                    },
                  ),
                  GoRoute(
                    path: ChangePasswordScreen.routeName,
                    name: ChangePasswordScreen.routeName,
                    builder: (context, state) {
                      return ChangePasswordScreen();
                    },
                  ),
                  GoRoute(
                    path: AccountDeletionScreen.routeName,
                    name: AccountDeletionScreen.routeName,
                    builder: (context, state) {
                      return AccountDeletionScreen();
                    },
                  ),
                ],
              ),
              // notification
              GoRoute(
                path: NotificationSettingScreen.routeName,
                name: NotificationSettingScreen.routeName,
                builder: (context, state) {
                  return NotificationSettingScreen();
                },
              ),
              // announcement
              GoRoute(
                path: AnnouncementScreen.routeName,
                name: AnnouncementScreen.routeName,
                builder: (context, state) {
                  return AnnouncementScreen();
                },
              ),
              // FAQ
              GoRoute(
                path: FaqScreen.routeName,
                name: FaqScreen.routeName,
                builder: (context, state) {
                  return FaqScreen();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/splash',
        name: SplashScreen.routeName,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/home_splash',
        name: HomeSplashScreen.routeName,
        builder: (context, state) => HomeSplashScreen(isUserStateLoading: true),
      ),
      GoRoute(
        path: '/init_nickname',
        name: InitNicknameScreen.routeName,
        builder: (context, state) => InitNicknameScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        name: AppMaintenanceAlertScreen.routeName,
        builder: (context, state) => AppMaintenanceAlertScreen(),
      ),
    ],
    initialLocation: '/splash',
    refreshListenable: provider,
    // 화면 이동마다 screen_view 이벤트 전송 → 가입 퍼널(어느 화면에서 이탈하는지) 분석
    observers: [Analytics.observer],

    /// provider 상태 변경될 때 redirect 실행
    redirect: (context, state) {
      return provider.redirectLogic(state);
    },
  );
});
