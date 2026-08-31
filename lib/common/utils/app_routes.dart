
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/global/navigation_observer_flushbar.dart';
import 'package:flutter_application_1/screens/Onboarding/Views/clientOnboarding_screen.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/privacy_policy_screen.dart';
import 'package:flutter_application_1/screens/Onboarding/terms_of_use/views/terms_of_use_screen.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/views/viewSP_Profile_requestScreen.dart';
import 'package:flutter_application_1/screens/address/views/address_creation_screen.dart';
import 'package:flutter_application_1/screens/auth/views/login_otp_verification_screen.dart';
import 'package:flutter_application_1/screens/auth/views/otp_verification_screen.dart';
import 'package:flutter_application_1/screens/location/views/address_screen.dart';
import 'package:flutter_application_1/screens/address/views/address_verification_screen.dart';
import 'package:flutter_application_1/screens/auth/views/auth_creation_screen.dart';
import 'package:flutter_application_1/screens/auth/views/client_details_patch_screen.dart';
import 'package:flutter_application_1/screens/auth/views/login_page.dart';
import 'package:flutter_application_1/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_1/screens/location/views/existing_address_verify.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_application_1/screens/location/views/new_address_verification_screen.dart';
import 'package:flutter_application_1/screens/notifications/views/notifications_screen.dart';
import 'package:flutter_application_1/screens/reset_password/views/reset_password_confirm_screen.dart';
import 'package:flutter_application_1/screens/reset_password/views/reset_password_screen.dart';

import 'package:flutter_application_1/screens/viewAllServices/screens/view_all_services.dart';
import 'package:flutter_application_1/screens/view_all_sp_service/views/view_sp_ass_service_screen.dart';
import 'package:go_router/go_router.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

late final GoRouter router;

GoRouter createRouter(String initialLocation) {
  router = GoRouter(
    observers: [AppNavigationObserver()],
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const ClientonboardingScreen(),
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
      path: '/existingAddressVerification',
      builder: (context, state) => const ExistingAddressVerificationScreen(),
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
  path: '/reset_password',
  builder: (context, state) => const ResetPasswordScreen(),
),

GoRoute(
  path: '/provider-details/:id',
  name: 'providerDetails',
  builder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');
    final serviceId = int.tryParse(state.uri.queryParameters['serviceId'] ?? '');

    if (id == null || serviceId == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid route parameters')),
      );
    }

    return ServiceProviderDetailsScreen(
      id: id,
      serviceId: serviceId,
    );
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
    
    return MainAddAddressScreen();
  },
),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthLoginScreen(),
    ),

    GoRoute(
  path: '/otpVerification',
  builder: (context, state) => const OtpVerificationScreen(),
),

GoRoute(
  path: '/loginOtpVerification',
  builder: (context, state) => const LoginOtpVerificationScreen(),
),

GoRoute(
  path: '/resetPasswordConfirm',
  builder: (context, state) => const ResetPasswordConfirmScreen(),
),

        GoRoute(
      path: '/location',
      builder: (context, state) {
        
        return LocationScreen();
      },
    ),
      
    ],
    
  );
   return router;
  
}




GoRouter get appRouter => router;
