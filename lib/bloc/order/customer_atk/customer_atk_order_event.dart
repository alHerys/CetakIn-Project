abstract class CustomerAtkOrderEvent {}

class CustomerAtkOrderLoadHistoryRequested extends CustomerAtkOrderEvent {}

enum CustomerAtkOrderFilter { ongoing, finished }

class CustomerAtkOrderFilterChanged extends CustomerAtkOrderEvent {
  final CustomerAtkOrderFilter filter;

  CustomerAtkOrderFilterChanged(this.filter);
}
