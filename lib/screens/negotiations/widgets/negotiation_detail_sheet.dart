import 'package:flutter/material.dart';
import 'package:flutter_application_1/global_util/services/controler/client_negotiation_round_start_ctrl.dart';
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // 🔹 Top notification helper
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

  Future<void> _sendRound(
      ClientStartRoundController clientCtrl, NegotiationByIdController negoCtrl) async {
    final msg = _messageController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);

    if (price == null) {
      _showTopNotification("Please enter a valid price", isError: true);
      return;
    }

    final success = await clientCtrl.sendRound(
      negotiationId: widget.negotiationId,
      offeredPrice: price,
      message: msg,
    );

    if (!context.mounted) return;

    if (success) {
      _messageController.clear();
      _priceController.clear();

      await negoCtrl.fetchNegotiationById(widget.negotiationId);

      final latestRound = negoCtrl.negotiation?.rounds?.last;
      if (latestRound != null) {
        setState(() {
          _displayedRounds.add(latestRound);
          _listKey.currentState?.insertItem(
            _displayedRounds.length - 1,
            duration: const Duration(milliseconds: 300),
          );
          _scrollToBottom();
        });
      }

      _showTopNotification("Round sent successfully");
    } else {
      _showTopNotification(clientCtrl.errorMessage ?? "Failed to send round", isError: true);
    }
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
          _updateRounds(allRounds);

          final lastRoundIsProvider = _displayedRounds.isNotEmpty
              ? _displayedRounds.last.senderType == "provider"
              : false;

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Negotiation #${negotiation.negotiationId}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(negotiation.status?.toUpperCase() ?? "PENDING",
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: _getStatusColor(negotiation.status),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Rounds list
              Expanded(
                child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  initialItemCount: _displayedRounds.length,
                  itemBuilder: (context, index, animation) {
                    if (index >= _displayedRounds.length) return const SizedBox();
                    final round = _displayedRounds[index];
                    final isProvider = round.senderType == "provider";

                    return SizeTransition(
                      sizeFactor: animation,
                      child: Align(
                        alignment:
                            isProvider ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          constraints: const BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            color: isProvider
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isProvider ? 12 : 0),
                              bottomRight: Radius.circular(isProvider ? 0 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (round.message != null)
                                Text(round.message!,
                                    style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                "R${round.offeredPrice?.toStringAsFixed(2) ?? 'N/A'} • ${round.createdAt != null ? DateFormat('HH:mm, dd MMM').format(round.createdAt!) : 'N/A'}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Message & Price input
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: clientCtrl.isLoading
                                ? null
                                : () => _sendRound(clientCtrl, negoCtrl),
                            child: clientCtrl.isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Send"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
