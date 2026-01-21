import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/cost_of_service_byemail_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/sp_by_email_controller.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/cost_of_service_detail.dart';
import 'package:flutter_application_1/screens/View_SP_Profile_Request/widgets/spdetailsbody.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';
import 'package:provider/provider.dart';



class ServiceProviderDetailsScreen extends StatefulWidget {
  final String email;
  final int serviceId;

  const ServiceProviderDetailsScreen({
    super.key,
    required this.email,
    required this.serviceId,
  });

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  


  late final ServiceProviderByEmailController spController;
  late final CostOfServiceByemailController costController;

  ServiceProviderModel? loadedProvider;

  @override
  void initState() {
    super.initState();

    spController = ServiceProviderByEmailController();
    costController = CostOfServiceByemailController();

    spController.fetchProviderByEmail(widget.email).then((_) {
      setState(() {
        loadedProvider = spController.provider;
      });
    });

    costController.fetchCostOfServiceByEmail(widget.email);
  }

  @override
  void dispose() {
    spController.dispose();
    costController.dispose();
    super.dispose();
  }

  void _goToBooking(BuildContext context) {
    if (loadedProvider == null) {
      FlushbarService.error(
          context, "Provider data is not loaded yet. Please wait.");
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProviderBookingScreen(
          selectedProviders: [loadedProvider!],
          selectedCosts: costController.costs,
          serviceId: widget.serviceId, // Pass serviceId here!
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServiceProviderByEmailController>.value(
            value: spController),
        ChangeNotifierProvider<CostOfServiceByemailController>.value(
            value: costController),
      ],
      child: Scaffold(
        // 🌟 Apply secondary color to the screen body background
        
        appBar: AppBar(
          backgroundColor: Kolors.kPrimary,
         
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Service Provider Details",
           
            style: TextStyle(fontSize: 16,color: Kolors.kOffWhite, ), 
          ), 
        ),
        body: Container(
           decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Kolors.kPrimary, Kolors.kOffWhite], // light orange to darker orange
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // We'll update SPDetailsBody to use primary/secondary colors too
                SPDetailsBody(email: widget.email), 
                const SizedBox(height: 16),
                Consumer<CostOfServiceByemailController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                    
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.error != null) {
                      return Text("Error loading cost: ${controller.error}");
                    } else {
                      return CostOfServiceCard(
                        costs: controller.costs,
                        serviceId: widget.serviceId,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _goToBooking(context),
          tooltip: 'Book Selected Provider',
          backgroundColor: Kolors.kPrimary,
          
          child: const Icon(Icons.add_sharp, color: Colors.white), 
        ),
      ),
    );
  }
}