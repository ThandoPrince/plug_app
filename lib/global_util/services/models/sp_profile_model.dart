

// List<SPProfileModel> spProfileModelFromJson(String str) =>
//     List<SPProfileModel>.from(json.decode(str).map((x) => SPProfileModel.fromJson(x)));

// String spProfileModelToJson(List<SPProfileModel> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SPProfileModel {
  final String emailAddress;
  int? id;


  SPProfileModel({
    required this.emailAddress,
    this.id,

  });

  factory SPProfileModel.fromJson(Map<String, dynamic> json) {
    return SPProfileModel(
      emailAddress: json['email_address'],
      id: json['id'],

    );
  }

  Map<String, dynamic> toJson() => {
        'email_address': emailAddress,
        'id': id,

      };
}
