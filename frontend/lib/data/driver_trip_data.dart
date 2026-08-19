import '../models/driver_trip.dart';

class DriverTripData {
  static const List<DriverTrip> trips = [
    DriverTrip(
      from: 'Bole',
      to: 'Mexico',
      date: '18 Aug 2026',
      time: '8:30 AM',
      passengers: 10,
      earnings: 300,
    ),
    DriverTrip(
      from: 'Mexico',
      to: 'Piassa',
      date: '18 Aug 2026',
      time: '10:15 AM',
      passengers: 8,
      earnings: 240,
    ),
    DriverTrip(
      from: 'Piassa',
      to: 'Megenagna',
      date: '17 Aug 2026',
      time: '1:00 PM',
      passengers: 12,
      earnings: 360,
    ),
    DriverTrip(
      from: 'Megenagna',
      to: 'Bole',
      date: '17 Aug 2026',
      time: '3:45 PM',
      passengers: 9,
      earnings: 270,
    ),
    DriverTrip(
      from: 'Bole',
      to: 'Kazanchis',
      date: '16 Aug 2026',
      time: '9:20 AM',
      passengers: 11,
      earnings: 330,
    ),
    DriverTrip(
      from: 'Kazanchis',
      to: 'Merkato',
      date: '16 Aug 2026',
      time: '12:30 PM',
      passengers: 8,
      earnings: 240,
    ),
    DriverTrip(
      from: 'Merkato',
      to: 'Megenagna',
      date: '15 Aug 2026',
      time: '2:15 PM',
      passengers: 12,
      earnings: 360,
    ),
    DriverTrip(
      from: 'Megenagna',
      to: 'Bole',
      date: '15 Aug 2026',
      time: '5:00 PM',
      passengers: 10,
      earnings: 300,
    ),
  ];
}
