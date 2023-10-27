import 'package:flutter/material.dart';

class ReplyCard extends StatelessWidget {
  final String message;

  const ReplyCard({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          color: Colors.grey.shade200,
          child: Stack(
            children: [
              Padding(
                // padding: const EdgeInsets.only(left: 10, right: 75, top: 5, bottom: 10),
                padding: const EdgeInsets.all(12),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF5B5B5B),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    // height: 0.12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
