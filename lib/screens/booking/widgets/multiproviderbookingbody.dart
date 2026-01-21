// multiproviderbookingbody.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/flushbar_service.dart';
import 'package:flutter_application_1/global_util/services/models/client_models/address_client_model.dart';
import 'package:flutter_application_1/global_util/services/models/cost_of_service_model.dart';
import 'package:flutter_application_1/global_util/services/models/service_provider_model.dart';
import 'package:flutter_application_1/screens/location/views/location_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:intl/intl.dart'; 

class MultiProviderBookingBody extends StatefulWidget {
  final Future<bool> Function({required bool isCamera}) handlePermission;
  final List<ServiceProviderModel> selectedProviders;
  final List<CostOfServiceModel> selectedCosts;
  final int serviceId;
  final TextEditingController negotiatedPriceController;
  final TextEditingController notesController;
  final TextEditingController titleController;
  final DateTime? selectedDate;
  final Function(List<File>) onImagesChanged;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onSubmitBooking;
  final AddressClientModel? defaultAddress;

  const MultiProviderBookingBody({
    super.key,
    required this.handlePermission,
    required this.titleController,
    required this.onImagesChanged,
    required this.selectedProviders,
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
  });

  @override
  State<MultiProviderBookingBody> createState() =>
      _MultiProviderBookingBodyState();
}

class _MultiProviderBookingBodyState extends State<MultiProviderBookingBody> {
  final List<File> _selectedImages = [];

 
 
  final Color hintColor = Colors.grey.shade500;
  final Color borderColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onImagesChanged(_selectedImages);
    });
  }

  double? get averagePrice {
    final relevantCosts = widget.selectedCosts
        .where((c) =>
            c.service.serviceId == widget.serviceId && c.basePrice != null)
        .toList();
    if (relevantCosts.isEmpty) return null;
    final totalBasePrice = relevantCosts.fold<double>(
        0, (sum, cost) => sum + (cost.basePrice ?? 0));
    return totalBasePrice / relevantCosts.length;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      FlushbarService.error(
          context, 'You can only upload up to 5 images.');
      return;
    }

    bool granted =
        await widget.handlePermission(isCamera: source == ImageSource.camera);
    if (!granted) {
      FlushbarService.error(
          context, 'Permission denied. Cannot access ${source == ImageSource.camera ? 'camera' : 'gallery'}.');
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

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

  

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color:
              color ?? Kolors.kDark, // Use provided color or default to primary
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Kolors.kDark),
      floatingLabelStyle:
          TextStyle(color: Kolors.kDark, fontWeight: FontWeight.bold),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Kolors.kDark, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // -----------------------------------------------

  @override
  Widget build(BuildContext context) {
    final providerCount = widget.selectedProviders.length;
    final relevantCosts = widget.selectedCosts
        .where((c) =>
            c.service.serviceId == widget.serviceId && c.basePrice != null)
        .toList();
    final firstProviderCost =
        relevantCosts.isNotEmpty ? relevantCosts.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title input
          _buildSectionTitle(
            "Booking Title",
          ),
          TextField(
            controller: widget.titleController,
            decoration: _buildInputDecoration(
              label: "Title",
              hint: "i.e. Fix my kitchen sink",
            ),
          ),
          const SizedBox(height: 20),

          // Date & Time Pickers
          _buildSectionTitle("Required Date and Time"),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.onPickDate,
                  child: InputDecorator(
                    decoration:
                        _buildInputDecoration(label: '').copyWith(
                      prefixIcon: Icon(Icons.calendar_today,
                          color: Kolors.kDark.withOpacity(0.7)),
                    ),
                    child: Text(
                        widget.selectedDate != null
                            ? DateFormat('dd MMM yyyy')
                                .format(widget.selectedDate!)
                            : 'Pick Date',
                        style: TextStyle(
                            color: widget.selectedDate != null
                                ? Colors.black
                                : hintColor)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: widget.onPickTime,
                  child: InputDecorator(
                    decoration:
                        _buildInputDecoration(label: '').copyWith(
                      labelStyle: const TextStyle(
                          color: Kolors.kDark), // <-- set label color
                      prefixIcon: Icon(
                        Icons.access_time,
                        color: Kolors.kDark.withOpacity(0.7),
                      ),
                    ),
                    child: Text(
                      widget.selectedTime != null
                          ? widget.selectedTime!.format(context)
                          : 'Pick Time',
                      style: TextStyle(
                        color: widget.selectedTime != null
                            ? Colors.black
                            : hintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Providers List
          _buildSectionTitle("Potential Service Providers ($providerCount)"),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, // Changed to white as per request
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            height: providerCount > 0
                ? (providerCount > 3 ? 3 : providerCount) * 55.0 + 10
                : 50.0,
            child: providerCount == 0
                ? Center(
                    child: Text("No providers selected.",
                        style: TextStyle(color: hintColor)),
                  )
                : ListView.builder(
                    itemCount: providerCount,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.person_pin, size: 20, color: Kolors.kDark),
                          const SizedBox(width: 8),
                          Text(
                            widget.selectedProviders[i].fullName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Delivery address
          if (widget.defaultAddress != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Delivery Address"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Changed to white as per request
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    widget.defaultAddress!.address.formattedAddress ??
                        'Address not available',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LocationScreen()),
                      );

                    }, 
                    icon: const Icon(Icons.edit_location_alt, size: 18),
                    label: const Text("Change Address"),
                    style: TextButton.styleFrom(foregroundColor: Kolors.kDark),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          
          if (averagePrice != null ||
              (firstProviderCost != null && firstProviderCost.negotiable))
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Kolors.kPrimary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (averagePrice != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Indicative Price: R ${averagePrice!.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Kolors.kDark,
                          ),
                        ),
                      ),
                    
                    if (firstProviderCost != null &&
                        firstProviderCost.negotiable)
                      TextField(
                        controller: widget.negotiatedPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            _buildInputDecoration(label: "Propose your price")
                                .copyWith(
                          prefixText: "R ",
                          prefixStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Notes
          _buildSectionTitle("Additional Notes / Description"),
          TextField(
            controller: widget.notesController,
            decoration:
                _buildInputDecoration(label: "Notes on the service required"),
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // Images
          _buildSectionTitle("Upload Photos (max 5)"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, size: 30),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    color: Kolors.kDark,
                    tooltip: 'Gallery',
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 30),
                    onPressed: () => _pickImage(ImageSource.camera),
                    color: Kolors.kDark,
                    tooltip: 'Camera',
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: _selectedImages.isEmpty
                      ? Center(
                          child: Text("Please add images regarding the service you require.",
                              style: TextStyle(color: hintColor)),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_selectedImages[i],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(i),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red.shade600,
                                      child: const Icon(Icons.close,
                                          size: 14, color: Colors.white),
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
          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: widget.onSubmitBooking,
              icon: const Icon(Icons.send),
              label: const Text(
                "Send Booking Requests",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Kolors.kPrimary,
                foregroundColor: Kolors.kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
