import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/currency_constants.dart';
import '../../core/utils/currency_formatter.dart';

class AmountInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final String? currencyCode;
  final ValueChanged<double>? onAmountChanged;
  final bool showCurrencySelector;

  const AmountInputField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.validator,
    this.currencyCode = 'INR',
    this.onAmountChanged,
    this.showCurrencySelector = false,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  late String _selectedCurrency;
  late FocusNode _focusNode;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currencyCode ?? 'INR';
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency =
    CurrencyConstants.getCurrencyByCode(_selectedCurrency);
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isError
                  ? Colors.red.shade400
                  : isFocused
                  ? Colors.black87
                  : Colors.grey.shade200,
              width: _isError ? 2 : (isFocused ? 1.5 : 1),
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              // Currency Symbol or Selector
              if (widget.showCurrencySelector)
                GestureDetector(
                  onTap: _showCurrencySelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency.symbol,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_down_1,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Icon(
                    Iconsax.wallet,
                    color: isFocused ? Colors.black87 : Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      final amount = double.tryParse(value);
                      _isError = widget.validator?.call(value) != null;
                      if (amount != null && amount > 0) {
                        widget.onAmountChanged?.call(amount);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                  ),
                  validator: widget.validator ?? (value) {
                    if (value?.isEmpty ?? true) return 'Amount is required';
                    final amount = double.tryParse(value!);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
              // Info Button
              if (!widget.showCurrencySelector)
                Padding(
                  padding:
                  const EdgeInsets.only(right: 12),
                  child: Tooltip(
                    message: 'Currency: ${currency.name}',
                    child: Icon(
                      Iconsax.info_circle,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.validator?.call(widget.controller.text) ?? '',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ],
    );
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount:
                CurrencyConstants.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency =
                  CurrencyConstants.supportedCurrencies[index];
                  final isSelected =
                      _selectedCurrency == currency.code;

                  return ListTile(
                    leading: Text(
                      currency.symbol,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    title: Text(currency.name),
                    subtitle: Text(
                      currency.country,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(
                      Iconsax.tick_circle,
                      color: Colors.green,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCurrency = currency.code;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}