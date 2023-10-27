import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;

  const OwnMessageCard({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
          constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width-45
      ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
          // color: Colors.green[50],
          color: Colors.greenAccent[100],
          child: Stack(
            children: [
              Padding(
                // padding: EdgeInsets.only(left: 10,right: 75,top: 5,bottom: 10),
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
              // const Positioned(
              //   bottom: 4,
              //   right: 10,
              //   child: Row(
              //     children: [
              //       Text(
              //           "20:11",
              //         style: TextStyle(fontSize: 12,color: Colors.grey),
              //       ),
              //       SizedBox(width: 5,),
              //       Icon(Icons.done_all)
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
