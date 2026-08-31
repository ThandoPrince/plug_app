import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/shimmers/household_members_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/global_util/services/controler/household_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/super_user_deactivate_address_controller.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';

class HouseholdMembersView extends StatefulWidget {
  final int clientAddressId;

  const HouseholdMembersView({
    super.key,
    required this.clientAddressId,
  });

  @override
  State<HouseholdMembersView> createState() => _HouseholdMembersViewState();
}

class _HouseholdMembersViewState extends State<HouseholdMembersView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<HouseholdController>()
          .fetchHouseholdMembers(widget.clientAddressId);
    });
  }

  void _openFullScreenPhoto(BuildContext context, String imageUrl, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenPhotoView(imageUrl: imageUrl, heroTag: heroTag),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, String memberName, int memberAddressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Deactivate Member",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to deactivate ${memberName.isEmpty ? 'this member' : memberName}'s access to this address?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientBtn(
                  text: "YES, DEACTIVATE",
                  btnColor: Colors.red,
                  textColor: Colors.white,
                  btnHieght: 50,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () => Navigator.of(dialogContext).pop(true),
                ),
                const SizedBox(height: 10),
                GradientBtn(
                  text: "CANCEL",
                  btnColor: Kolors.kPrimary,
                  textColor: Colors.white,
                  btnHieght: 50,
                  btnWidth: double.infinity,
                  radius: 12,
                  onTap: () => Navigator.of(dialogContext).pop(false),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final deactivateCtrl = context.read<SuperUserDeactivateAddressController>();
    final success = await deactivateCtrl.deactivateAddress(context, memberAddressId);

    // deactivateAddress already shows its own success/error Flushbar.
    if (!success || !context.mounted) return;

    await context.read<HouseholdController>().fetchHouseholdMembers(widget.clientAddressId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Household Members",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<HouseholdController>(
            builder: (context, ctrl, child) {
              return _buildBody(ctrl);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(HouseholdController ctrl) {
    if (ctrl.isLoading) {
      return const HouseholdMembersSkeleton();
    }

    if (ctrl.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 40),
              const SizedBox(height: 12),
              Text(
                ctrl.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (ctrl.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: Colors.white.withOpacity(0.7), size: 48),
            const SizedBox(height: 12),
            Text(
              "No household members found.",
              style: TextStyle(color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ctrl.members.length,
      itemBuilder: (context, index) {
        final member = ctrl.members[index];
        final client = member.client;
        final fullName = "${client.firstName ?? ''} ${client.lastName ?? ''}".trim();
        final initials = (client.firstName?.isNotEmpty ?? false)
            ? client.firstName![0].toUpperCase()
            : "?";
        final String? profilePic = client.profilePic;
        final bool hasPhoto = profilePic != null && profilePic.isNotEmpty;
        final heroTag = 'household_member_photo_${member.hashCode}_$index';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: hasPhoto
                      ? () => _openFullScreenPhoto(context, profilePic, heroTag)
                      : null,
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Kolors.kPrimary,
                        border: Border.all(color: Kolors.kPrimary.withOpacity(0.15), width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasPhoto
                          ? Image.network(
                              profilePic,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? "Unnamed member" : fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: member.isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            member.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (member.isOwner) _buildBadge("OWNER", Colors.green),
                        if (member.houseAdministrator) ...[
                          if (member.isOwner) const SizedBox(width: 4),
                          _buildBadge("ADMIN", Colors.orange),
                        ],
                      ],
                    ),
                    // Only active members can be deactivated — no point
                    // showing the menu for someone already inactive.
                    if (member.isActive)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_vert, color: Colors.grey.shade500, size: 20),
                        onSelected: (value) {
                          if (value == 'deactivate') {
                            _confirmDeactivate(context, fullName, member.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'deactivate',
                            child: Text(
                              "Deactivate",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Full-screen photo viewer with pinch-to-zoom and a Hero transition
/// from the avatar. Dismiss by tapping the background or the close
/// button, or via the system back gesture/button.
class _FullScreenPhotoView extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenPhotoView({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 64,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const CircularProgressIndicator(color: Colors.white);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}