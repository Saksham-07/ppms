import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModernDateInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isSelected;
  final VoidCallback onTap;

  const ModernDateInput({
    required this.controller,
    required this.hintText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ModernDateInput> createState() => ModernDateInputState();
}

class ModernDateInputState extends State<ModernDateInput> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 35,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (widget.isSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            if (_isPressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.controller.text.isEmpty
                      ? widget.hintText
                      : widget.controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
