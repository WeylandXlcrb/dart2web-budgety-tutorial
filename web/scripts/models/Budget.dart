import 'dart:math';

import 'Balance.dart';

class Budget {
  double current;
  double totalIncomes;
  double totalExpenses;
  int expensesPercent;
  List<Balance> incomes = [];
  List<Balance> expenses = [];

  Budget({
    this.current = 0,
    this.totalIncomes = 0,
    this.totalExpenses = 0,
    this.expensesPercent = 0,
  });

  void _calcCurrent() {
    current = totalIncomes - totalExpenses;
    expensesPercent =
        totalIncomes > 0 ? ((totalExpenses / totalIncomes) * 100).round() : 100;
  }

  Balance addBalance({BalanceType type, String description, double amount}) {
    var balance = Balance(DateTime.now().toString(), type, description, amount);

    if (type == BalanceType.income) {
      incomes.add(balance);
      totalIncomes += balance.amount;
    } else {
      expenses.add(balance);
      totalExpenses += balance.amount;
    }

    _calcCurrent();

    return balance;
  }

  void removeBalance({String id, BalanceType type}) {
    if (type == BalanceType.income) {
      var balance = incomes.firstWhere((b) => b.id == id);
      totalIncomes -= balance.amount;
      incomes.remove(balance);
    } else {
      var balance = expenses.firstWhere((b) => b.id == id);
      expenses.remove(balance);
      totalExpenses -= balance.amount;
    }

    _calcCurrent();
  }

  int percentOfExpenses(double amount) {
    return ((amount / totalExpenses) * 100).round();
  }
}
