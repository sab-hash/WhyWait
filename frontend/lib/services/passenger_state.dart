class PassengerState {
  static final PassengerState _instance = PassengerState._internal();
  factory PassengerState() => _instance;
  PassengerState._internal();

  String selectedStation = 'Bole Taxi Station';
  List<Map<String, dynamic>> terminals = [];
}