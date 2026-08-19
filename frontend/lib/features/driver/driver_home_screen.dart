import 'package:flutter/material.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundColor = Color(0xFFF7F9FC);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int passengerCount = 7;
  final int maximumPassengers = 12;

  String pickupLocation = 'Bole';
  String destinationLocation = 'Mexico';

  void _showPassengerDialog() {
    int temporaryCount = passengerCount;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Update Passengers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Update the number of passengers currently on board.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PassengerCounterButton(
                        icon: Icons.remove,
                        onPressed: temporaryCount > 0
                            ? () {
                                setDialogState(() {
                                  temporaryCount--;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            '$temporaryCount',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: DriverHomeScreen.primaryBlue,
                            ),
                          ),
                          Text(
                            'of $maximumPassengers',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      _PassengerCounterButton(
                        icon: Icons.add,
                        onPressed: temporaryCount < maximumPassengers
                            ? () {
                                setDialogState(() {
                                  temporaryCount++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      passengerCount = temporaryCount;
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DriverHomeScreen.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeRouteDialog() {
    String temporaryPickup = pickupLocation;
    String temporaryDestination = destinationLocation;

    final locations = [
      'Bole',
      'Mexico',
      'Piassa',
      'Megenagna',
      'Kazanchis',
      'CMC',
      'Sarbet',
      '4 Kilo',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Change Route',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select the pickup and destination for this trip.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pickup',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: temporaryPickup,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.my_location_rounded,
                        color: DriverHomeScreen.primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          temporaryPickup = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Destination',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: temporaryDestination,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_rounded,
                        color: DriverHomeScreen.primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: locations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          temporaryDestination = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: temporaryPickup == temporaryDestination
                      ? null
                      : () {
                          setState(() {
                            pickupLocation = temporaryPickup;
                            destinationLocation = temporaryDestination;
                          });

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DriverHomeScreen.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Route'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DriverHomeScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'WhyWait',
          style: TextStyle(
            color: DriverHomeScreen.primaryBlue,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: _DashboardContent(
            passengerCount: passengerCount,
            pickupLocation: pickupLocation,
            destinationLocation: destinationLocation,
            onPassengersPressed: _showPassengerDialog,
            onChangeRoutePressed: _showChangeRouteDialog,
          ),
        ),
      ),
      bottomNavigationBar: const _DriverBottomNavigation(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final int passengerCount;
  final String pickupLocation;
  final String destinationLocation;
  final VoidCallback onPassengersPressed;
  final VoidCallback onChangeRoutePressed;

  const _DashboardContent({
    required this.passengerCount,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.onPassengersPressed,
    required this.onChangeRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DriverHeader(),

        const SizedBox(height: 24),

        const _SectionTitle(
          title: 'Active Trip',
        ),

        const SizedBox(height: 12),

        _ActiveTripCard(
          passengerCount: passengerCount,
          pickupLocation: pickupLocation,
          destinationLocation: destinationLocation,
        ),

        const SizedBox(height: 20),

        const _SectionTitle(
          title: 'Quick Actions',
        ),

        const SizedBox(height: 12),

        _QuickActions(
          onPassengersPressed: onPassengersPressed,
          onChangeRoutePressed: onChangeRoutePressed,
        ),

        const SizedBox(height: 20),

        const _SectionTitle(
          title: "Today's Summary",
        ),

        const SizedBox(height: 12),

        const _TodaysSummary(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: DriverHomeScreen.primaryBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Driver',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Ready for your next trip?',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Online',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final int passengerCount;
  final String pickupLocation;
  final String destinationLocation;

  const _ActiveTripCard({
    required this.passengerCount,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACTIVE TRIP',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DriverHomeScreen.primaryBlue.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: DriverHomeScreen.primaryBlue,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'AA 32-81',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: DriverHomeScreen.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DriverHomeScreen.primaryBlue,
                        width: 3,
                      ),
                    ),
                  ),

                  Container(
                    width: 2,
                    height: 46,
                    color: DriverHomeScreen.primaryBlue.withValues(
                      alpha: 0.25,
                    ),
                  ),

                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: DriverHomeScreen.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      pickupLocation,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      destinationLocation,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_rounded,
                color: DriverHomeScreen.primaryBlue,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Divider(
            height: 1,
            color: Color(0xFFE8E8E8),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: _TripStatistic(
                  icon: Icons.route_rounded,
                  value: '2.4 km',
                  label: 'Distance',
                ),
              ),

              const _StatisticDivider(),

              const Expanded(
                child: _TripStatistic(
                  icon: Icons.access_time_rounded,
                  value: '~8 min',
                  label: 'ETA',
                ),
              ),

              const _StatisticDivider(),

              Expanded(
                child: _TripStatistic(
                  icon: Icons.people_alt_rounded,
                  value: '$passengerCount / 12',
                  label: 'Passengers',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripStatistic extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TripStatistic({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: DriverHomeScreen.primaryBlue,
          size: 22,
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatisticDivider extends StatelessWidget {
  const _StatisticDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 55,
      color: const Color(0xFFE8E8E8),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onPassengersPressed;
  final VoidCallback onChangeRoutePressed;

  const _QuickActions({
    required this.onPassengersPressed,
    required this.onChangeRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 430;

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.people_alt_rounded,
                      label: 'Passengers',
                      onTap: onPassengersPressed,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.map_rounded,
                      label: 'Change Route',
                      onTap: onChangeRoutePressed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: _QuickActionButton(
                  icon: Icons.stop_circle_rounded,
                  label: 'End Trip',
                  isDestructive: true,
                  onTap: () {},
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.people_alt_rounded,
                label: 'Passengers',
                onTap: onPassengersPressed,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _QuickActionButton(
                icon: Icons.map_rounded,
                label: 'Change Route',
                onTap: onChangeRoutePressed,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _QuickActionButton(
                icon: Icons.stop_circle_rounded,
                label: 'End Trip',
                isDestructive: true,
                onTap: () {},
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDestructive
        ? Colors.red
        : DriverHomeScreen.primaryBlue;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 105,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.15)
                  : DriverHomeScreen.primaryBlue.withValues(
                      alpha: 0.12,
                    ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                label,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red
                      : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassengerCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PassengerCounterButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: DriverHomeScreen.primaryBlue.withValues(
          alpha: 0.10,
        ),
        foregroundColor: DriverHomeScreen.primaryBlue,
        disabledForegroundColor: Colors.grey,
        minimumSize: const Size(50, 50),
      ),
      icon: Icon(icon),
    );
  }
}

class _TodaysSummary extends StatelessWidget {
  const _TodaysSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _SummaryStatistic(
              icon: Icons.directions_bus_rounded,
              value: '8',
              label: 'Trips',
            ),
          ),

          _SummaryDivider(),

          Expanded(
            child: _SummaryStatistic(
              icon: Icons.route_rounded,
              value: '47 km',
              label: 'Distance',
            ),
          ),

          _SummaryDivider(),

          Expanded(
            child: _SummaryStatistic(
              icon: Icons.payments_rounded,
              value: '320 ETB',
              label: 'Earnings',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatistic extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryStatistic({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: DriverHomeScreen.primaryBlue.withValues(
              alpha: 0.10,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: DriverHomeScreen.primaryBlue,
            size: 21,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 65,
      color: const Color(0xFFE8E8E8),
    );
  }
}

class _DriverBottomNavigation extends StatelessWidget {
  const _DriverBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: true,
                  onTap: () {},
                ),
              ),

              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.map_rounded,
                  label: 'Map',
                  onTap: () {},
                ),
              ),

              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () {},
                ),
              ),

              Expanded(
                child: _BottomNavigationItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavigationItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isSelected
        ? DriverHomeScreen.primaryBlue
        : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: itemColor,
              size: 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 11,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}