import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../viewmodels/transactions_view_model.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => sl<TransactionsViewModel>()..load(),
    child: const _TransactionsView(),
  );
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionsViewModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/transactions/add');
          if (context.mounted) await vm.load();
        },
        icon: const Icon(Iconsax.add), label: const Text('Add expense'),
      ),
      body: SafeArea(child: RefreshIndicator(
        onRefresh: vm.load,
        child: CustomScrollView(physics: const AlwaysScrollableScrollPhysics(), slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            sliver: SliverList(delegate: SliverChildListDelegate([
              _Header(onSort: vm.sortBy), const SizedBox(height: 20),
              _SummaryCard(viewModel: vm), const SizedBox(height: 20),
              _Filters(viewModel: vm), const SizedBox(height: 24),
              if (vm.isLoading && vm.transactions.isEmpty) const _LoadingState()
              else if (vm.errorMessage != null && vm.transactions.isEmpty) _ErrorState(message: vm.errorMessage!, onRetry: vm.load)
              else if (vm.transactions.isEmpty) const _EmptyState()
              else _TransactionList(transactions: vm.transactions),
            ])),
          ),
        ]),
      )),
    );
  }
}

class _Header extends StatelessWidget {
  final ValueChanged<String> onSort;
  const _Header({required this.onSort});
  @override
  Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Activity', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      SizedBox(height: 4), Text('Track every rupee with clarity', style: TextStyle(color: AppColors.textSecondary)),
    ])),
    PopupMenuButton<String>(onSelected: onSort, icon: const Icon(Iconsax.sort), itemBuilder: (_) => const [
      PopupMenuItem(value: 'date_desc', child: Text('Newest first')), PopupMenuItem(value: 'date_asc', child: Text('Oldest first')),
      PopupMenuItem(value: 'amount_desc', child: Text('Highest amount')), PopupMenuItem(value: 'amount_asc', child: Text('Lowest amount')),
    ]),
  ]);
}

class _SummaryCard extends StatelessWidget {
  final TransactionsViewModel viewModel;
  const _SummaryCard({required this.viewModel});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22), decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF6366F1)]), borderRadius: BorderRadius.circular(28),
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Net balance', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)), const SizedBox(height: 6),
      Text(CurrencyFormatter.format(viewModel.balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20), Row(children: [
        _Amount(label: 'Income', amount: viewModel.income, color: const Color(0xFF86EFAC)), const SizedBox(width: 28),
        _Amount(label: 'Spent', amount: viewModel.expenses, color: const Color(0xFFFDA4AF)),
      ]),
    ]),
  );
}

class _Amount extends StatelessWidget {
  final String label; final double amount; final Color color;
  const _Amount({required this.label, required this.amount, required this.color});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 3),
    Text(CurrencyFormatter.format(amount), style: TextStyle(color: color, fontWeight: FontWeight.w800)),
  ]);
}

class _Filters extends StatelessWidget {
  final TransactionsViewModel viewModel;
  const _Filters({required this.viewModel});
  @override Widget build(BuildContext context) => Column(children: [
    TextField(onChanged: viewModel.setSearchQuery, decoration: const InputDecoration(prefixIcon: Icon(Iconsax.search_normal), hintText: 'Search category or note')),
    const SizedBox(height: 12), Row(children: [
      _TypeChip(label: 'All', selected: viewModel.selectedType == null, onTap: () => viewModel.setType(null)), const SizedBox(width: 8),
      _TypeChip(label: 'Income', selected: viewModel.selectedType == TransactionType.income, onTap: () => viewModel.setType(TransactionType.income)), const SizedBox(width: 8),
      _TypeChip(label: 'Expenses', selected: viewModel.selectedType == TransactionType.expense, onTap: () => viewModel.setType(TransactionType.expense)),
    ]),
  ]);
}
class _TypeChip extends StatelessWidget { final String label; final bool selected; final VoidCallback onTap; const _TypeChip({required this.label, required this.selected, required this.onTap}); @override Widget build(BuildContext context) => ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()); }

class _TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionList({required this.transactions});
  @override Widget build(BuildContext context) => Column(children: transactions.map((item) => _TransactionRow(transaction: item)).toList());
}
class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  const _TransactionRow({required this.transaction});
  @override Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final tint = isIncome ? const Color(0xFF16A34A) : const Color(0xFFE11D48);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      onTap: () async {
        await context.push('/transactions/add', extra: transaction);
        if (context.mounted) await context.read<TransactionsViewModel>().load();
      }, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(backgroundColor: tint.withValues(alpha: .12), child: Icon(isIncome ? Iconsax.arrow_down : Iconsax.arrow_up, color: tint)),
      title: Text(transaction.category, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(transaction.note.isEmpty ? DateFormat('d MMM, y').format(transaction.date) : '${transaction.note} · ${DateFormat('d MMM').format(transaction.date)}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}', style: TextStyle(color: tint, fontWeight: FontWeight.w800)),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await context.push('/transactions/add', extra: transaction);
              if (context.mounted) await context.read<TransactionsViewModel>().load();
              return;
            }
            final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
              title: const Text('Delete transaction?'),
              content: const Text('This transaction will be removed from your local history.'),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete'))],
            ));
            if (confirmed == true && context.mounted) {
              final error = await context.read<TransactionsViewModel>().delete(transaction.id);
              if (context.mounted && error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
            }
          },
          itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
        ),
      ]),
    ));
  }
}
class _LoadingState extends StatelessWidget { const _LoadingState(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())); }
class _EmptyState extends StatelessWidget { const _EmptyState(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(42), child: Column(children: [Icon(Iconsax.receipt_item, size: 52, color: AppColors.textSecondary), SizedBox(height: 14), Text('No transactions yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), SizedBox(height: 6), Text('Add your first expense or income to get started.', textAlign: TextAlign.center)])); }
class _ErrorState extends StatelessWidget { final String message; final VoidCallback onRetry; const _ErrorState({required this.message, required this.onRetry}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(36), child: Column(children: [const Icon(Iconsax.warning_2, color: AppColors.expense, size: 48), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), TextButton(onPressed: onRetry, child: const Text('Try again'))])); }
