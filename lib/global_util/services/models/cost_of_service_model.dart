import 'service_provider_model.dart';
import 'services_model.dart';

class CostOfServiceModel {
  final int? id;

  final double? basePrice;
 
  final String? notes;

  CostOfServiceModel({
    this.id,

    this.basePrice,
  
    this.notes,
  });

  factory CostOfServiceModel.fromJson(Map<String, dynamic> json) {
    return CostOfServiceModel(
      id: json['id'],

      basePrice: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString())
          : null,
     
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'base_price': basePrice,
    
      'notes': notes,
    };
  }
}
