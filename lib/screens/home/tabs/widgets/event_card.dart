import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proact/custom_elements/custom_elements.dart';
import 'package:proact/model/task_model.dart';
import '../../../../controller/home_controller.dart';
import '../../../../core/value/app_colors.dart';

class EventCard extends StatelessWidget {
  final TaskModel task;
  final Function onDelete;
  final Function onEdit;
  final Function showGeminiPrompt;
  final VoidCallback markAsDone;
  final int index;
  final int listLength;

  const EventCard(
      {super.key,
        required this.index,
        required this.listLength,
        required this.task,
        required this.onDelete,
        required this.onEdit,
        required this.showGeminiPrompt,
        required this.markAsDone,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              if(index != 0)
              Column(
                children: [
                  Text(".",style: TextStyle(color: Colors.grey),),
                  Text(".",style: TextStyle(color: Colors.grey),),
                ],
              ), if(index == 0)
              Column(
                children: [
                  Text("",style: TextStyle(color: Colors.grey),),
                  Text("",style: TextStyle(color: Colors.grey),),
                ],
              ),
              Text(task.startTime ?? '',style: TextStyle(fontSize: 11.sp,color: Colors.grey),),
              if(listLength-1 != index)
              Column(
                children: [
                  Text(".",style: TextStyle(color: Colors.grey),),
                  Text(".",style: TextStyle(color: Colors.grey),),
                ],
              ),
              if(listLength == index)
                Column(
                  children: [
                    Text("",style: TextStyle(color: Colors.grey),),
                    Text("",style: TextStyle(color: Colors.grey),),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
            decoration: customBoxDecoration(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${task.title}' ?? '',
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8,),
                          if(task.status == 1 )

                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:Color(0xff00d00e).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8)

                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text("Completed",style: TextStyle(color: Colors.green,fontSize: 9.sp),),
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(right: 40.0,left: 0,bottom: 8),
                        child: Container(
                          height: 0.3,
                          width: double.infinity,
                          color: Colors.grey,
                        ),
                      ),
                      Row(children: [
                        Icon(Icons.schedule, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Time: ${task.startTime} - ${task.endTime}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                          ),
                        ),

                      ]),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        onEdit();
                      },
                      child: SvgPicture.asset(
                        "assets/icons/edit_icon.svg",
                      ),
                    ),
                    SizedBox(height: 12,),
                    GestureDetector(
                      onTap: () {
                        onDelete();
                      },
                      child: SvgPicture.asset(
                        "assets/icons/delete_icon.svg",
                      ),
                    ),
                    SizedBox(height: 12,),


                    GestureDetector(
                      onTap: markAsDone,
                      child: SvgPicture.asset(
                        task.status == 0
                        ?"assets/icons/grey_check_icon.svg"
                        :"assets/icons/green_check_icon.svg"
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10,),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration customBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color:Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),topLeft: Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).iconTheme.color == AppColors.kblack
        ?Colors.grey.withOpacity(0.3)
        :Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

}
