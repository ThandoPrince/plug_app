import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/viewAllServices/widgets/services_list.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/utils/kstrings.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/common/widgets/shimmers/custom_back_button.dart';
import 'package:provider/provider.dart';

class ViewAllServices extends StatefulWidget {
  const ViewAllServices({super.key});

  @override
  State<ViewAllServices> createState() => _ViewAllServicesState();
}

class _ViewAllServicesState extends State<ViewAllServices> with SingleTickerProviderStateMixin {
  bool _showSearchBox = false;
  late final AnimationController _controller;
  late final TextEditingController _searchController;

  @override
void initState() {
  super.initState();

  _searchController = TextEditingController();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ServiceController>().fetchServices();
  });

  _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
}
  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearchBox = !_showSearchBox;
      if (_showSearchBox) {
        _controller.forward();
      } else {
        _controller.reverse();
        FocusScope.of(context).unfocus(); // Hide keyboard
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceController = Provider.of<ServiceController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Kolors.kPrimary,
        elevation: 0,
        centerTitle: false,
        leading: const CustomBackButton(),
        title: ReusableText(
          text: AppText.kServices,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Kolors.kOffWhite,
            onPressed: _toggleSearch,
          )
        ],
      ),
      body: Container(
         decoration: const BoxDecoration(
    gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
  ),
        child: Column(
          children: [
            // Search box with animated expand/collapse height
            SizeTransition(
              sizeFactor: _controller,
              axisAlignment: -1.0, // Expand/collapse from top
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: serviceController.filterServices,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        border: InputBorder.none,
                        icon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            FocusScope.of(context).unfocus();  // hide keyboard
                            _searchController.clear();          // clear input
                            serviceController.filterServices(''); // clear filter
                          },
                        ),
                      ),
                      autofocus: false,
                    ),
                  ),
                ),
              ),
            ),
        
            // Expanded services list below search box
            const Expanded(
              child: ServicesListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}