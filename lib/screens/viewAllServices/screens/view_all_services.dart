import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';
import 'package:flutter_application_1/screens/viewAllServices/widgets/services_list.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/utils/kstrings.dart';
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
  late final FocusNode _searchFocusNode; // 1. Declare FocusNode
  Timer? _debounce;
  late ServiceController _serviceController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(); // 2. Initialize FocusNode

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceController>().fetchServices();
    });

    

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  _serviceController = context.read<ServiceController>();
}

  void _onSearchChanged(String query) {
    if (kDebugMode) {
      print(">>> 1. TextField onChanged triggered with query: '$query'");
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (kDebugMode) {
        print(">>> 2. Debounce finished. Calling filterServices...");
      }
      context.read<ServiceController>().filterServices(query);
    });
  }

  @override
void dispose() {
  _debounce?.cancel();
 
  _controller.dispose();
  _searchController.dispose();
  _searchFocusNode.dispose();
  super.dispose();
}

  void _toggleSearch() {
    setState(() {
      _showSearchBox = !_showSearchBox;
      if (_showSearchBox) {
        _controller.forward();
        // 4. Force focus into the TextField so typing works immediately!
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocusNode.requestFocus();
        });
      } else {
        _controller.reverse();
         _serviceController.clearSearch();
        _searchFocusNode.unfocus();
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            SizeTransition(
              sizeFactor: _controller,
              axisAlignment: -1.0,
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
                      focusNode: _searchFocusNode, // 5. Attach the FocusNode
                      autofocus: false,            // 6. Backup autofocus flag
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search services or keywords...',
                        border: InputBorder.none,
                        icon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchFocusNode.unfocus();
                            _searchController.clear();
                            context.read<ServiceController>().clearSearch();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: Kolors.kPrimary,
                backgroundColor: Colors.white,
                onRefresh: () => serviceController.refresh(),
                child: const ServicesListWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}