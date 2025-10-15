import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnomalyPage extends StatefulWidget {
  const AnomalyPage({super.key});

  @override
  State<AnomalyPage> createState() => _AnomalyPageState();
}

class _AnomalyPageState extends State<AnomalyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingFlagged = false;
  bool _isLoadingNumber = false;
  List<Map<String, dynamic>> _flaggedData = [];
  List<Map<String, dynamic>> _numberData = [];
  String? _errorFlagged;
  String? _errorNumber;
  
  // Pagination for Flagged tab
  int _currentPage = 1;
  int _totalPages = 1;
  int _itemsPerPage = 20;
  
  // Pagination for Number tab
  int _currentPageNumber = 1;
  int _totalPagesNumber = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFlaggedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFlaggedData({int page = 1}) async {
    setState(() {
      _isLoadingFlagged = true;
      _errorFlagged = null;
    });

    try {
      final response = await ApiService.getAnalysisData(
        tableName: 'anomaly_flagged_data',
        page: page,
        pageSize: _itemsPerPage,
      );
      
      // Print complete response to console
      print('=== FLAGGED DATA API RESPONSE ===');
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
          _flaggedData = pageData;
          _currentPage = currentPage;
          _totalPages = totalPages;
        });
      }
    } catch (e) {
      setState(() {
        _errorFlagged = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingFlagged = false;
      });
    }
  }

  Future<void> _loadNumberData({int page = 1}) async {
    setState(() {
      _isLoadingNumber = true;
      _errorNumber = null;
    });

    try {
      final response = await ApiService.getAnalysisData(
        tableName: 'ongoing_projects_with_anomaly_flag',
        page: page,
        pageSize: _itemsPerPage,
      );
      
      // Print complete response to console
      print('=== NUMBER DATA API RESPONSE ===');
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
          _numberData = pageData;
          _currentPageNumber = currentPage;
          _totalPagesNumber = totalPages;
        });
      }
    } catch (e) {
      setState(() {
        _errorNumber = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingNumber = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Sub-tabs
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                if (index == 1 && _numberData.isEmpty && !_isLoadingNumber) {
                  _loadNumberData();
                }
              },
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Flagged'),
                Tab(text: 'Number'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFlaggedTab(),
                _buildNumberTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flagged Anomalies',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anomalies that have been flagged for review',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isLoadingFlagged)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorFlagged != null)
            _buildErrorWidget(_errorFlagged!, () => _loadFlaggedData())
          else if (_flaggedData.isEmpty)
            _buildEmptyWidget('No flagged anomalies found')
          else
            Column(
              children: [
                _buildDataGrid(_flaggedData),
                const SizedBox(height: 24),
                _buildPaginationControls(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNumberTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ongoing Projects with Anomaly Flags',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Projects that currently have anomaly flags',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isLoadingNumber)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_errorNumber != null)
            _buildErrorWidget(_errorNumber!, () => _loadNumberData())
          else if (_numberData.isEmpty)
            _buildEmptyWidget('No ongoing projects with anomaly flags found')
          else
            Column(
              children: [
                _buildDataGrid(_numberData),
                const SizedBox(height: 24),
                _buildPaginationControlsNumber(),
              ],
            ),
        ],
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
                onPressed: _currentPage > 1 ? () => _loadFlaggedData(page: _currentPage - 1) : null,
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
                      onTap: () => _loadFlaggedData(page: pageNumber),
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
                onPressed: _currentPage < _totalPages ? () => _loadFlaggedData(page: _currentPage + 1) : null,
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

  Widget _buildPaginationControlsNumber() {
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
            'Page $_currentPageNumber of $_totalPagesNumber',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Pagination buttons
          Row(
            children: [
              // Previous button
              IconButton(
                onPressed: _currentPageNumber > 1 ? () => _loadNumberData(page: _currentPageNumber - 1) : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPageNumber > 1 
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surface,
                  foregroundColor: _currentPageNumber > 1 
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              
              // Page numbers
              ...List.generate(
                _totalPagesNumber.clamp(0, 5), // Show max 5 page numbers
                (index) {
                  int pageNumber = _currentPageNumber <= 3 
                      ? index + 1 
                      : _currentPageNumber - 2 + index;
                  
                  if (pageNumber > _totalPagesNumber) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _loadNumberData(page: pageNumber),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: pageNumber == _currentPageNumber
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: pageNumber == _currentPageNumber
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '$pageNumber',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: pageNumber == _currentPageNumber
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: pageNumber == _currentPageNumber
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
                onPressed: _currentPageNumber < _totalPagesNumber ? () => _loadNumberData(page: _currentPageNumber + 1) : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: _currentPageNumber < _totalPagesNumber 
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.surface,
                  foregroundColor: _currentPageNumber < _totalPagesNumber 
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
}
