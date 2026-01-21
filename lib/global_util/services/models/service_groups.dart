

class ServiceGroupModel {
  final String groupId;
  final String name;

  ServiceGroupModel({
    required this.groupId,
    required this.name,
  });

  factory ServiceGroupModel.fromJson(Map<String, dynamic> json) => ServiceGroupModel(
        groupId: json["group_id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "name": name,
      };
}



