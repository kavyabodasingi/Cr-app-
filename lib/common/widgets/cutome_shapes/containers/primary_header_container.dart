// import 'package:flutter/cupertino.dart';
// import 'package:t_store/common/widgets/cutome_shapes/containers/circular_container.dart';
// import 'package:t_store/common/widgets/cutome_shapes/cureved_egdes/cureved_edges_widget.dart';
// import 'package:t_store/utils/constants/colors.dart';

// class TPrimeHeaderContainer extends StatelessWidget {
//   const TPrimeHeaderContainer({
//     super.key,
//     required this.child,
//   });

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return TCurvedEdgeWidget(
//       child: Container(
//         color: TColors.primary,
//         padding: EdgeInsets.all(0),
//         child: SizedBox(
//           height: 400,
//           child: Stack(
//             children: [
//               Positioned(
//                 top: -150,
//                 right: -250,
//                 child: TCircularContainer(
//                   backgroundColor: TColors.textWhite.withOpacity(0.1),
//                 ),
//               ),
//               Positioned(
//                 top: 100,
//                 right: -300,
//                 child: TCircularContainer(
//                   backgroundColor: TColors.textWhite.withOpacity(0.1),
//                 ),
//               ),
//               child,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
