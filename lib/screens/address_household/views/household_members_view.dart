import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/controler/household_controller.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class HouseholdMembersView extends StatelessWidget {
  final int clientAddressId;

  const HouseholdMembersView({
    super.key,
    required this.clientAddressId,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HouseholdController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Household Members"),
        backgroundColor: Kolors.kPrimary,
      ),
      body: _buildBody(ctrl),
    );
  }

  Widget _buildBody(HouseholdController ctrl) {
    if (ctrl.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (ctrl.error != null) {
      return Center(
        child: Text(
          ctrl.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (ctrl.members.isEmpty) {
      return const Center(
        child: Text("No household members found."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.members.length,
      itemBuilder: (context, index) {
        final member = ctrl.members[index];

        final client = member.client;
        final membersstatus = member.isActive;
        final address = member.address;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Kolors.kPrimary,
              child: Text(
                (client.firstName!.isNotEmpty) ? client.firstName![0] : "?",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
  "${client.firstName} ${client.lastName}",
  style: const TextStyle(fontWeight: FontWeight.bold),
),

subtitle: Text(
  member.isActive
      ? "Active household member"
      : "Inactive household member",
),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (member.isOwner)
                  const Text(
                    "OWNER",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (member.houseAdministrator)
                  const Text(
                    "ADMIN",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
