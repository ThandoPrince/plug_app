import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/global_util/services/models/services_model.dart';


class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<ServiceModel>> fetchServicesWithUsers() async {
    final response = await supabase
        .from('services')
        .select('id, title, users(id, name, service_id)');

    if (response == Null) {
      throw Exception("No response from Supabase");
    }

    final List data = response as List;

    return data.map<ServiceModel>((json) => ServiceModel.fromJson(json)).toList();
  }
}
