
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/global/navigation_observer_flushbar.dart';
import 'package:flutter_application_1/screens/Onboarding/Views/clientOnboarding_screen.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/privacy_policy_screen.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/terms_of_use_screen.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/views/viewSP_Profile_requestScreen.dart';
import 'package:flutter_application_1/screens/address/views/address_creation_screen.dart';
import 'package:flutter_application_1/screens/location/views/address_screen.dart';
import 'package:flutter_application_1/screens/address/views/address_verification_screen.dart';
import 'package:flutter_application_1/screens/auth/views/auth_creation_screen.dart';
import 'package:flutter_application_1/screens/auth/views/client_details_patch_screen.dart';
import 'package:flutter_application_1/screens/auth/views/login_page.dart';
import 'package:flutter_application_1/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_application_1/screens/location/views/new_address_verification_screen.dart';
import 'package:flutter_application_1/screens/notifications/views/notifications_screen.dart';
import 'package:flutter_application_1/screens/splash/spash_screen.dart';
import 'package:flutter_application_1/screens/viewAllServices/screens/view_all_services.dart';
import 'package:flutter_application_1/screens/view_all_sp_service/views/viewSp_AssService.dart';
import 'package:go_router/go_router.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final GoRouter _router = GoRouter(
  observers: [
    AppNavigationObserver(), 
  ],
   navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [

    GoRoute(
  path: '/',
  builder: (context, state) => const SpashScreen(), 
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
      builder: (context, state) => const AuthLoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthLoginScreen(),
    ),
        GoRoute(
      path: '/entryPoint',
      builder: (context, state) => EntryPoint(),
    ),
    GoRoute(
      path: '/addressVerificationUpload',
      builder: (context, state) => const AddressVerificationUploadScreen(),
    ),

  GoRoute(
      path: '/addressVerification',
      builder: (context, state) => const AddressVerificationScreen(),
    ),

    GoRoute(
      path: '/viewAllServices',
      builder: (context, state) => const ViewAllServices(),
    ),

    GoRoute(
      path: '/authCreation',
      builder: (context, state) => const AuthCreationScreen(),
    ),

    GoRoute(
      path: '/clientDetailsPatch',
      builder: (context, state) => const ClientDetailsPatchScreen(),
    ),

GoRoute(
  path: "/terms",
  builder: (context, state) => const TermsOfUseScreen(),
),
GoRoute(
  path: "/privacy",
  builder: (context, state) => const PrivacyPolicyScreen(),
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

    GoRoute(
      path: '/addaddress',
      builder: (context, state) => const AddAddressScreen(),
    ),
GoRoute(
  path: '/main_addaddress',
  builder: (context, state) {
    final email = state.uri.queryParameters['email'];
    return MainAddAddressScreen(clientemail: email);
  },
),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthLoginScreen(),
    ),

        GoRoute(
      path: '/location',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return LocationScreen(email: email);
      },
    ),

  ],
);

GoRouter get router => _router;
