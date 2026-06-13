import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:mma_flutter/app_status/provider/app_status_provider.dart';
import 'package:mma_flutter/app_status/provider/server_state_provider.dart';
import 'package:mma_flutter/app_status/screen/app_maintenance_alert_screen.dart';
import 'package:mma_flutter/common/const/app_colors.dart';
import 'package:mma_flutter/common/const/colors.dart';
import 'package:mma_flutter/common/const/data.dart';
import 'package:mma_flutter/common/notification/fcm_initializer.dart';
import 'package:mma_flutter/common/provider/route/router.dart'
    show routerProvider, rootNavigatorKey;
import 'package:mma_flutter/common/provider/theme/theme_mode_provider.dart';
import 'package:mma_flutter/common/screen/splash_screen.dart';
import 'package:naver_login_sdk/naver_login_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

const _env = String.fromEnvironment('ENV', defaultValue: 'dev');
const _prodBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
const _devHost = String.fromEnvironment('DEV_HOST', defaultValue: '10.210.100.65');

const _realDeviceBaseUrl = 'http://$_devHost:8080';

void main() async {
  if (_env == 'prod' && _prodBaseUrl.isEmpty) {
    throw Exception('prod 빌드 시 --dart-define=BASE_URL=<url> 필요');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  if (Platform.isIOS) {
    final beforeStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('[ATT] before request status=$beforeStatus');
    final result = await AppTrackingTransparency.requestTrackingAuthorization();
    debugPrint('[ATT] after request status=$result');
  }
  await MobileAds.instance.initialize();
  final packageInfo = await PackageInfo.fromPlatform();
  appVersion = packageInfo.version;
  if (_env == 'prod') {
    baseUrl = _prodBaseUrl;
  } else {
    baseUrl = _realDeviceBaseUrl;
  }

  await FcmInitializer.init();

  await dotenv.load(fileName: "asset/config/.env");
  KakaoSdk.init(
    nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'),
    javaScriptAppKey: dotenv.get("KAKAO_JS_KEY"),
  );

  NaverLoginSDK.initialize(
    urlScheme: dotenv.get('NAVER_URL_SCHEME'),
    clientId: dotenv.get('NAVER_CLIENT_ID'),
    clientSecret: dotenv.get('NAVER_CLIENT_SECRET'),
    clientName: dotenv.get('NAVER_CLIENT_NAME'),
  );
  runApp(
    ProviderScope(
      child: Builder(
        builder: (context) {
          FlutterError.demangleStackTrace = (StackTrace stack) {
            if (stack is stack_trace.Chain) {
              return stack.toTrace();
            }
            return stack;
          };

          return ScreenUtilInit(
            designSize: const Size(402, 874), // 피그마 캔버스 그대로
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => _App(),
          );
        },
      ),
    ),
  );
}

const _lightColors = AppColors(
  surface: Color(0xffFFFAF8),
  box: Color(0xffb3b3b3),
  onBox: Color(0xff1F2022),
  onSurface: Color(0xff0F0F10),
  subText: Color(0xff8C8C8C),
);

const _darkColors = AppColors(
  surface: Color(0xff0F0F10),
  box: Color(0xff1F2022),
  onBox: Color(0xffb3b3b3),
  onSurface: Color(0xffFFFAF8),
  subText: Color(0xff8C8C8C),
);

class _App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightAppBarTheme = AppBarTheme(
      backgroundColor: _lightColors.surface,
      foregroundColor: _lightColors.onSurface,
      elevation: 0,
    );
    final darkAppBarTheme = AppBarTheme(
      backgroundColor: _darkColors.surface,
      foregroundColor: _darkColors.onSurface,
      elevation: 0,
    );

    final textTheme = TextTheme(
      bodySmall: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    );
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ko', 'KR'),
      // 기본 언어 한국어
      supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        appBarTheme: lightAppBarTheme,
        brightness: Brightness.light,
        textTheme: textTheme,
        fontFamily: 'NotoSans',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _lightColors.box,
          contentTextStyle: TextStyle(
            fontSize: 13.sp,
            color: _lightColors.onSurface,
          ),
        ),
      ),
      darkTheme: ThemeData(
        appBarTheme: darkAppBarTheme,
        brightness: Brightness.dark,
        textTheme: textTheme,
        fontFamily: 'NotoSans',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _darkColors.box,
          contentTextStyle: TextStyle(
            fontSize: 13.sp,
            color: _darkColors.onSurface,
          ),
        ),
      ),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => _ServerStateListener(child: child!),
    );
  }
}

void _exitApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}

class _ServerStateListener extends ConsumerWidget {
  final Widget child;
  const _ServerStateListener({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ServerState>(serverStateProvider, (prev, next) {
      if (next == ServerState.maintenance) {
        ref.read(routerProvider).goNamed(AppMaintenanceAlertScreen.routeName);
      } else if (next == ServerState.timeout) {
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;
        if (Platform.isIOS) {
          showCupertinoDialog(
            context: navContext,
            barrierDismissible: false,
            builder: (dialogContext) => CupertinoAlertDialog(
              title: const Text('서버 응답 지연'),
              content: const Text('서버 응답이 지연되고 있습니다.\n잠시 후 다시 시도해 주세요.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(serverStateProvider.notifier).state = ServerState.normal;
                    ref.invalidate(appStatusProvider);
                    ref.read(routerProvider).goNamed(SplashScreen.routeName);
                  },
                  child: const Text('재시도'),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: _exitApp,
                  child: const Text('종료'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: navContext,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: _darkColors.box,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(
                '서버 응답 지연',
                style: TextStyle(
                  color: _darkColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              content: Text(
                '서버 응답이 지연되고 있습니다.\n잠시 후 다시 시도해 주세요.',
                style: TextStyle(color: _darkColors.onSurface, fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(serverStateProvider.notifier).state = ServerState.normal;
                    ref.invalidate(appStatusProvider);
                    ref.read(routerProvider).goNamed(SplashScreen.routeName);
                  },
                  child: Text('재시도', style: TextStyle(color: _darkColors.onSurface)),
                ),
                TextButton(
                  onPressed: _exitApp,
                  child: Text('종료', style: TextStyle(color: MID_GREY_COLOR)),
                ),
              ],
            ),
          );
        }
      }
    });
    return child;
  }
}

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  AppColors get colors =>
      Theme.of(this).brightness == Brightness.dark ? _darkColors : _lightColors;

  TextTheme get text => Theme.of(this).textTheme;
}
