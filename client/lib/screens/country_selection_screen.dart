import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import '../services/localization_service.dart';
import '../main.dart' show SelectionScreen;

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  List<Country> _allCountries = [];
  List<Country> _filteredCountries = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allCountries = CountryService().getAll();
    // Sort by name
    _allCountries.sort((a, b) => a.name.compareTo(b.name));
    _filteredCountries = _allCountries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries.where((country) {
        return country.name.toLowerCase().contains(query) ||
            country.displayName.toLowerCase().contains(query) ||
            country.countryCode.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                LocalizationService().translate('select_country'),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                LocalizationService().translate('choose_region'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search country...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF059669),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 24),
              Expanded(
                child: _filteredCountries.isEmpty
                    ? Center(
                        child: Text(
                          'No country found',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                _onCountrySelected(context, country);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      country.flagEmoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Color(0xFF059669),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: (50 * index).ms).slideX();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCountrySelected(BuildContext context, Country country) {
    final service = LocalizationService();

    // Set the country
    service.setCountry(country.name);

    // Set language based on country code
    // Arabic countries
    const arabicCountries = [
      'DZ',
      'EG',
      'SA',
      'AE',
      'QA',
      'KW',
      'OM',
      'BH',
      'LB',
      'JO',
      'PS',
      'IQ',
      'YE',
      'SY',
      'SD',
      'LY',
      'TN',
      'MA',
      'MR',
      'SO',
      'KM',
      'DJ',
    ];
    // French speaking countries (partial list)
    const frenchCountries = [
      'FR',
      'BE',
      'CH',
      'CA',
      'SN',
      'CI',
      'CM',
      'CD',
      'MG',
      'ML',
      'NE',
      'BF',
      'BJ',
      'TG',
      'GA',
      'CG',
      'TD',
      'CF',
      'GQ',
    ];

    if (arabicCountries.contains(country.countryCode)) {
      service.changeLocale('ar');
    } else if (frenchCountries.contains(country.countryCode)) {
      service.changeLocale('fr');
    } else {
      service.changeLocale('en');
    }

    // Navigate to main selection screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
    );
  }
}
