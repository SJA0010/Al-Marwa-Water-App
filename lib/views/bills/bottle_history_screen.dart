import 'package:al_marwa_water_app/core/constants/global_variable.dart';
import 'package:al_marwa_water_app/routes/app_routes.dart';
import 'package:al_marwa_water_app/widgets/custom_textform_field.dart';
import 'package:flutter/material.dart';

class BottleHistoryScreen extends StatefulWidget {
  const BottleHistoryScreen({super.key});

  @override
  State<BottleHistoryScreen> createState() => _BottleHistoryState();
}

class _BottleHistoryState extends State<BottleHistoryScreen> {
  // Dummy data for demonstration
  final List<Map<String, String>> _bottleData = List.generate(
      23,
      (i) => {
            'name': 'Customer ${i + 1}',
            'id': 'CUST-${(i + 1).toString().padLeft(3, '0')}',
            'quantity': '${(i + 1) * 2}',
            'date': '2025-09-${(i % 30 + 1).toString().padLeft(2, '0')}',
          });

  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _perPage = 5;

  List<Map<String, String>> get _filteredData {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _bottleData;
    return _bottleData
        .where((item) =>
            item['name']!.toLowerCase().contains(query) ||
            item['id']!.toLowerCase().contains(query))
        .toList();
  }

  int get _lastPage => (_filteredData.length / _perPage).ceil().clamp(1, 9999);

  List<Map<String, String>> get _pagedData {
    final start = (_currentPage - 1) * _perPage;
    final end = (_currentPage * _perPage).clamp(0, _filteredData.length);
    return _filteredData.sublist(start, end);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.homeScreen, (route) => false);
            },
            icon: Icon(Icons.home, color: Colors.white),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colorScheme(context).onPrimary),
        ),
        title: Text(
          'Bottle History',
          style: textTheme(context).titleLarge?.copyWith(
                color: colorScheme(context).onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme(context).primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextFormField(
                onChanged: (val) {
                  setState(() {
                    _currentPage = 1;
                  });
                },
                controller: _searchController,
                hint: 'Search by name, email, TRN...',
                prefixIcon: Icon(
                  Icons.search,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            Expanded(
              child: _pagedData.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: _pagedData.length,
                      itemBuilder: (context, index) {
                        final item = _pagedData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: Container(
                              width: 340,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.person,
                                          color: Colors.blue[900], size: 32),
                                      SizedBox(width: 12),
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          'Customer Name:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          item['name']!,
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.badge,
                                          color: Colors.blue[900]),
                                      SizedBox(width: 12),
                                      Text(
                                        'Customer ID:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(item['id']!),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.local_drink,
                                          color: Colors.blue[900]),
                                      SizedBox(width: 12),
                                      Text(
                                        'Bottle Quantity:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(item['quantity']!),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          color: Colors.blue[900]),
                                      SizedBox(width: 12),
                                      Text(
                                        'Date:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(item['date']!),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            _pagedData.isEmpty
                ? SizedBox.shrink()
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: _currentPage > 1
                              ? () => _goToPage(_currentPage - 1)
                              : null,
                          icon: Icon(
                            Icons.arrow_back,
                            color: _currentPage > 1
                                ? Colors.blue[900]
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_lastPage, (i) => i + 1)
                                .map((page) {
                              final bool isCurrent = page == _currentPage;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    if (!isCurrent) _goToPage(page);
                                  },
                                  child: isCurrent
                                      ? CircleAvatar(
                                          backgroundColor: Colors.blue[900],
                                          radius: 12,
                                          child: Text(
                                            '$page',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : Text(
                                          '$page',
                                          style: TextStyle(
                                              color: Colors.blue[900],
                                              fontWeight: FontWeight.w500),
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: _currentPage < _lastPage
                              ? () => _goToPage(_currentPage + 1)
                              : null,
                          icon: Icon(
                            Icons.arrow_forward,
                            color: _currentPage < _lastPage
                                ? Colors.blue[900]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
