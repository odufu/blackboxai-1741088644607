import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/data_service.dart';
import '../models/stand_model.dart';
import 'dart:async';

class StandListScreen extends StatefulWidget {
  const StandListScreen({super.key});

  @override
  State<StandListScreen> createState() => _StandListScreenState();
}

class _StandListScreenState extends State<StandListScreen> {
  final DataService _dataService = DataService();
  List<Stand> _stands = [];
  List<Stand> _filteredStands = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadStands();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadStands() async {
    try {
      final stands = await _dataService.getAllStands();
      setState(() {
        _stands = stands;
        _filteredStands = stands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _filteredStands = _stands.where((stand) {
          final searchLower = query.toLowerCase();
          return stand.name.toLowerCase().contains(searchLower) ||
                 stand.exhibitorName.toLowerCase().contains(searchLower) ||
                 stand.description.toLowerCase().contains(searchLower);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearch: _onSearchChanged,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStandsList(),
    );
  }

  Widget _buildStandsList() {
    if (_filteredStands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No stands found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStands.length,
      itemBuilder: (context, index) {
        final stand = _filteredStands[index];
        return _buildStandCard(stand);
      },
    );
  }

  Widget _buildStandCard(Stand stand) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/stand-details',
          arguments: stand,
        ),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stand Image or Placeholder
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: stand.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(stand.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: stand.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.store,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : null,
            ),
            // Stand Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stand.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stand.exhibitorName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stand.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/ar-navigation',
                          arguments: stand,
                        ),
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
