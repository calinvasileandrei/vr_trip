import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final bool? isLoading;
  final EdgeInsets? customMargin;

  const MyButton(this.label,{super.key,required this.onPressed, this.isLoading = false,this.customMargin = const EdgeInsets.symmetric(vertical: 20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: customMargin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child:  Row(
          children: [
            Text(label,style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
            if(isLoading == true) Container(height: 20,width: 20, margin: const EdgeInsets.only(left: 10), child: const CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
