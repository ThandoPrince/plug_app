import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/service_controller.dart';

class SearchWidget extends StatefulWidget {
  final bool showFloatingSearch;
  final VoidCallback onClose;

  const SearchWidget({
    super.key,
    required this.showFloatingSearch,
    required this.onClose,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  void _onSearchChanged(String query) {
    if (kDebugMode) {
      print(">>> 1. TextField onChanged triggered with query: '$query'");
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        if (kDebugMode) {
          print(">>> 2. Widget not mounted, aborting search.");
        }
        return;
      }
      if (kDebugMode) {
        print(">>> 2. Debounce finished. Calling filterServices...");
      }
      context.read<ServiceController>().filterServices(query);
    });
  }

  void _closeAndClear() {
  _searchController.clear();
  context.read<ServiceController>().clearSearch();
  _hideKeyboard();
  widget.onClose();
}

@override
void didUpdateWidget(covariant SearchWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.showFloatingSearch && !widget.showFloatingSearch) {
    _searchController.clear();
    context.read<ServiceController>().clearSearch();
  }
}

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ServiceController>();

    return Stack(
      children: [
        // Results area
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(top: widget.showFloatingSearch ? 80 : 0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _buildBody(controller),
          ),
        ),

        // Floating search bar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          top: widget.showFloatingSearch ? 0 : -90,
          left: 0,
          right: 0,
          height: 80,
          child: Material(
            elevation: 8,
            color: Colors.black.withOpacity(0.75),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Kolors.kPrimary,
                  decoration: InputDecoration(
                    hintText: 'Search services or keywords...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: _closeAndClear,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Kolors.kPrimary, width: 1.5),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _hideKeyboard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ServiceController controller) {
    if (controller.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: Kolors.kPrimary),
      );
    }

    if (controller.error != null) {
      return Center(
        key: const ValueKey('error'),
        child: Text(
          'Error: ${controller.error}',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (controller.filteredServices.isEmpty) {
      return const Center(
        key: ValueKey('empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.white54),
            SizedBox(height: 12),
            Text(
              'No services found',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: controller.filteredServices.length,
      itemBuilder: (context, index) {
        final service = controller.filteredServices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Kolors.kOffWhite, Kolors.kOffWhite],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              title: Text(
                service.serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Kolors.kDark,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Active: ${service.activeProviderCount ?? service.providerCount ?? 0}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Kolors.kDark,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Kolors.kDark),
              onTap: () {
                _hideKeyboard();
                context.pushNamed(
                  'viewSPByService',
                  queryParameters: {
                    'serviceId': service.serviceId.toString(),
                    'serviceName': service.serviceName,
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}