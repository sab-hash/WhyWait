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
  }