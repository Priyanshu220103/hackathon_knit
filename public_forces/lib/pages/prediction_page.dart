import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final TextEditingController _originalCostController = TextEditingController();
  final TextEditingController _projectCountController = TextEditingController();
  final TextEditingController _cumulativeExpenditureController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _prediction;
  String? _error;

  @override
  void dispose() {
    _originalCostController.dispose();
    _projectCountController.dispose();
    _cumulativeExpenditureController.dispose();
    super.dispose();
  }

  Future<void> _getPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _prediction = null;
    });

    try {
      final response = await ApiService.getPrediction(
        originalCost: double.parse(_originalCostController.text),
        projectCount: int.parse(_projectCountController.text),
        cumulativeExpenditure: double.parse(_cumulativeExpenditureController.text),
      );

      // Print complete response to console
      print('=== PREDICTION API RESPONSE ===');
      print('Complete Response: $response');
      print('Response Type: ${response.runtimeType}');
      print('Response Keys: ${response.keys.toList()}');
      print('================================');

      setState(() {
        _prediction = response['prediction']?.toString() ?? 'No prediction available';
      });
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
              minWidth: 600,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Cost Prediction',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the project details to get cost prediction',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  Row(
                    children: [
                      // Original Cost Field
                      Expanded(
                        child: _buildTextField(
                          controller: _originalCostController,
                          label: 'Original Cost',
                          hint: 'Enter original cost',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter original cost';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Project Count Field
                      Expanded(
                        child: _buildTextField(
                          controller: _projectCountController,
                          label: 'Project Count',
                          hint: 'Enter project count',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter project count';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Cumulative Expenditure Field
                      Expanded(
                        child: _buildTextField(
                          controller: _cumulativeExpenditureController,
                          label: 'Cumulative Expenditure',
                          hint: 'Enter cumulative expenditure',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter cumulative expenditure';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Predict Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _getPrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Predict',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Prediction Result
                  if (_prediction != null || _error != null)
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: 200,
                          maxWidth: 600,
                        ),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: _error != null 
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _error != null 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _error != null ? Icons.error_outline : Icons.analytics,
                              size: 48,
                              color: _error != null 
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error != null ? 'Error' : 'Prediction Result',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: _error != null 
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _error ?? _prediction!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _error != null 
                                    ? Theme.of(context).colorScheme.onErrorContainer
                                    : Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          validator: validator,
        ),
      ],
    );
  }
}