import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class DriverProfileScreen extends StatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final double rating;
  final int totalTrips;
  final double earningsToday;
  final String vehicleModel;
  final String vehiclePlate;
  final String vehicleColor;

  const DriverProfileScreen({
    super.key,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    required this.rating,
    required this.totalTrips,
    required this.earningsToday,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.vehicleColor,
  });

  @override
  State<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState
    extends State<DriverProfileScreen> {
  static const Color primaryBlue = Color(0xFF0B3D78);

  int _currentNavIndex = 3;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),

              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: _buildStatsCard(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  8,
                ),
                child: Text(
                  'VEHICLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: _buildVehicleCard(),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                child: Text(
                  'SETTINGS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: _settingItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: _buildSettingRow(item),
                        ),
                      )
                      .toList(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  20,
                ),
                child: _buildSignOutButton(),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        48,
      ),
      decoration: const BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: widget.avatarUrl != null
                      ? Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),

              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _isOnline
                        ? Colors.greenAccent.shade400
                        : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryBlue,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            widget.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.phoneNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          _buildOnlineToggle(),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  Widget _buildOnlineToggle() {
  return Tooltip(
    message: _isOnline
        ? 'Tap to go offline'
        : 'Tap to go online',
    child: GestureDetector(
      onTap: () {
        setState(() {
          _isOnline = !_isOnline;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _isOnline
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: _isOnline
              ? null
              : Border.all(
                  color: Colors.white54,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline
                    ? const Color(0xFF2E9E4F)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline
                  ? 'Online — accepting rides'
                  : 'Offline',
              style: TextStyle(
                color: _isOnline
                    ? primaryBlue
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildStatsCard() {
  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              '${widget.rating.toStringAsFixed(1)} ★',
              'Rating',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn(
              '${widget.totalTrips}',
              'Trips',
            ),
          ),
          _statDivider(),
          Expanded(
            child: _statColumn(
              '${widget.earningsToday.toStringAsFixed(0)} ETB',
              'Today',
            ),
          ),
        ],
      ),
    ),
  );
}
  
  Widget _statColumn(
    String value,
    String label,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.grey[200],
    );
  }

  Widget _buildVehicleCard() {
  return InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: primaryBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.vehicleColor} '
                  '${widget.vehicleModel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.vehiclePlate,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[400],
          ),
        ],
      ),
    ),
  );
}

  List<_SettingItem> get _settingItems => [
        _SettingItem(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Earnings & Payouts',
          subtitle: 'View history, cash out',
        ),
        _SettingItem(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications',
          subtitle: 'Alerts for new ride requests',
        ),
        _SettingItem(
          icon: Icons.shield_outlined,
          title: 'Privacy & Security',
          subtitle: 'Password, data settings',
        ),
        _SettingItem(
          icon: Icons.headset_mic_outlined,
          title: 'Support',
          subtitle: 'Help center, contact us',
        ),
      ];

  Widget _buildSettingRow(
    _SettingItem item,
  ) {
    return InkWell(
      onTap: item.onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: primaryBlue,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.redAccent,
              size: 20,
            ),

            SizedBox(width: 8),

            Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}