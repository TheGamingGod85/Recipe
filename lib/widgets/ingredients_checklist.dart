import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IngredientsChecklist extends StatefulWidget {
  final List<String> ingredients;

  const IngredientsChecklist({Key? key, required this.ingredients})
      : super(key: key);

  @override
  _IngredientsChecklistState createState() => _IngredientsChecklistState();
}

class _IngredientsChecklistState extends State<IngredientsChecklist> {
  late Map<String, bool> _ingredientChecklist;

  @override
  void initState() {
    super.initState();
    // Initialize checklist state
    _ingredientChecklist = {
      for (var ingredient in widget.ingredients) ingredient: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _ingredientChecklist.keys.map((ingredient) {
            return CheckboxListTile(
              title: Text(
                ingredient,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  decoration: _ingredientChecklist[ingredient]!
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: _ingredientChecklist[ingredient]!
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              value: _ingredientChecklist[ingredient],
              onChanged: (bool? checked) {
                setState(() {
                  _ingredientChecklist[ingredient] = checked!;
                });
              },
              activeColor: Colors.deepOrange,
            );
          }).toList(),
        ),
      ),
    );
  }
}
