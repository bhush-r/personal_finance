import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/goal.dart';
import '../cubit/goal_cubit.dart';

import '../../../../shared/widgets/enhanced_text_field.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalType goalType;

  const AddGoalScreen({
    super.key,
    required this.goalType,
  });

  @override
  State<AddGoalScreen> createState() =>
      _AddGoalScreenState();
}

class _AddGoalScreenState
    extends State<AddGoalScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ===========================================================================
  // SUBMIT
  // ===========================================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    if (_nameCtrl.text.trim().isEmpty) {
      _showErrorSnackBar(
        'Please enter a goal name',
      );
      return;
    }

    if (_amountCtrl.text.trim().isEmpty) {
      _showErrorSnackBar(
        'Please enter a target amount',
      );
      return;
    }

    final amount = double.tryParse(
      _amountCtrl.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showErrorSnackBar(
        'Please enter a valid amount',
      );
      return;
    }

    final goal = Goal(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      type: widget.goalType,
      targetAmount: amount,
      currentAmount: 0,
      createdDate: DateTime.now(),
    );

    context.read<GoalCubit>().createGoal(
      goal,
    );

    context.pop();
  }

  // ===========================================================================
  // ERROR SNACKBAR
  // ===========================================================================

  void _showErrorSnackBar(
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                message,
              ),
            ),
          ],
        ),

        backgroundColor:
        Colors.red.shade600,

        duration:
        const Duration(seconds: 2),

        behavior:
        SnackBarBehavior.floating,

        margin:
        const EdgeInsets.all(16),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ===========================================================================
  // GOAL TYPE COLOR
  // ===========================================================================

  Color _getGoalTypeColor() {
    switch (widget.goalType) {
      case GoalType.savings:
        return Colors.green;

      case GoalType.investment:
        return Colors.blue;

      case GoalType.debt:
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final goalTypeColor =
    _getGoalTypeColor();

    return Scaffold(
      resizeToAvoidBottomInset: true,

      backgroundColor:
      const Color(0xFFF7F8FA),

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Add Goal',
        ),

        backgroundColor:
        Colors.transparent,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            context.pop();
          },

          icon: const Icon(
            Icons.close,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------

      body: SlideTransition(
        position: _slideAnimation,

        child: FadeTransition(
          opacity: _fadeAnimation,

          child: SafeArea(
            bottom: false,

            child: LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,

                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    32,
                  ),

                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(
                      minHeight:
                      constraints.maxHeight,
                    ),

                    child: Column(
                      children: [
                        // -----------------------------------------------------
                        // FORM CARD
                        // -----------------------------------------------------

                        FCard(
                          child: Padding(
                            padding:
                            const EdgeInsets.all(
                              20,
                            ),

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [
                                // ------------------------------------------------
                                // GOAL TYPE BADGE
                                // ------------------------------------------------

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color: goalTypeColor
                                        .withValues(
                                      alpha: 0.1,
                                    ),

                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      8,
                                    ),
                                  ),

                                  child: Text(
                                    widget.goalType
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),

                                    style: TextStyle(
                                      color:
                                      goalTypeColor,

                                      fontWeight:
                                      FontWeight.w600,

                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                // ------------------------------------------------
                                // GOAL NAME
                                // ------------------------------------------------

                                EnhancedTextField(
                                  controller:
                                  _nameCtrl,

                                  label:
                                  'Goal Name',

                                  hintText:
                                  'e.g., Buy Laptop',

                                  prefixIcon:
                                  Icons.flag_outlined,
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                // ------------------------------------------------
                                // TARGET AMOUNT
                                // ------------------------------------------------

                                EnhancedTextField(
                                  controller:
                                  _amountCtrl,

                                  label:
                                  'Target Amount',

                                  hintText:
                                  'e.g., 50000',

                                  keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                    decimal: true,
                                  ),

                                  prefixIcon:
                                  Icons.currency_rupee,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // -----------------------------------------------------
                        // CREATE GOAL BUTTON
                        // -----------------------------------------------------

                        SizedBox(
                          width:
                          double.infinity,

                          child: FButton(
                            onPress:
                            _submit,

                            child: const Text(
                              'Create Goal',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}