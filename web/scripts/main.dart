import 'dart:html';

import 'package:intl/intl.dart';

import 'models/Budget.dart';
import 'models/Balance.dart';

final DivElement container = querySelector('.container');
final SpanElement timeSpan = querySelector('.budget__title--month');
final ButtonElement addBtn = querySelector('.add__btn');
final SelectElement typeSelect = querySelector('.add__type');
final InputElement descriptionInput = querySelector('.add__description');
final InputElement amountInput = querySelector('.add__value');
final DivElement incomeListContainer = querySelector('.income__list');
final DivElement expenseListContainer = querySelector('.expenses__list');
final DivElement budgetContainer = querySelector('.budget__value');
final DivElement incomesTotalContainer =
    querySelector('.budget__income--value');
final DivElement expensesTotalContainer =
    querySelector('.budget__expenses--value');
final DivElement expensesPcntContainer =
    querySelector('.budget__expenses--percentage');

final budget = Budget();

String formatCurrency(double amount) {
  return NumberFormat.currency(locale: 'ru', customPattern: '#,###.#')
      .format(amount);
}

void displayDate() {
  var now = DateTime.now();

  var months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  timeSpan.innerHtml = '${months[now.month - 1]} ${now.year}';
}

void updateBudgetUI([bool recalcExpensePercents = false]) {
  budgetContainer.innerHtml = budget.current > 0 ? '+ ' : '';
  budgetContainer.innerHtml += '${formatCurrency(budget.current)}\$';
  incomesTotalContainer.innerHtml = '+${formatCurrency(budget.totalIncomes)}';
  expensesTotalContainer.innerHtml =
      '- ${formatCurrency(budget.totalExpenses)}';
  expensesPcntContainer.innerHtml = '${budget.expensesPercent}%';

  if (!recalcExpensePercents) return;

  for (DivElement expenseDiv in expenseListContainer.children) {
    var balance = budget.expenses.firstWhere((b) => b.id == expenseDiv.id);

    expenseDiv.querySelector('.item__percentage').innerHtml =
        '${budget.percentOfExpenses(balance.amount)}%';
  }
}

void renderBalanceItem(Balance balance) {
  var balanceContainer = balance.type == BalanceType.income
      ? incomeListContainer
      : expenseListContainer;
  var sign = balance.type == BalanceType.income ? '+' : '-';

  var html = '''
      <div class="item clearfix" id="${balance.id}">
          <div class="item__description">${balance.description}</div>
          <div class="right clearfix">
              <div class="item__value">
                  $sign ${formatCurrency(balance.amount)}
              </div>
      ''';

  if (balance.type == BalanceType.expense) {
    html += '''
        <div class="item__percentage">
            ${budget.percentOfExpenses(balance.amount)}%
        </div>
    ''';
  }

  html += '''
              <div class="item__delete">
                  <button class="item__delete--btn">
                    <i class="ion-ios-close-outline"></i>
                  </button>
              </div>
          </div>
      </div>
  ''';

  balanceContainer.insertAdjacentHtml('beforeEnd', html);
}

void addItem() {
  var amount = double.tryParse(amountInput.value) ?? double.nan;

  if (descriptionInput.value.isEmpty || amount.isNaN || amount <= 0) return;

  var isIncome = typeSelect.value == 'inc';

  var newBalance = budget.addBalance(
    type: isIncome ? BalanceType.income : BalanceType.expense,
    description: descriptionInput.value,
    amount: amount,
  );

  renderBalanceItem(newBalance);
  updateBudgetUI(!isIncome);
}

void deleteItem(MouseEvent event) {
  var container = event.matchingTarget.parent.parent;

  var isIncome = container.parent == incomeListContainer;

  budget.removeBalance(
    id: container.id,
    type: isIncome ? BalanceType.income : BalanceType.expense,
  );

  container.remove();
  updateBudgetUI(!isIncome);
}

void changeBalanceTypeUI() {
  typeSelect.classes.toggle('red-focus');
  descriptionInput.classes.toggle('red-focus');
  amountInput.classes.toggle('red-focus');
  addBtn.classes.toggle('red');
}

void main() {
  updateBudgetUI();
  displayDate();
  addBtn.onClick.listen((_) => addItem());
  container.onClick.matches('.item__delete').listen(deleteItem);
  typeSelect.onChange.listen((_) => changeBalanceTypeUI());
  document.onKeyPress.listen((event) {
    if (event.keyCode != 13) return;

    addItem();
  });
}
