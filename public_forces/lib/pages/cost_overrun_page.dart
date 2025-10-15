import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CostOverRunPage extends StatefulWidget {
  const CostOverRunPage({super.key});

  @override
  State<CostOverRunPage> createState() => _CostOverRunPageState();
}

class _CostOverRunPageState extends State<CostOverRunPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _data = [];
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getAnalysisData(
        tableName: 'costoverrun',
        page: page,
        pageSize: _itemsPerPage,
      );
      
      // Print complete response to console
      print('=== COST OVERRUN API RESPONSE ===');
      print('Complete Response: $response');
      print('Response Type: ${response.runtimeType}');
      print('Response Keys: ${response.keys.toList()}');
      if (response['data'] != null) {
        print('Data Length: ${response['data'].length}');
        print('First Item: ${response['data'].isNotEmpty ? response['data'][0] : 'No data'}');
      }
      print('================================');
      
      if (response['data'] != null) {
        List<Map<String, dynamic>> pageData = List<Map<String, dynamic>>.from(response['data']);
        
        // Use server-side pagination info
        Map<String, dynamic> pagination = response['pagination'] ?? {};
        int totalPages = pagination['total_pages'] ?? 1;
        int currentPage = pagination['current_page'] ?? 1;
        
        setState(() {
          _data = pageData;
          _currentPage = currentPage;
          _totalPages = totalPages;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              'Cost Overrun Analysis',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Projects with cost overruns and budget analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Data Display
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              _buildErrorWidget(_error!, () => _loadData())
            else if (_data.isEmpty)
              _buildEmptyWidget('No cost overrun data found')
            else
              Column(
                children: [
                  _buildDataGrid(_data),
                  const SizedBox(height: 24),
                  _buildPaginationControls(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGrid(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    // Get all unique keys from the data
    Set<String> allKeys = {};
    for (var item in data) {
      allKeys.addAll(item.keys);
    }
    List<String> columns = allKeys.toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          ),
          columns: columns.map((column) => DataColumn(
            label: Text(
              column.replaceAll('_', ' ').toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
          rows: data.map((item) => DataRow(
            cells: columns.map((column) => DataCell(
              Text(
                item[column]?.toString() ?? 'N/A',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )).toList(),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Text(
            'Page $_currentPage of $_totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Pagination buttons
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: _currentPage > 1 ? () => _loadData(page: _currentPage - 1) : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage > 1 
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surface,
                  foregroundColor: _currentPage > 1 
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              
              // Page numbers
              ...List.generate(
                _totalPages.clamp(0, 5), // Show max 5 page numbers
                (index) {
                  int pageNumber = _currentPage <= 3 
                      ? index + 1 
                      : _currentPage - 2 + index;
                  
                  if (pageNumber > _totalPages) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _loadData(page: pageNumber),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: pageNumber == _currentPage
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: pageNumber == _currentPage
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$pageNumber',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: pageNumber == _currentPage
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: pageNumber == _currentPage
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Next button
              IconButton(
                onPressed: _currentPage < _totalPages ? () => _loadData(page: _currentPage + 1) : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPage < _totalPages 
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surface,
                  foregroundColor: _currentPage < _totalPages 
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
