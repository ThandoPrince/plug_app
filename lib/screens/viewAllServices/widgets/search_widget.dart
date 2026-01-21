import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Unfocus keyboard right after the widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusScope.of(context).unfocus();
  });
}

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      Provider.of<ServiceController>(context, listen: false).filterServices(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showFloatingSearch && !widget.showFloatingSearch) {
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ServiceController>(context);

    return Stack(
      children: [
        // Body with fade/slide animation
        AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(top: widget.showFloatingSearch ? 80 : 0),
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final offsetAnim = Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offsetAnim, child: child),
                    );
                  },
                  child: controller.isLoading
                      ? const Center(
                          key: ValueKey('loading'),
                          child: CircularProgressIndicator(),
                        )
                      : controller.error != null
                          ? Center(
                              key: const ValueKey('error'),
                              child: Text('Error: ${controller.error}'),
                            )
                          : controller.filteredServices.isEmpty
                              ? const Center(
                                  key: ValueKey('empty'),
                                  child: Text('No services found.'),
                                )
                              : ListView.builder(
                                  key: const ValueKey('list'),
                                  itemCount: controller.filteredServices.length,
                                  itemBuilder: (context, index) {
                                    final service = controller.filteredServices[index];
                                    return ListTile(
                                      title: Text(
                                        service.serviceName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Available: ${service.providerCount ?? 0}',
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                      onTap: () {
                                        _hideKeyboard();
                                        // Optional: Navigate or trigger action
                                      },
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),

        // Floating search box on top
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: widget.showFloatingSearch ? 0 : -80,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black.withOpacity(0.7),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Kolors.kOffWhite.withOpacity(0.1),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _hideKeyboard(),
            ),
          ),
        ),
      ],
    );
  }
}
