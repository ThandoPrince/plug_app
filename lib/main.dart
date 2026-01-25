
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/app_routes.dart';
import 'package:flutter_application_1/common/utils/kstrings.dart';
import 'package:flutter_application_1/const/services/booking_services/create_booking_api.dart';
import 'package:flutter_application_1/const/services/sessions/confirm_checkin_api.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_location_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_negotiation_round_start_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_detail_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/create_booking_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/def_add_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/home_here_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/home_refresh_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/location_permission_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_OrderID_Ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_negoID_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/session_by_shipment_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/session_location_ping_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_confirm_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_add_by_id_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_addesses_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/user_input_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/controllers/onboarding_notifiers.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/drawer_notifier.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_contoller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';

Future<void> main() async {


  
  WidgetsFlutterBinding.ensureInitialized();

 

  await _initializeHERESDK();

  


  // 3️⃣ Pick env file depending on build mode
 



  // 5️⃣ Run the app with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingNotifier()),
        ChangeNotifierProvider(create: (_) => TabIndexNotifier()),
        ChangeNotifierProvider(create: (_) => DefAddController()),
        ChangeNotifierProvider(create: (_) => CostOfServiceByemailController()),
        ChangeNotifierProvider(create: (_) => AddressController()),
        ChangeNotifierProvider(create: (_) => SpAddressController()),
        ChangeNotifierProvider(create: (_) => DrawerNotifier()),
        ChangeNotifierProvider(create: (_) => AddressClientCtrl()),
        ChangeNotifierProvider(create: (_) => ClientPendingOrdersController()),
        ChangeNotifierProvider(create: (_) => ServiceController()..fetchServices()),
        ChangeNotifierProvider(create: (_) => ServiceProviderController()),
        ChangeNotifierProvider(create: (_) => ClientPendingOrdersDetailCtrl()),
        ChangeNotifierProvider(create: (_) => ClientProfileController()),
        ChangeNotifierProvider(create: (_) => SpProfileController()),
        ChangeNotifierProvider(create: (_) => NegotiationByIdController()),
        ChangeNotifierProvider(create: (_) => NegotationByOrderIDController()),
        ChangeNotifierProvider(create: (_) => LocationController()),
        ChangeNotifierProvider(create: (_) => LocationPermissionCtrl()),
        ChangeNotifierProvider(
          create: (_) => BookingController(apiService: BookingApiService()),
        ),
        ChangeNotifierProvider(create: (_) => ServiceProviderByEmailController()),
        ChangeNotifierProvider(create: (_) => SpAddressControllerByID()),
        ChangeNotifierProvider(
          create: (context) => HereMapMarkerController(
            defAddCtrl: Provider.of<DefAddController>(context, listen: false),
            spAddrCtrl: Provider.of<SpAddressControllerByID>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SPByAddressController()),
        ChangeNotifierProvider(create: (_) => NegotiatedPriceController()),
        ChangeNotifierProvider(create: (_) => ClientStartRoundController()),
        ChangeNotifierProxyProvider2<SPByAddressController, HereMapMarkerController, HomeRefreshController>(
          create: (_) => HomeRefreshController(
            spByAddressController: SPByAddressController(),
            mapMarkerCtrl: HereMapMarkerController(
              defAddCtrl: DefAddController(),
              spAddrCtrl: SpAddressControllerByID(),
              
            ),
            serviceController: ServiceController(),
          ),
          update: (_, spCtrl, mapCtrl, homeCtrl) => HomeRefreshController(
            spByAddressController: spCtrl,
            mapMarkerCtrl: mapCtrl,
            serviceController: homeCtrl!.serviceController,
          ),
        ),
        ChangeNotifierProvider(create: (_) => ShipmentController()),
        ChangeNotifierProvider(create: (_) => ShipmentConfirmController()),
        ChangeNotifierProvider(create: (_) => ClientCheckinController(),),
        ChangeNotifierProvider(create: (_) => SessionByShipmentController(),),
        ChangeNotifierProvider(create: (_) => ClientSessionLocationPingController(),),

        
         
      ],
      child: const MyApp(),
    ),
  );
}
Future<void> _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  String accessKeyId = "A4BPfmQeylObiKyCy4bpVw";
  String accessKeySecret = "fJ-0ruCb_mS29BQk46Hi28mp6toudzEIViGwUgiihVmLVgzAvnGB9P6KFDKgFDdSpB9_RHv4mbPW4d4DMudlRQ";
  AuthenticationMode authenticationMode =
      AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
  SDKOptions sdkOptions = SDKOptions.withAuthenticationMode(authenticationMode);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    

    return ScreenUtilInit(
      
      designSize: const Size(375, 812), // or your preferred default
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppText.kAppName,
          theme: ThemeData(useMaterial3: false),
          routerConfig: router,
        );
      },
    );
    
  }
}
