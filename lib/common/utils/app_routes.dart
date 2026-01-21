// ignore_for_file: unused_element


import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/global/navigation_observer_flushbar.dart';
import 'package:flutter_application_1/screens/Onboarding/Views/clientOnboarding_screen.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/views/viewSP_Profile_requestScreen.dart';
import 'package:flutter_application_1/screens/auth/views/login_page.dart';
import 'package:flutter_application_1/screens/client_login.dart';
import 'package:flutter_application_1/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_application_1/screens/notifications/views/notifications_screen.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:flutter_application_1/screens/viewAllServices/screens/view_all_services.dart';
import 'package:flutter_application_1/screens/view_all_sp_service/views/viewSp_AssService.dart';
import 'package:go_router/go_router.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final GoRouter _router = GoRouter(
  observers: [
    AppNavigationObserver(), // ✅ Flushbar auto-dismiss
  ],
   navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [

    GoRoute(
  path: '/',
  builder: (context, state) => const SpashScreen(), // or your app's home screen
),

    GoRoute(
      path: '/splash',
      builder: (context, state) => const SpashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const ClientonboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const ClientLogin(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const ClientLogin(),
    ),
        GoRoute(
      path: '/entryPoint',
      builder: (context, state) => EntryPoint(),
    ),

    GoRoute(
      path: '/viewAllServices',
      builder: (context, state) => const ViewAllServices(),
    ),

GoRoute(
  path: '/viewspByService',
  name: 'viewSPByService',
  builder: (context, state) {
    final serviceIdParam = state.uri.queryParameters['serviceId'];
    final serviceName = state.uri.queryParameters['serviceName'] ?? 'Service Providers';

    // Validate and parse serviceId
    if (serviceIdParam == null || int.tryParse(serviceIdParam) == null) {
      return const Scaffold(
        body: Center(child: Text("Invalid or missing service ID.")),
      );
    }

    final serviceId = int.parse(serviceIdParam);

    return ServiceProvidersByServiceScreen(
      serviceId: serviceId,
      serviceName: serviceName,
    );
  },
),

GoRoute(
  path: '/provider-details/:email',
  name: 'providerDetails',
  builder: (context, state) {
    final email = state.pathParameters['email']!;
    final serviceIdStr = state.uri.queryParameters['serviceId'];
    final serviceId = serviceIdStr != null ? int.tryParse(serviceIdStr) : null;

    if (serviceId == null) {
      return Scaffold(
        body: Center(child: Text('Missing or invalid serviceId')),
      );
    }

    return ServiceProviderDetailsScreen(email: email, serviceId: serviceId);
  },
),


        GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // GoRoute(
    //   path: '/resetPassword',
    //   builder: (context, state) => const ResetPasswordPage(),
    // ),
    // GoRoute(
    //   path: '/verifyEmail',
    //   builder: (context, state) => const VerifyEmailPage(),
    // ),
    // GoRoute(
    //   path: '/verifyPhone',
    //   builder: (context, state) => const VerifyPhonePage(),
    // ),
    // GoRoute(
    //   path: '/verifyOtp',
    //   builder: (context, state) => const VerifyOtpPage(),
    // ),
    // GoRoute(
    //   path: '/home',
    //   builder: (context, state) => const HomePage(),
    // ),
    

    

//     GoRoute(
//       path: '/verification',
//       builder: (context, state) => const VerificationPage(),
//     ),
//     GoRoute(
//       path: '/search',
//       builder: (context, state) => const SearchPage(),
//     ),
//     GoRoute(
//       path: '/help',
//       builder: (context, state) => const HelpCenterPage(),
//     ),
//     GoRoute(
//       path: '/orders',
//       builder: (context, state) => const OrdersPage(),
//     ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

        GoRoute(
      path: '/location',
      builder: (context, state) => const LocationScreen(),
    ),
//     GoRoute(
//       path: '/register',
//       builder: (context, state) => const RegistrationPage(),
//     ),
//     GoRoute(
//       path: '/categories',
//       builder: (context, state) => const CategoriesPage(),
//     ),
//      GoRoute(
//       path: '/category',
//       builder: (context, state) => const CategoryPage(),
//     ),

//     GoRoute(
//       path: '/addaddress',
//       builder: (context, state) => const AddAddress(),
//     ),

//     GoRoute(
//       path: '/addresses',
//       builder: (context, state) => const AddressesListPage(),
//     ),

//      GoRoute(
//       path: '/notifications',
//       builder: (context, state) => const NotificationPage(),
//     ),

//      GoRoute(
//       path: '/tracking',
//       builder: (context, state) => const TrackOrderPage(),
//     ),

//     GoRoute(
//       path: '/checkout',
//       builder: (context, state) => const CheckoutPage(),
//     ),

//       GoRoute(
//       path: '/successful',
//       builder: (context, state) => const SuccessfulPayment(),
//     ),

//       GoRoute(
//       path: '/failed',
//       builder: (context, state) => const FailedPayment(),
//     ),

//     GoRoute(
//       path: '/product/:id',
//       builder: (BuildContext context, GoRouterState state) {
//         final productId = state.pathParameters['id'];
//         return ProductPage(productId: productId.toString());
//       },
//     ),
  ],
);

GoRouter get router => _router;
