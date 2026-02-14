import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Kolors.kPrimary,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => const SizedBox(
                      width: 5,
                      height: 1,
                      child: DecoratedBox(
                        decoration:
                            BoxDecoration(color: Color(0xFFECEFF1)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Kolors.kSecondaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
