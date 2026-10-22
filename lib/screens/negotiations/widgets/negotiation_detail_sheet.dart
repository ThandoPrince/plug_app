import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/shimmers/negotiation_sheet_skeleton.dart';
import 'package:flutter_application_1/global_util/services/controler/client_negotiation_round_start_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_badge_store_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/reject_negociation_controller.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_accepted_view.dart';
import 'package:flutter_application_1/screens/negotiations/widgets/negotiation_controller_cache.dart';
import 'package:flutter_application_1/screens/sp_profile/views%20copy/viewSP_Profile_Screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';

import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_round_model.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_by_negoID_ctrl.dart';

class NegotiationDetailSheet extends StatefulWidget {
  final int negotiationId;
  final BuildContext parentContext;

  const NegotiationDetailSheet({
    super.key,
    required this.negotiationId,
    required this.parentContext,
  });

  @override
  State<NegotiationDetailSheet> createState() => _NegotiationDetailSheetState();
}

class _NegotiationDetailSheetState extends State<NegotiationDetailSheet> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<NegotiationRound> _displayedRounds = [];
  late final NegotiationRealtimeController _realtimeCtrl;

  @override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  NegotiationBadgeStore.global.setActive(widget.negotiationId); // or context.read
NegotiationBadgeStore.global.markRead(widget.negotiationId);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final realtime = context.read<NegotiationRealtimeController>();
    realtime.connect(widget.negotiationId, _handleSocketEvent);
  });
}

NegotiationByIdController get _negoCtrl =>
    NegotiationControllerCache.instance.controllerFor(widget.negotiationId);

void _onScroll() {
  if (!_scrollController.hasClients) return;
  // Reversed list: extentAfter is the older end of the chat.
  if (_scrollController.position.extentAfter < 200) _loadOlder();
}

Future<void> _loadOlder({bool retry = false}) async {
  final added = await _negoCtrl.loadOlderRounds(
    widget.negotiationId,
    retry: retry,
  );
  if (!mounted || added.isEmpty) return;
  _prependOlder(added);
}

void _prependOlder(List<NegotiationRound> older) {
  final shown = {for (final r in _displayedRounds) r.id};
  final fresh = older.where((r) => !shown.contains(r.id)).toList();
  if (fresh.isEmpty) return;

  final oldLen = _displayedRounds.length;
  setState(() => _displayedRounds.insertAll(0, fresh));
  // Older rounds sit at the far (top) end of the reversed list.
  for (var k = 0; k < fresh.length; k++) {
    _listKey.currentState?.insertItem(oldLen + k, duration: Duration.zero);
  }
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _realtimeCtrl = context.read<NegotiationRealtimeController>();
  }

  void _handleSocketEvent(Map<String, dynamic> event) {
  final type = event["type"];

  if (type == "negotiation_counter_offer" ||
      type == "negotiation_round_created") {
    final data = event["data"];
    final roundJson = data["round"];
    if (roundJson == null) return;

    final round = NegotiationRound.fromJson(roundJson);

    context.read<NegotiationByIdController>().applyIncomingRound(round);

    // Merge into the currently-displayed list too, for the live view.
    _mergeServerRounds([round]);
  }
}

  @override
void dispose() {
  NegotiationBadgeStore.global.markRead(widget.negotiationId);
  NegotiationBadgeStore.global.setActive(null);
  _realtimeCtrl.disconnectSilently();
  _scrollController.dispose();
  _messageController.dispose();
  

  _priceController.dispose();
  super.dispose();
}

void _initDisplayed(List<NegotiationRound> rounds) {
  _displayedRounds.addAll(rounds);
}



bool _isSending = false;

