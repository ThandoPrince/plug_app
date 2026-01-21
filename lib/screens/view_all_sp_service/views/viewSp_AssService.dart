import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/screens/booking/views/MultiProviderBookingScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/const/services/sp_api.dart';
import 'package:flutter_application_1/const/services/cost_of_servicebyemail_api.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/view_all_sp_service/widgets/viewSpService.dart';

class ServiceProvidersByServiceScreen extends StatefulWidget {
  final int serviceId;
  final String serviceName;

  const ServiceProvidersByServiceScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<ServiceProvidersByServiceScreen> createState() =>
      _ServiceProvidersByServiceScreenState();
}

class _ServiceProvidersByServiceScreenState
    extends State<ServiceProvidersByServiceScreen>
    with SingleTickerProviderStateMixin {

  static const Color primaryColor = Kolors.kPrimary;

  late Future<List<ServiceProviderModel>> _futureProviders;
  late AnimationController _searchAnimController;
  late TextEditingController _searchController;

  bool _showSearchBox = false;

  List<ServiceProviderModel> _allProviders = [];
  List<ServiceProviderModel> _filteredProviders = [];
  List<ServiceProviderModel> _selectedProviders = [];

  bool _isLoadingCosts = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _futureProviders =
        ServiceProviderApi.fetchAllServiceProviders(widget.serviceId);
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ================= SEARCH =================
  void _toggleSearch() {
    setState(() {
      _showSearchBox = !_showSearchBox;

      if (_showSearchBox) {
        _searchAnimController.forward();
      } else {
        _searchAnimController.reverse();
        _searchController.clear();
        _filteredProviders = _allProviders;
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _filterProviders(String query) {
    final q = query.toLowerCase();

    setState(() {
      _filteredProviders = _allProviders.where((provider) {
        final name = provider.fullName.toLowerCase();
        final email =
            provider.spProfile.emailAddress.toLowerCase() ?? '';
        return name.contains(q) || email.contains(q);
      }).toList();
    });
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.serviceName,
          style: appStyle(16, Kolors.kOffWhite, FontWeight.w700),
        ),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.search, color: Kolors.kOffWhite),
            onPressed: _toggleSearch,
          ),
        ],
      ),

      // ---------- BODY ----------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Kolors.kPrimary, Colors.white],
          ),
        ),
        child: Column(
          children: [

            // 🔍 SEARCH BAR (Animated)
            SizeTransition(
              sizeFactor: _searchAnimController,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterProviders,
                      decoration: InputDecoration(
                        hintText: 'Search providers...',
                        border: InputBorder.none,
                        icon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _toggleSearch,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 📋 PROVIDER LIST
            Expanded(child: _buildProvidersList()),
          ],
        ),
      ),

      // ---------- FAB ----------
      floatingActionButton: _isLoadingCosts
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: primaryColor.withOpacity(.7),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: _onBookingButtonPressed,
              child: const Icon(Icons.add_sharp, color: Colors.white),
            ),
    );
  }

  // ================= PROVIDERS =================
  Widget _buildProvidersList() {
    return FutureBuilder<List<ServiceProviderModel>>(
      future: _futureProviders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Kolors.kDark),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load providers"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No providers found"));
        }

        // cache once
        if (_allProviders.isEmpty) {
          _allProviders = snapshot.data!;
          _filteredProviders = _allProviders;
        }

        return ProviderListWidget(
          providers: _filteredProviders,
          onSelectionChanged: (selected) {
            _selectedProviders = selected;
          },
          onProviderTap: _onProviderTap,
        );
      },
    );
  }

  // ================= ACTIONS =================
  void _onProviderTap(ServiceProviderModel provider) {
    context.pushNamed(
      'providerDetails',
      pathParameters: {'email': provider.spProfile.emailAddress},
      queryParameters: {'serviceId': widget.serviceId.toString()},
    );
  }

  Future<void> _onBookingButtonPressed() async {
    if (_selectedProviders.isEmpty) {
      FlushbarService.error(
        context,
        "Please select at least one provider.",
        position: FlushbarPosition.TOP,
      );
      return;
    }

    setState(() => _isLoadingCosts = true);

    try {
      final emails = _selectedProviders
          .map((p) => p.spProfile.emailAddress)
          .toList();

      final costs =
          await CostOfServiceByEmailApi.fetchCostsByEmails(emails);

      setState(() => _isLoadingCosts = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiProviderBookingScreen(
            selectedProviders: _selectedProviders,
            selectedCosts: costs,
            serviceId: widget.serviceId,
          ),
        ),
      );
    } catch (_) {
      setState(() => _isLoadingCosts = false);
      FlushbarService.error(
        context,
        "Failed to load provider costs.",
        position: FlushbarPosition.TOP,
      );
    }
  }
}
