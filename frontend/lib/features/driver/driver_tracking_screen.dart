  Widget _buildHeader() {
    final seats = '${_state.seatsFilled} / ${DriverState.totalSeats} seats';

    final subtitle = !_state.isOnline
        ? 'Offline • hidden from passengers'
        : 'Demo location • $seats • ~${_state.etaMinutes} min';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: DriverTheme.deepBlue,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_state.tripFrom} → ${_state.tripTo}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _state.stage.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DriverTheme.deepBlue,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _routeCenter,
              initialZoom: 13,
              minZoom: 10,
              maxZoom: 18,
              onMapReady: () {
                if (!mounted) return;

                _mapReady = true;

                // Center on the simulated taxi once the map is initialized.
                _moveMap(_driverLatLng, 13);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.whywait',
              ),
            ],
          ),
        ],
      ),
    );
  }            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.whywait',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: DriverTheme.primaryBlue.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _buildMarkers(stops),
              ),
            ],  Widget _buildMapBanners() {
    final problem = _state.problem;

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Column(
        children: [
          if (!_state.isOnline)
            _banner(
              icon: Icons.visibility_off_rounded,
              text: "You're offline. Passengers can't see your taxi.",
              color: Colors.grey.shade800,
            ),
          _banner(
            icon: Icons.info_outline_rounded,
            text: 'Showing simulated location, not live GPS.',
            color: DriverTheme.deepBlue,
          ),
          if (problem != null)
            _banner(
              icon: Icons.warning_amber_rounded,
              text: '${problem.type} reported. '
                  'ETA delay: +${problem.delayMinutes} min.',
              color: DriverTheme.warning,
            ),
        ],
      ),
    );
  }

  Widget _banner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }