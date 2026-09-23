class DriverTrip {
  final String from;
  final String to;
  final String date;
  final String time;
  final int passengers;
  final double earnings;
  final double fare;

  const DriverTrip({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.passengers,
    required this.earnings,
    required this.fare,
  });

  /// Per-seat fare derived from earnings ÷ passengers.
  /// Handy when you don't want to pass `fare` explicitly in the data file.
  double get farePerSeat => passengers == 0 ? 0 : earnings / passengers;

  factory DriverTrip.fromJson(Map<String, dynamic> json) {
    return DriverTrip(
      from: json['from'] as String,
      to: json['to'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      passengers: (json['passengers'] as num).toInt(),
      earnings: (json['earnings'] as num).toDouble(),
      fare: (json['fare'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'date': date,
        'time': time,
        'passengers': passengers,
        'earnings': earnings,
        'fare': fare,
      };

  @override
  String toString() =>
      'DriverTrip($from → $to, $date $time, $passengers pax, '
      'earnings: $earnings, fare: $fare)';
}