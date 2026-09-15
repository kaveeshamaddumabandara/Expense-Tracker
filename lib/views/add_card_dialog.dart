import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/virtual_card.dart';

Future<VirtualCardData?> showAddCardDialog(
  BuildContext context, {
  required ValueChanged<VirtualCardData> onCardAdded,
}) {
  return showModalBottomSheet<VirtualCardData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AddCardModalSheet(onCardAdded: onCardAdded),
  );
}

class AddCardModalSheet extends StatefulWidget {
  const AddCardModalSheet({
    super.key,
    required this.onCardAdded,
  });

  final ValueChanged<VirtualCardData> onCardAdded;

  @override
  State<AddCardModalSheet> createState() => _AddCardModalSheetState();
}

class _AddCardModalSheetState extends State<AddCardModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  String _selectedBrand = 'mastercard'; // 'mastercard' or 'visa'
  int _selectedGradientIndex = 0;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _cardNumberController.addListener(() => setState(() {}));
    _balanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final rawNumber = _cardNumberController.text.trim();
    final cardNumber = rawNumber.length > 4
        ? rawNumber.substring(rawNumber.length - 4)
        : rawNumber.padLeft(4, '0');
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    final newCard = VirtualCardData(
      title: title,
      cardNumber: cardNumber,
      balance: balance,
      brand: _selectedBrand,
      gradientIndex: _selectedGradientIndex,
    );

    widget.onCardAdded(newCard);
    Navigator.of(context).pop(newCard);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final parsedBalance = double.tryParse(_balanceController.text.trim()) ?? 0.0;
    final currentTitle =
        _titleController.text.trim().isEmpty ? 'My Card' : _titleController.text.trim();
    final rawNum = _cardNumberController.text.trim();
    final currentCardNum = rawNum.isEmpty
        ? '••••'
        : (rawNum.length > 4 ? rawNum.substring(rawNum.length - 4) : rawNum);

    final previewCard = VirtualCardData(
      title: currentTitle,
      cardNumber: currentCardNum,
      balance: parsedBalance,
      brand: _selectedBrand,
      gradientIndex: _selectedGradientIndex,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inactivePillBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Store your virtual debit or credit card',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          // Scrollable Form Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Card Preview
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: VirtualCardWidget(card: previewCard),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Title Field
                    const Text(
                      'Card Name / Title',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('add_card_title_field'),
                      controller: _titleController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Daily Spending, Bank of Ceylon',
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a card title.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Card Number (Last 4 digits) & Brand in a Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Last 4 digits
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last 4 Digits',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const Key('add_card_number_field'),
                                controller: _cardNumberController,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '6175',
                                  prefixIcon: const Icon(
                                    Icons.pin_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide:
                                        const BorderSide(color: AppColors.borderLight),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (val.trim().length != 4) {
                                    return '4 digits';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Brand Selector (Mastercard vs Visa)
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Card Brand',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _BrandChoiceChip(
                                      label: 'Mastercard',
                                      isSelected: _selectedBrand == 'mastercard',
                                      onTap: () =>
                                          setState(() => _selectedBrand = 'mastercard'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _BrandChoiceChip(
                                      label: 'Visa',
                                      isSelected: _selectedBrand == 'visa',
                                      onTap: () =>
                                          setState(() => _selectedBrand = 'visa'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Starting Balance Field (in LKR)
                    const Text(
                      'Starting Balance (LKR)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('add_card_balance_field'),
                      controller: _balanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 58,
                          alignment: Alignment.center,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LKR',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter starting balance.';
                        }
                        final amount = double.tryParse(val.trim());
                        if (amount == null) {
                          return 'Please enter a valid numeric balance.';
                        }
                        if (amount < 0) {
                          return 'Balance cannot be negative.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Card Theme Picker
                    const Text(
                      'Card Theme',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: VirtualCardData.presets.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedGradientIndex == index;
                          final gradient = VirtualCardData.presets[index];
                          final name = VirtualCardData.presetNames[index];

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedGradientIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: isSelected ? 2.5 : 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.borderLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            key: const Key('add_card_submit_button'),
                            onPressed: _submit,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text(
                              'Add Card',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandChoiceChip extends StatelessWidget {
  const _BrandChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