void _mergeServerRounds(List<NegotiationRound> serverRounds) {
  for (final serverRound in serverRounds) {
    final alreadyDisplayed = _displayedRounds.any(
      (r) => r.id != null && r.id == serverRound.id,
    );
    if (alreadyDisplayed) continue;

    setState(() {
      _displayedRounds.add(serverRound);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 300),
      );
    });
    _scrollToBottom();
  }
}

  void _scrollToBottom() {
  Future.delayed(const Duration(milliseconds: 100), () {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

  void _showTopNotification(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: isError ? Colors.red : Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 300),
    ).show(widget.parentContext);
  }

  void _openProviderProfile(NegotiationByIdController negotiation) {
    final providerId =
        negotiation.negotiation?.providerForNegotiation?.provider.spProfile?.id;
    final serviceId =
        negotiation.negotiation?.providerForNegotiation?.service.serviceId;

    if (providerId == null || serviceId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceProviderScreen(id: providerId, serviceId: serviceId),
      ),
    );
  }

  void _removeFromNegotiation(
    BuildContext context,
    RejectNegotiationController rejectCtrl,
    int negotiationId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Remove Negotiation",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to remove this negotiation thread?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            children: [
              GradientBtn(
                text: "No, Keep It",
                btnColor: Kolors.kPrimary,
                btnHieght: 50,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
              const SizedBox(height: 10),
              GradientBtn(
                text: "Yes, Remove",
                textColor: Colors.black,
                btnColor: Colors.grey.shade300,
                btnHieght: 50,
                btnWidth: double.infinity,
                radius: 12,
                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  final success = await rejectCtrl.rejectNegotiation(
                    negotiationId: negotiationId,
                  );

                  if (!context.mounted) return;

                  Navigator.of(context).pop({
                    "success": success,
                    "message": rejectCtrl.message,
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

Future<void> _submitRound(
  ClientStartRoundController clientCtrl,
  NegotiationByIdController negoCtrl, {
  required double price,
  String? message,
  bool clearFields = true,
  String successText = "Round sent successfully",
}) async {
  if (_isSending) return;
  setState(() => _isSending = true);

  try {
    final success = await clientCtrl.sendRound(
      negotiationId: widget.negotiationId,
      offeredPrice: price,
      message: message,
    );
    if (!mounted) return;

    if (!success) {
      _showTopNotification(
        clientCtrl.errorMessage ?? "Failed to send round",
        isError: true,
      );
      return;
    }

    if (clearFields) {
      _messageController.clear();
      _priceController.clear();
    }

    await negoCtrl.fetchNegotiationById(widget.negotiationId, force: true);
    if (!mounted) return;
    _mergeServerRounds(negoCtrl.negotiation?.rounds ?? []);

    _showTopNotification(successText);
  } finally {
    if (mounted) setState(() => _isSending = false);
  }
}

Future<void> _sendRound(
  ClientStartRoundController clientCtrl,
  NegotiationByIdController negoCtrl,
) async {
  final price = double.tryParse(_priceController.text.trim());
  if (price == null) {
    _showTopNotification("Please enter a valid price", isError: true);
    return;
  }
  await _submitRound(
    clientCtrl,
    negoCtrl,
    price: price,
    message: _messageController.text.trim(),
  );
}

/// Accept = a round at the provider's last price with the message "Accepted".
Future<void> _acceptProviderPrice(
  ClientStartRoundController clientCtrl,
  NegotiationByIdController negoCtrl,
  double providerPrice,
) async {
  await _submitRound(
    clientCtrl,
    negoCtrl,
    price: providerPrice,
    message: "Accepted",
    clearFields: false,
    successText: "Offer accepted",
  );
}



  Widget _buildRoundBubble(NegotiationRound round, Animation<double> animation) {
  final isClient = round.senderType == "client";

  final bubble = Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    constraints: const BoxConstraints(maxWidth: 250),
    decoration: BoxDecoration(
      color: isClient ? Colors.blue.shade100 : Colors.grey.shade200,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
        bottomLeft: Radius.circular(isClient ? 12 : 0),
        bottomRight: Radius.circular(isClient ? 0 : 12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (round.message != null && round.message!.isNotEmpty)
          Text(round.message!,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'}",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              round.createdAt != null
                  ? DateFormat('HH:mm, dd MMM').format(round.createdAt!.toLocal())
                  : '',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ],
    ),
  );

  return SizeTransition(
    sizeFactor: animation,
    child: Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
       providers: [
    ChangeNotifierProvider.value(
      value: NegotiationControllerCache.instance.controllerFor(widget.negotiationId)
        ..fetchNegotiationById(widget.negotiationId), // no-op if already cached
    ),
    ChangeNotifierProvider(create: (_) => ClientStartRoundController()),
  ],
      child: Consumer2<NegotiationByIdController, ClientStartRoundController>(
        builder: (context, negoCtrl, clientCtrl, _) {
          if (negoCtrl.isLoading) {
  return const NegotiationSheetSkeleton();
}

          if (negoCtrl.errorMessage != null) {
            return Center(
              child: Text(
                negoCtrl.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final negotiation = negoCtrl.negotiation;
          if (negotiation == null) {
            return const Center(child: Text("No negotiation details found."));
          }
         if ((negotiation.status ?? '').toLowerCase() == 'accepted') {
  return NegotiationAcceptedView(
    onGoToSchedule: () {
      // Capture what we need from parentContext before anything pops —
      // once navigation starts, contexts along the stack can become
      // unreliable to read from.
      final rootNavigator = Navigator.of(widget.parentContext);
      final tabNotifier =
          Provider.of<TabIndexNotifier>(widget.parentContext, listen: false);

      // Close the modal sheet itself first.
      Navigator.of(context).pop();

      // Then pop every pushed screen (NegotiationsByOrderidScreen,
      // PendingOrderDetailScreen) back down to EntryPoint, and only then
      // switch tabs — otherwise the tab change happens underneath screens
      // still stacked on top of it, invisible until the user backs out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rootNavigator.popUntil((route) => route.isFirst);
        tabNotifier.setIndex(2);
      });
    },
  );
}

          final allRounds = negotiation.rounds ?? [];
if (_displayedRounds.isEmpty) {
  _initDisplayed(allRounds);
}

          // Reading the last displayed round (which now includes optimistic
          // bubbles instantly) is what flips the banner to "waiting" the
          // moment the client sends — no network round trip needed for that.
          final lastRoundIsProvider = _displayedRounds.isNotEmpty
              ? _displayedRounds.last.senderType == "provider"
              : false;

              final providerPrice =
    lastRoundIsProvider ? _displayedRounds.last.offeredPrice : null;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        negotiation.providerForNegotiation?.provider.fullName ??
                            "Unknown Provider",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == "profile") {
                          _openProviderProfile(negoCtrl);
                        } else if (value == "remove") {
                          final rejectCtrl = context.read<RejectNegotiationController>();
                          _removeFromNegotiation(context, rejectCtrl, widget.negotiationId);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: "profile", child: Text("View Profile")),
                        PopupMenuItem(value: "remove", child: Text("Remove / Block")),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Older-rounds indicator above the list
if (negoCtrl.isLoadingOlder)
  const LinearProgressIndicator(minHeight: 2)
else if (negoCtrl.hasOlderError)
  TextButton(
    onPressed: () => _loadOlder(retry: true),
    child: const Text("Couldn't load earlier messages. Tap to retry"),
  ),

Expanded(
  child: AnimatedList(
    key: _listKey,
    controller: _scrollController,
    reverse: true,
    initialItemCount: _displayedRounds.length,
    itemBuilder: (context, index, animation) {
      final i = _displayedRounds.length - 1 - index;
      if (i < 0 || i >= _displayedRounds.length) return const SizedBox();
      return _buildRoundBubble(_displayedRounds[i], animation);
    },
  ),
),

              if (lastRoundIsProvider)
                Consumer<ClientStartRoundController>(
                  builder: (context, clientCtrl, _) {
                    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                    return Padding(
  padding: EdgeInsets.only(
      left: 16, right: 16, bottom: bottomInset + 8, top: 8),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (providerPrice != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSending
                  ? null
                  : () => _acceptProviderPrice(
                      clientCtrl, negoCtrl, providerPrice),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      "Accept R${providerPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Message (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Kolors.kPrimary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSending ? null : () => _sendRound(clientCtrl, negoCtrl),
            child: const Text("Send"),
          ),
        ],
      ),
    ],
  ),
);
                  },
                )
              else
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Waiting for Service Provider to reply...',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}