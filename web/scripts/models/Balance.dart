import 'dart:core';

enum BalanceType { income, expense }

class Balance {
  final String id;
  final BalanceType type;
  final String description;
  final double amount;

  const Balance(this.id, this.type, this.description, this.amount);
}
