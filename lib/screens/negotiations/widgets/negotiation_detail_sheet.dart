import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/global_util/services/controler/client_negotiation_round_start_ctrl.dart';
import 'package:flutter_application_1/global_util/services/controler/negotiation_realtime_controller.dart';
import 'package:flutter_application_1/global_util/services/controler/reject_negociation_controller.dart';
import 'package:flutter_application_1/screens/sp_profile/views%20copy/viewSP_Profile_Screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/models/order_service_models/negotiation_model.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final realtime = context.read<NegotiationRealtimeController>();
      realtime.connect(widget.negotiationId, _handleSocketEvent);
    });
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
      final round = NegotiationRound.fromJson(data);

      // Route through the merge step instead of appending directly —
      // this is what stops the client's own optimistic bubble from
      // getting duplicated when the server echoes it back over the socket.
      _mergeServerRounds([round]);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateRounds(List<NegotiationRound> newRounds) {
    final roundsToAdd = newRounds.skip(_displayedRounds.length).toList();
    for (var round in roundsToAdd) {
      _displayedRounds.add(round);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listKey.currentState?.insertItem(
          _displayedRounds.length - 1,
          duration: const Duration(milliseconds: 300),
        );
        _scrollToBottom();
      });
    }
  }

  /// Reconciles rounds coming from the server (via refetch OR the realtime
  /// socket) against what's already on screen.
  ///
  /// - If a server round's id is already displayed, skip it.
  /// - If there's a pending/sent local bubble with no id yet that matches
  ///   this server round (same sender, price, message), replace it in place
  ///   — this is how an optimistic bubble gets "confirmed" without ever
  ///   duplicating.
  /// - Otherwise it's a genuinely new round (e.g. the provider's reply) —
  ///   append it with the normal insert animation.
  void _mergeServerRounds(List<NegotiationRound> serverRounds) {
    for (final serverRound in serverRounds) {
      final alreadyDisplayed = _displayedRounds.any(
        (r) => r.id != null && r.id == serverRound.id,
      );
      if (alreadyDisplayed) continue;

      final pendingIndex = _displayedRounds.indexWhere(
        (r) =>
            r.id == null &&
            r.localId != null &&
            r.senderType == serverRound.senderType &&
            r.offeredPrice == serverRound.offeredPrice &&
            (r.message ?? '') == (serverRound.message ?? ''),
      );

      if (pendingIndex != -1) {
        setState(() {
          _displayedRounds[pendingIndex] = serverRound;
        });
      } else {
        setState(() {
          _displayedRounds.add(serverRound);
          _listKey.currentState?.insertItem(
            _displayedRounds.length - 1,
            duration: const Duration(milliseconds: 300),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
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

  /// Optimistic send: bubble appears instantly, then we reconcile with
  /// whatever the refetch / socket brings back.
  Future<void> _sendRound(
    ClientStartRoundController clientCtrl,
    NegotiationByIdController negoCtrl,
  ) async {
    final msg = _messageController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);

    if (price == null) {
      _showTopNotification("Please enter a valid price", isError: true);
      return;
    }

    _messageController.clear();
    _priceController.clear();

    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final tempRound = NegotiationRound(
      negotiationId: widget.negotiationId,
      senderType: 'client',
      offeredPrice: price,
      message: msg.isEmpty ? null : msg,
      createdAt: DateTime.now(),
      localId: tempId,
      localStatus: RoundLocalStatus.sending,
    );

    // 1. Show the bubble immediately — no await before this.
    setState(() {
      _displayedRounds.add(tempRound);
      _listKey.currentState?.insertItem(
        _displayedRounds.length - 1,
        duration: const Duration(milliseconds: 300),
      );
    });
    _scrollToBottom();

    // 2. Fire the request in the background.
    final success = await clientCtrl.sendRound(
      negotiationId: widget.negotiationId,
      offeredPrice: price,
      message: msg,
    );

    if (!mounted) return;

    final idx = _displayedRounds.indexWhere((r) => r.localId == tempId);
    if (idx == -1) return; // bubble already reconciled by socket, nothing to do

    if (success) {
      setState(() {
        _displayedRounds[idx] =
            _displayedRounds[idx].copyWith(localStatus: RoundLocalStatus.confirmed);
      });

      // The API doesn't return the created round, so refetch to get the
      // real id — _mergeServerRounds will swap our temp bubble for it
      // rather than duplicating.
      await negoCtrl.fetchNegotiationById(widget.negotiationId);
      if (!mounted) return;
      _mergeServerRounds(negoCtrl.negotiation?.rounds ?? []);

      _showTopNotification("Round sent successfully");
    } else {
      setState(() {
        _displayedRounds[idx] =
            _displayedRounds[idx].copyWith(localStatus: RoundLocalStatus.failed);
      });
      _showTopNotification(clientCtrl.errorMessage ?? "Failed to send round", isError: true);
    }
  }

  Future<void> _retryPendingRound(
    String localId,
    ClientStartRoundController clientCtrl,
    NegotiationByIdController negoCtrl,
  ) async {
    final idx = _displayedRounds.indexWhere((r) => r.localId == localId);
    if (idx == -1) return;
    final round = _displayedRounds[idx];

    setState(() {
      _displayedRounds[idx] = round.copyWith(localStatus: RoundLocalStatus.sending);
    });

    final success = await clientCtrl.sendRound(
      negotiationId: widget.negotiationId,
      offeredPrice: round.offeredPrice ?? 0,
      message: round.message,
    );

    if (!mounted) return;

    final idx2 = _displayedRounds.indexWhere((r) => r.localId == localId);
    if (idx2 == -1) return;

    if (success) {
      setState(() {
        _displayedRounds[idx2] =
            _displayedRounds[idx2].copyWith(localStatus: RoundLocalStatus.confirmed);
      });
      await negoCtrl.fetchNegotiationById(widget.negotiationId);
      if (!mounted) return;
      _mergeServerRounds(negoCtrl.negotiation?.rounds ?? []);
    } else {
      setState(() {
        _displayedRounds[idx2] =
            _displayedRounds[idx2].copyWith(localStatus: RoundLocalStatus.failed);
      });
      _showTopNotification(clientCtrl.errorMessage ?? "Still failed to send", isError: true);
    }
  }

  void _discardPendingRound(String localId) {
    final idx = _displayedRounds.indexWhere((r) => r.localId == localId);
    if (idx == -1) return;

    final removed = _displayedRounds.removeAt(idx);
    _listKey.currentState?.removeItem(
      idx,
      (context, animation) => _buildRoundBubble(removed, animation),
      duration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildRoundBubble(NegotiationRound round, Animation<double> animation) {
    final isClient = round.senderType == "client";
    final isFailed = round.isFailed;
    final isSending = round.isPending;

    Widget bubble = Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
        color: isFailed
            ? Colors.red.shade50
            : isClient
                ? Colors.blue.shade100
                : Colors.grey.shade200,
        border: isFailed ? Border.all(color: Colors.red.shade300) : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isClient ? 12 : 0),
          bottomRight: Radius.circular(isClient ? 0 : 12),
        ),
      ),
      child: Opacity(
        opacity: isSending ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (round.message != null && round.message!.isNotEmpty)
              Text(round.message!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'}",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 6),
                if (isSending)
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else if (isFailed)
                  Icon(Icons.error_outline, size: 13, color: Colors.red.shade600)
                else
                  Text(
                    round.createdAt != null
                        ? DateFormat('HH:mm, dd MMM').format(round.createdAt!)
                        : 'N/A',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                if (isFailed) ...[
                  const SizedBox(width: 6),
                  Text(
                    'Tap to retry',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (isFailed && round.localId != null) {
      final clientCtrl = context.read<ClientStartRoundController>();
      final negoCtrl = context.read<NegotiationByIdController>();
      bubble = GestureDetector(
        onTap: () => _retryPendingRound(round.localId!, clientCtrl, negoCtrl),
        onLongPress: () => _discardPendingRound(round.localId!),
        child: bubble,
      );
    }

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
        ChangeNotifierProvider(
            create: (_) => NegotiationByIdController()
              ..fetchNegotiationById(widget.negotiationId)),
        ChangeNotifierProvider(create: (_) => ClientStartRoundController()),
      ],
      child: Consumer2<NegotiationByIdController, ClientStartRoundController>(
        builder: (context, negoCtrl, clientCtrl, _) {
          if (negoCtrl.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Kolors.kPrimary),
            );
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

          final allRounds = negotiation.rounds ?? [];
          if (_displayedRounds.isEmpty) {
            _updateRounds(allRounds);
          }

          // Reading the last displayed round (which now includes optimistic
          // bubbles instantly) is what flips the banner to "waiting" the
          // moment the client sends — no network round trip needed for that.
          final lastRoundIsProvider = _displayedRounds.isNotEmpty
              ? _displayedRounds.last.senderType == "provider"
              : false;

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

              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  initialItemCount: _displayedRounds.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _displayedRounds.length) return const SizedBox();
                    return _buildRoundBubble(_displayedRounds[index], animation);
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
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Message...',
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
                          // No isLoading gate — send is instant now, the
                          // bubble itself carries the pending/failed state.
                          ElevatedButton(
                            onPressed: () => _sendRound(clientCtrl, negoCtrl),
                            child: const Text("Send"),
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