import 'package:go_router/go_router.dart';
import '../../../model/result.dart';

import '../screen/login_register/login_screen.dart';
import '../screen/login_register/register_screen.dart';
import '../screen/login_register/register_from_login.dart';
import '../screen/login_register/forgot_pass.dart';
import '../screen/login_register/usage_guide.dart';

import '../screen/splash_screen.dart';
import '../screen/services/home_screen.dart';
import '../screen/services/index.dart';
import '../screen/services/lexicon.dart';
import '../screen/services/resources.dart';
import '../screen/services/thesaurus.dart';

import '../widget/result_cards/thesaurus/detail/thesaurus_detail.dart';
import '../widget/result_cards/library/library_detail.dart';
import '../widget/result_cards/index/index_detail.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterFromLogin(),
    ),
    GoRoute(
      path: '/register_home',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/usage_guide',
      builder: (context, state) => const UsageGuideScreen(),
    ),
    GoRoute(
      path: '/thesaurus/detail/:id',
      builder: (context, state) {
        final result = state.extra as ThesaurusResult;
        final query = state.uri.queryParameters['query'] ?? '';
        return ThesaurusDetailPage(result: result, searchQuery: query);
      },
    ),
    GoRoute(
      path: '/index/detail',
      builder: (context, state) {
        final result = state.extra as ThesaurusResult;
        return IndexDetailTerms(result: result);
      },
    ),
    GoRoute(
      path: '/thesaurus',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return ThesaurusScreen(initialSearchQuery: query);
      },
    ),
    GoRoute(
      path: '/lexicon',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return LexiconScreen(initialSearchQuery: query);
      },
    ),
    GoRoute(
      path: '/index',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return IndexScreen(initialSearchQuery: query);
      },
    ),
    GoRoute(
      path: '/resources/detail/:id',
      builder: (context, state) {
        final result = state.extra as ThesaurusResult;
        final query = state.uri.queryParameters['query'] ?? '';
        return LibraryDetailPage(result: result, searchQuery: query);
      },    
    ),
    GoRoute(
      path: '/resources',
      builder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return ResourcesScreen(initialSearchQuery: query);
      },
    ),
  ],
);
