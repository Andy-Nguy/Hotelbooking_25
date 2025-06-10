import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class MapWidget extends StatefulWidget {
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String _selectedLocation = '';

  // Danh sách các địa điểm với thông tin chi tiết
  final List<LocationData> _locations = [
    LocationData(
      name: 'Phú Quốc',
      position: latlong.LatLng(10.0333, 103.9667),
      description: 'Đảo ngọc Phú Quốc',
      color: Colors.orange,
    ),
    LocationData(
      name: 'Hà Nội',
      position: latlong.LatLng(21.0341, 105.7867),
      description: 'Thủ đô ngàn năm văn hiến',
      color: Colors.red,
    ),
    LocationData(
      name: 'TP. Hồ Chí Minh',
      position: latlong.LatLng(10.7794, 106.7009),
      description: 'Thành phố năng động',
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _moveToLocation(LocationData location) {
    _mapController.move(location.position, 10.0);
    setState(() {
      _selectedLocation = location.name;
    });

    // Hide selection after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _selectedLocation = '';
        });
      }
    });
  }

  void _resetView() {
    _mapController.move(latlong.LatLng(13.9489, 105.3848), 5.5);
    setState(() {
      _selectedLocation = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            // Main Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latlong.LatLng(13.9489, 105.3848),
                initialZoom: 5.5,
                minZoom: 3.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_hotelbooking_25',
                ),
                MarkerLayer(
                  markers:
                      _locations.map((location) {
                        final isSelected = _selectedLocation == location.name;
                        return Marker(
                          width: isSelected ? 100.0 : 80.0,
                          height: isSelected ? 100.0 : 80.0,
                          point: location.position,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: location.color,
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: isSelected ? 32.0 : 24.0,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      location.name,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.9),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải bản đồ...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Map Controls
            if (!_isLoading)
              Positioned(
                top: 16.0,
                right: 16.0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Zoom Controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildControlButton(
                              icon: Icons.add,
                              onPressed: () {
                                final center = _mapController.camera.center;
                                final zoom = (_mapController.camera.zoom + 1)
                                    .clamp(3.0, 18.0);
                                _mapController.move(center, zoom);
                              },
                            ),
                            Container(height: 1, color: Colors.grey.shade300),
                            _buildControlButton(
                              icon: Icons.remove,
                              onPressed: () {
                                final center = _mapController.camera.center;
                                final zoom = (_mapController.camera.zoom - 1)
                                    .clamp(3.0, 18.0);
                                _mapController.move(center, zoom);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Reset View Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildControlButton(
                          icon: Icons.center_focus_strong,
                          onPressed: _resetView,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Location List
            if (!_isLoading)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        final location = _locations[index];
                        final isSelected = _selectedLocation == location.name;
                        return GestureDetector(
                          onTap: () => _moveToLocation(location),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? location.color.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : location.color,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    location.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isSelected
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
      ),
    );
  }
}

// Data class cho location
class LocationData {
  final String name;
  final latlong.LatLng position;
  final String description;
  final Color color;

  LocationData({
    required this.name,
    required this.position,
    required this.description,
    required this.color,
  });
}
