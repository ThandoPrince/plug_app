
import 'package:flutter_application_1/global_util/services/controler/address_a_creation_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_order_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cancel_shipment_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_update_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/completed_service_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_image_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/get_client_auth_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/google_map_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/logout_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/patch_default_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/reject_negociation_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/reset_password_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/shipment_reshedule_controler.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_rating_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/update_final_price_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/update_order_service_controller.dart';
import 'package:flutter_application_1/screens/Onboarding/controllers/onboarding_notifiers.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/tab_lifecycle_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_application_1/global_util/services/controler/address_client_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/address_creation_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/address_verification_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_login_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_auth_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_location_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/client_negotiation_round_start_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_pending_orders_detail_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_by_email_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/client_profile_creation_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/confirm_session_controller.dart';
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
import 'package:flutter_application_1/global_util/services/controler/submit_ratings_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/user_input_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/drawer_notifier.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_contoller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_address_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_profile_controller.dart';

List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => OnboardingNotifier()),
  ChangeNotifierProvider(create: (_) => ShipmentRescheduleController()),
  ChangeNotifierProvider(create: (_) => NegotiationBadgeStore()),
  ChangeNotifierProvider(create: (_) => TabIndexNotifier()),
  ChangeNotifierProvider(create: (_) => LogoutController()),
  ChangeNotifierProvider(create: (_) => TabLifecycleController()),
  ChangeNotifierProvider(create: (_) => GetClientAuthController()),
  ChangeNotifierProvider(create: (_) => CostOfServiceController()),
  ChangeNotifierProvider(create: (_) => DrawerNotifier()),
  ChangeNotifierProvider(create: (_) => ResetPasswordController()),
  ChangeNotifierProvider(create: (_) => LoginController()),
  ChangeNotifierProvider(create: (_) => ClientAuthProvider()),
  ChangeNotifierProvider(create: (_) => AuthSessionController.instance),
  ChangeNotifierProvider(create: (_) => AddressVerificationController()),
  ChangeNotifierProvider(create: (_) => ClientDetailsController()),
  ChangeNotifierProvider(create: (_) => AddressCreationController()),
  ChangeNotifierProvider(create: (_) => DefAddController()),
  ChangeNotifierProvider(create: (_) => ServiceProviderByEmailController()),
  ChangeNotifierProvider(create: (_) => AddressController()),
  ChangeNotifierProvider(
  create: (_) => NegotiationRealtimeController(),
),
  ChangeNotifierProvider(create: (_) => SpAddressController()),
  ChangeNotifierProvider(create: (_) => ShipmentCancelController()),
  ChangeNotifierProvider(create: (_) => ServiceController()..fetchServices()),
  ChangeNotifierProvider(create: (_) => ServiceProviderController()),
  ChangeNotifierProvider(create: (_) => CancelOrderController()),
  ChangeNotifierProvider(create: (_) => ClientPendingOrdersController()),
  ChangeNotifierProvider(create: (_) => ClientPendingOrdersDetailCtrl()),
  ChangeNotifierProvider(create: (_) => ClientProfileController()),
  ChangeNotifierProvider(create: (_) => SpProfileController()),
  ChangeNotifierProvider(create: (_) => NegotiationByIdController()),
  ChangeNotifierProvider(create: (_) => NegotationByOrderIDController()),
  ChangeNotifierProvider(create: (_) => LocationController()),
  ChangeNotifierProvider(create: (_) => PatchOrderFinalPriceController()),
  ChangeNotifierProvider(create: (_) => LocationPermissionCtrl()),
  ChangeNotifierProvider(create: (_) => CostOfServiceImageController()),
  ChangeNotifierProvider(create: (_) => UpdateOrderServiceController()),
  ChangeNotifierProvider(
      create: (_) => BookingController()),
  ChangeNotifierProvider(create: (_) => ServiceProviderByEmailController()),
  ChangeNotifierProvider(create: (_) => SpAddressControllerByID()),
  
  ChangeNotifierProvider(create: (_) => SPByAddressController()),
  ChangeNotifierProvider(create: (_) => PatchDefaultAddressController()),
  ChangeNotifierProvider(create: (_) => ClientRatingsController()),
  ChangeNotifierProvider(create: (_) => NegotiatedPriceController()),
  ChangeNotifierProvider(create: (_) => ClientStartRoundController()),
ChangeNotifierProvider<DefAddController>(
  create: (_) => DefAddController(),
  child: MultiProvider(
    providers: [
      ChangeNotifierProvider<SPByAddressController>(
        create: (_) => SPByAddressController(),
      ),
     
      ChangeNotifierProvider<ServiceController>(
        create: (_) => ServiceController(),
      ),

      
      // HomeRefreshController depends on SPByAddressController + HereMapMarkerController + DefAddController
      ChangeNotifierProxyProvider2<SPByAddressController,GoogleMapMarkerController, HomeRefreshController>(
        create: (context) => HomeRefreshController(
          googleMapMarkerController: context.read<GoogleMapMarkerController>(),
          defAddController: context.read<DefAddController>(),
          spByAddressController: context.read<SPByAddressController>(),
          authSessionController: AuthSessionController.instance,
          
          serviceController: context.read<ServiceController>(),
        ),
        update: (context, spCtrl, mapCtrl, homeCtrl, ) {
          return HomeRefreshController(
            googleMapMarkerController: context.read<GoogleMapMarkerController>(),
            defAddController: context.read<DefAddController>(), 
            spByAddressController: spCtrl,
            authSessionController: AuthSessionController.instance,
            
            serviceController: context.read<ServiceController>(),
          );
        },
      ),
    ],
  ),
),
  ChangeNotifierProvider(create: (_) => ShipmentController()),
  ChangeNotifierProvider(create: (_) => GoogleMapMarkerController(
defAddCtrl: DefAddController(),
spAddrCtrl: SpAddressControllerByID()

  )),
  ChangeNotifierProvider(create: (_) => RejectNegotiationController()),
  ChangeNotifierProvider(create: (_) => AddressACreationController()),
  ChangeNotifierProvider(create: (_) => SPRatingController()),
  ChangeNotifierProvider(create: (_) => AddressClientCtrl()),
  ChangeNotifierProvider(create: (_) => ShipmentConfirmController()),
  ChangeNotifierProvider(create: (_) => ClientCheckinController()),
  ChangeNotifierProvider(create: (_) => SessionByShipmentController()),
  ChangeNotifierProvider(create: (_) => ClientSessionLocationPingController()),
  ChangeNotifierProvider(create: (_) => ClientProfileUpdateController ()),
  ChangeNotifierProvider(create: (_) => RatingController()),
];
