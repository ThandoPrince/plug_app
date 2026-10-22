import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/controler/auth_session_controller.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:flutter_application_1/screens/sp_profile/views%20copy/viewSP_Profile_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MultiProviderBookingBody extends StatefulWidget {
  final Future<bool> Function({required bool isCamera}) handlePermission;
  final List<ServiceProviderModel> selectedProviders;
  final List<CostOfServiceModel> selectedCosts;
  final int serviceId;
  final TextEditingController negotiatedPriceController;
  final TextEditingController notesController;
  final void Function(int index) onRemoveProvider;
  final TextEditingController titleController;
  final DateTime? selectedDate;
  final Function(List<File>) onImagesChanged;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final bool isSubmitting;
  final VoidCallback onPickTime;
  final VoidCallback onSubmitBooking;
  final AddressClientModel? defaultAddress;

  const MultiProviderBookingBody({
    super.key,
    required this.handlePermission,
    required this.titleController,
    required this.onImagesChanged,
    required this.selectedProviders,
    required this.isSubmitting,
    required this.selectedCosts,
    required this.serviceId,
    required this.negotiatedPriceController,
    required this.notesController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSubmitBooking,
    required this.defaultAddress,
    required this.onRemoveProvider,
  });

  @override
  State<MultiProviderBookingBody> createState() =>
      _MultiProviderBookingBodyState();
}

class _MultiProviderBookingBodyState extends State<MultiProviderBookingBody> {
  final List<File> _selectedImages = [];
  final Color hintColor = Colors.grey.shade400;
  final Color borderColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onImagesChanged(_selectedImages);
    });
  }

  double? get averagePrice {
    final relevantCosts = widget.selectedCosts
        .where((cost) => cost.basePrice != null)
        .toList();

    if (relevantCosts.isEmpty) return null;

    final totalBasePrice = relevantCosts.fold<double>(
      0,
      (sum, cost) => sum + (cost.basePrice ?? 0),
    );

    final avg = totalBasePrice / relevantCosts.length;
    return double.parse(avg.toStringAsFixed(2));
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      FlushbarService.error(context, 'You can only upload up to 5 images.');
      return;
    }

    final granted =
        await widget.handlePermission(isCamera: source == ImageSource.camera);

    if (!granted) {
      FlushbarService.error(
        context,
        'Permission denied. Cannot access ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
      widget.onImagesChanged(_selectedImages);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesChanged(_selectedImages);
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _openProviderDetails(ServiceProviderModel provider) {
    final providerEmail = provider.spProfile?.id;

    if (providerEmail == null) {
      FlushbarService.error(
        context,
        "This provider does not have a valid email address.",
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceProviderScreen(
          id: providerEmail,
          serviceId: widget.serviceId,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
          color: color ?? Kolors.kDark.withOpacity(0.85),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Kolors.kDark.withOpacity(0.6), fontSize: 14),
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: Kolors.kPrimary,
        fontWeight: FontWeight.w600,
      ),
      fillColor: const Color(0xFFF9FAFB),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Kolors.kPrimary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerCount = widget.selectedProviders.length;
    final relevantCosts =
        widget.selectedCosts.where((c) => c.basePrice != null).toList();
    final firstProviderCost =
        relevantCosts.isNotEmpty ? relevantCosts.first : null;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Booking Title"),
            TextField(
              controller: widget.titleController,
              style: const TextStyle(fontSize: 15, color: Kolors.kDark),
              decoration: _buildInputDecoration(
                label: "Title",
                hint: "i.e. Fix my kitchen sink",
              ),
            ),
            const SizedBox(height: 12),

            _buildSectionTitle("Required Date & Time"),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _dismissKeyboard();
                      widget.onPickDate();
                    },
                    child: InputDecorator(
                      decoration: _buildInputDecoration(label: '').copyWith(
                        prefixIcon: const Icon(
                          Icons.calendar_today_rounded,
                          color: Kolors.kPrimary,
                          size: 18,
                        ),
                      ),
                      child: Text(
                        widget.selectedDate != null
                            ? DateFormat('dd MMM yyyy').format(widget.selectedDate!)
                            : 'Pick Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: widget.selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                          color: widget.selectedDate != null ? Kolors.kDark : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _dismissKeyboard();
                      widget.onPickTime();
                    },
                    child: InputDecorator(
                      decoration: _buildInputDecoration(label: '').copyWith(
                        prefixIcon: const Icon(
                          Icons.access_time_rounded,
                          color: Kolors.kPrimary,
                          size: 18,
                        ),
                      ),
                      child: Text(
                        widget.selectedTime != null
                            ? widget.selectedTime!.format(context)
                            : 'Pick Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: widget.selectedTime != null ? FontWeight.w500 : FontWeight.normal,
                          color: widget.selectedTime != null ? Kolors.kDark : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildSectionTitle("Selected Service Providers ($providerCount)"),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              height: providerCount > 0
                  ? (providerCount > 3 ? 3.2 : providerCount) * 64.0 + 8
                  : 70.0,
              child: providerCount == 0
                  ? Center(
                      child: Text(
                        "No providers selected.",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: providerCount,
                      itemBuilder: (_, i) {
                        final provider = widget.selectedProviders[i];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            elevation: 0.5,
                            shadowColor: Colors.black12,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: widget.isSubmitting
                                  ? null
                                  : () => _openProviderDetails(provider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Kolors.kPrimary.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        size: 16,
                                        color: Kolors.kPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider.fullName.toString().toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Kolors.kDark,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "Tap to view profile details",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      onPressed: widget.isSubmitting
                                          ? null
                                          : () => widget.onRemoveProvider(i),
                                      icon: Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                      tooltip: "Remove provider",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Kolors.kPrimary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Kolors.kPrimary.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (averagePrice != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Indicative Price",
                              style: TextStyle(color: Kolors.kDark.withOpacity(0.6), fontSize: 14),
                            ),
                            Text(
                              "R ${averagePrice!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Kolors.kPrimary,
                              ),
                            ),
                          ],
                        ),
                      
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                        ),
                     
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: TextField(
                            controller: widget.negotiatedPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Kolors.kDark),
                            decoration: _buildInputDecoration(
                              label: "Propose your price",
                            ).copyWith(
                              prefixText: "R ",
                              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Kolors.kDark),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            _buildSectionTitle("Additional Notes / Description"),
            TextField(
              controller: widget.notesController,
              style: const TextStyle(fontSize: 14, color: Kolors.kDark),
              decoration: _buildInputDecoration(
                label: "Notes on the service required",
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            _buildSectionTitle("Upload Photos (Max 5)"),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _buildIconButton(
                      icon: Icons.photo_library_rounded,
                      tooltip: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(height: 10),
                    _buildIconButton(
                      icon: Icons.camera_alt_rounded,
                      tooltip: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 94,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Please add images regarding\nthe service you require.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, height: 1.3),
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(8),
                            itemCount: _selectedImages.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[i],
                                      width: 78,
                                      height: 78,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(i),
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red.shade600,
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.isSubmitting || widget.selectedProviders.isEmpty
                    ? null
                    : widget.onSubmitBooking,
                icon: widget.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  widget.isSubmitting
                      ? "Submitting Requests..."
                      : widget.selectedProviders.isEmpty
                          ? "Select at least one provider"
                          : "Send Booking Requests",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Kolors.kWhite,
                  disabledBackgroundColor: Kolors.kPrimary.withOpacity(0.55),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: Kolors.kPrimary.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: Kolors.kPrimary),
        ),
      ),
    );
  }
}