import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/nepali_date_service.dart';
import '../../services/data_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/home_title.dart';

/// Calendar day info with events (bilingual support)
class CalendarDayInfo {
  final int day;
  final List<String> events;      // English events
  final List<String> eventsNp;    // Nepali events
  final bool isHoliday;

  CalendarDayInfo({
    required this.day,
    required this.events,
    required this.eventsNp,
    required this.isHoliday,
  });

  factory CalendarDayInfo.fromJson(Map<String, dynamic> json) {
    final events = (json['events'] as List<dynamic>).cast<String>();
    // Use events_np if available, otherwise fallback to events
    final eventsNp = json['events_np'] != null
        ? (json['events_np'] as List<dynamic>).cast<String>()
        : events;
    return CalendarDayInfo(
      day: json['day'] as int,
      events: events,
      eventsNp: eventsNp,
      isHoliday: json['is_holiday'] as bool? ?? false,
    );
  }

  /// Get events based on locale
  List<String> getLocalizedEvents(bool isNepali) {
    return isNepali ? eventsNp : events;
  }
}

/// Auspicious days info
class AuspiciousDaysInfo {
  final List<int> bibahaLagan;
  final List<int> bratabandha;
  final List<int> pasni;

  AuspiciousDaysInfo({
    required this.bibahaLagan,
    required this.bratabandha,
    required this.pasni,
  });

  factory AuspiciousDaysInfo.fromJson(Map<String, dynamic> json) {
    return AuspiciousDaysInfo(
      bibahaLagan: (json['bibaha_lagan'] as List<dynamic>?)?.cast<int>() ?? [],
      bratabandha: (json['bratabandha'] as List<dynamic>?)?.cast<int>() ?? [],
      pasni: (json['pasni'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  bool hasAuspiciousDay(int day) {
    return bibahaLagan.contains(day) ||
        bratabandha.contains(day) ||
        pasni.contains(day);
  }

  List<String> getAuspiciousTypes(int day, AppLocalizations l10n) {
    final types = <String>[];
    if (bibahaLagan.contains(day)) types.add(l10n.weddingAuspicious);
    if (bratabandha.contains(day)) types.add(l10n.bratabandhaAuspicious);
    if (pasni.contains(day)) types.add(l10n.pasniAuspicious);
    return types;
  }
}

/// Simple Nepali calendar utility screen with events
class NepaliCalendarScreen extends StatefulWidget {
  const NepaliCalendarScreen({super.key});

  @override
  State<NepaliCalendarScreen> createState() => _NepaliCalendarScreenState();
}

class _NepaliCalendarScreenState extends State<NepaliCalendarScreen> {
  late int _currentYear;
  late int _currentMonth;
  late NepaliDateTime _today;
  int? _selectedDay;

  Map<String, dynamic>? _eventsData;
  Map<String, dynamic>? _auspiciousData;
  bool _isLoading = true;

  // Collapsible section states
  bool _holidaysExpanded = true;
  bool _eventsExpanded = false;
  bool _auspiciousExpanded = false;

  @override
  void initState() {
    super.initState();
    _today = NepaliDateService.today();
    _currentYear = _today.year;
    _currentMonth = _today.month;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final events = await DataService.loadCalendarEvents();
      final auspicious = await DataService.loadAuspiciousDays();
      if (mounted) {
        setState(() {
          _eventsData = events;
          _auspiciousData = auspicious;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getMonthKey(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';

  Map<int, CalendarDayInfo> _getEventsForMonth() {
    if (_eventsData == null) return {};
    final key = _getMonthKey(_currentYear, _currentMonth);
    final monthData = _eventsData![key] as Map<String, dynamic>?;
    if (monthData == null) return {};

    final days = monthData['days'] as List<dynamic>?;
    if (days == null) return {};

    final result = <int, CalendarDayInfo>{};
    for (final dayJson in days) {
      final info = CalendarDayInfo.fromJson(dayJson as Map<String, dynamic>);
      result[info.day] = info;
    }
    return result;
  }

  AuspiciousDaysInfo? _getAuspiciousForMonth() {
    if (_auspiciousData == null) return null;
    final key = _getMonthKey(_currentYear, _currentMonth);
    final monthData = _auspiciousData![key] as Map<String, dynamic>?;
    if (monthData == null) return null;
    return AuspiciousDaysInfo.fromJson(monthData);
  }

  void _previousMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _today = NepaliDateService.today();
      _currentYear = _today.year;
      _currentMonth = _today.month;
      _selectedDay = null;
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = _selectedDay == day ? null : day;
    });
  }

  /// Get English month range for the current BS month
  String _getEnglishMonthRange() {
    final daysInMonth = NepaliDateService.getDaysInMonth(_currentYear, _currentMonth);
    final firstDayBs = NepaliDateService.fromBsDate(_currentYear, _currentMonth, 1);
    final lastDayBs = NepaliDateService.fromBsDate(_currentYear, _currentMonth, daysInMonth);

    final firstDayAd = NepaliDateService.bsToAd(firstDayBs);
    final lastDayAd = NepaliDateService.bsToAd(lastDayBs);

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final startMonth = months[firstDayAd.month - 1];
    final endMonth = months[lastDayAd.month - 1];

    if (firstDayAd.month == lastDayAd.month && firstDayAd.year == lastDayAd.year) {
      return '$startMonth ${firstDayAd.year}';
    } else if (firstDayAd.year == lastDayAd.year) {
      return '$startMonth - $endMonth ${firstDayAd.year}';
    } else {
      return '$startMonth ${firstDayAd.year} - $endMonth ${lastDayAd.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = NepaliDateService.getDaysInMonth(_currentYear, _currentMonth);
    final firstDayOfMonth = NepaliDateService.fromBsDate(_currentYear, _currentMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Sunday in Nepali calendar
    final eventsForMonth = _getEventsForMonth();
    final auspiciousForMonth = _getAuspiciousForMonth();

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.nepaliCalendar)),
        actions: [
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today),
            label: Text(l10n.today),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0), // Calendar
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                if (isWide) {
                  // Desktop/tablet layout: calendar on left, events on right
                  return _buildWideLayout(
                    daysInMonth,
                    firstWeekday,
                    eventsForMonth,
                    auspiciousForMonth,
                  );
                } else {
                  // Mobile layout: vertical stack
                  return _buildNarrowLayout(
                    daysInMonth,
                    firstWeekday,
                    eventsForMonth,
                    auspiciousForMonth,
                  );
                }
              },
            ),
    );
  }

  Widget _buildNarrowLayout(
    int daysInMonth,
    int firstWeekday,
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMonthHeader(),
          const Divider(height: 1),
          _buildLegend(),
          const Divider(height: 1),
          _buildWeekdayHeaders(),
          const Divider(height: 1),
          _buildCalendarGridCompact(
            daysInMonth,
            firstWeekday,
            eventsForMonth,
            auspiciousForMonth,
          ),
          const SizedBox(height: 8),
          _buildTodayInfo(eventsForMonth),
          if (_selectedDay != null)
            _buildSelectedDayEvents(eventsForMonth, auspiciousForMonth),
          const Divider(height: 1),
          _buildMonthEventsSection(eventsForMonth, auspiciousForMonth),
        ],
      ),
    );
  }

  /// Compact calendar grid for mobile - grid layout matching desktop
  Widget _buildCalendarGridCompact(
    int daysInMonth,
    int firstWeekday,
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    final startOffset = firstWeekday - 1;
    final rows = ((startOffset + daysInMonth) / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        const cellHeight = 56.0; // Compact height for mobile (no event text)

        return Column(
          children: List.generate(rows, (rowIndex) {
            return Row(
              children: List.generate(7, (colIndex) {
                final index = rowIndex * 7 + colIndex;
                final dayNumber = index - startOffset + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                  );
                }

                final isToday = _currentYear == _today.year &&
                    _currentMonth == _today.month &&
                    dayNumber == _today.day;
                final isSaturday = colIndex == 6;
                final isSelected = _selectedDay == dayNumber;

                final bsDate = NepaliDateService.fromBsDate(_currentYear, _currentMonth, dayNumber);
                final adDate = NepaliDateService.bsToAd(bsDate);

                final dayInfo = eventsForMonth[dayNumber];
                final l10n = AppLocalizations.of(context);
                final localizedEvents = dayInfo?.getLocalizedEvents(l10n.isNepali) ?? [];
                final hasEvents = localizedEvents.isNotEmpty;
                final isHoliday = dayInfo?.isHoliday ?? false;
                final isAuspicious = auspiciousForMonth?.hasAuspiciousDay(dayNumber) ?? false;

                return SizedBox(
                  width: cellWidth,
                  height: cellHeight,
                  child: _buildDayCellCompact(
                    dayNumber,
                    adDate.day,
                    isToday,
                    isSaturday,
                    isSelected,
                    hasEvents,
                    isHoliday,
                    isAuspicious,
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }

  /// Month events section for mobile - shows all events in a list
  Widget _buildMonthEventsSection(
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    final l10n = AppLocalizations.of(context);

    // Track events with their type
    final allItems = <({int day, String text, bool isAuspicious, bool isHoliday})>[];

    eventsForMonth.forEach((day, info) {
      final localizedEvents = info.getLocalizedEvents(l10n.isNepali);
      for (final event in localizedEvents) {
        allItems.add((day: day, text: event, isAuspicious: false, isHoliday: info.isHoliday));
      }
    });

    // Add auspicious days
    if (auspiciousForMonth != null) {
      final daysInMonth = NepaliDateService.getDaysInMonth(_currentYear, _currentMonth);
      for (int day = 1; day <= daysInMonth; day++) {
        final types = auspiciousForMonth.getAuspiciousTypes(day, l10n);
        for (final type in types) {
          allItems.add((day: day, text: type, isAuspicious: true, isHoliday: false));
        }
      }
    }

    // Sort by day
    allItems.sort((a, b) => a.day.compareTo(b.day));

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${NepaliMonth.namesNp[_currentMonth - 1]} - ${l10n.monthEvents}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (allItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  l10n.noEvents,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...allItems.map((item) {
              final isHoliday = item.isHoliday;
              final isAuspicious = item.isAuspicious;

              return InkWell(
                onTap: () => _selectDay(item.day),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isHoliday
                              ? Colors.red.withValues(alpha: 0.1)
                              : isAuspicious
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            item.day.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isHoliday
                                  ? Colors.red
                                  : isAuspicious
                                      ? Colors.green
                                      : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: isHoliday
                                    ? Colors.red
                                    : isAuspicious
                                        ? Colors.green[700]
                                        : null,
                                fontWeight: isHoliday ? FontWeight.w500 : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isHoliday)
                        Icon(Icons.celebration, size: 16, color: Colors.red[300])
                      else if (isAuspicious)
                        Icon(Icons.star, size: 16, color: Colors.green[300])
                      else
                        Icon(Icons.event, size: 16, color: Colors.orange[300]),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    int daysInMonth,
    int firstWeekday,
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar section (left) - fills available space
        Expanded(
          child: Column(
            children: [
              _buildMonthHeader(),
              const Divider(height: 1),
              _buildLegend(),
              const Divider(height: 1),
              _buildWeekdayHeaders(),
              const Divider(height: 1),
              Expanded(
                child: _buildCalendarGrid(
                  daysInMonth,
                  firstWeekday,
                  eventsForMonth,
                  auspiciousForMonth,
                  maxCellHeight: 120,
                ),
              ),
            ],
          ),
        ),
        // Events panel (right) - fixed width
        Container(
          width: 320,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            children: [
              _buildTodayInfo(eventsForMonth),
              const Divider(height: 1),
              if (_selectedDay != null)
                Expanded(
                  child: _buildSelectedDayEventsExpanded(eventsForMonth, auspiciousForMonth),
                )
              else
                Expanded(
                  child: _buildMonthEventsOverview(eventsForMonth, auspiciousForMonth),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthEventsOverview(
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    final l10n = AppLocalizations.of(context);

    // Separate holidays and regular events
    final holidays = <MapEntry<int, String>>[];
    final events = <MapEntry<int, String>>[];

    eventsForMonth.forEach((day, info) {
      final localizedEvents = info.getLocalizedEvents(l10n.isNepali);
      for (final event in localizedEvents) {
        if (info.isHoliday) {
          holidays.add(MapEntry(day, event));
        } else {
          events.add(MapEntry(day, event));
        }
      }
    });

    // Get auspicious days
    final auspiciousList = <MapEntry<int, String>>[];
    if (auspiciousForMonth != null) {
      final daysInMonth = NepaliDateService.getDaysInMonth(_currentYear, _currentMonth);
      for (int day = 1; day <= daysInMonth; day++) {
        final types = auspiciousForMonth.getAuspiciousTypes(day, l10n);
        for (final type in types) {
          auspiciousList.add(MapEntry(day, type));
        }
      }
    }

    if (holidays.isEmpty && events.isEmpty && auspiciousList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noEvents,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Auspicious section (expanded by default)
        if (auspiciousList.isNotEmpty) ...[
          _buildCollapsibleSection(
            icon: Icons.auto_awesome,
            title: l10n.auspicious,
            color: Colors.green,
            count: auspiciousList.length,
            isExpanded: _auspiciousExpanded,
            onToggle: () => setState(() => _auspiciousExpanded = !_auspiciousExpanded),
            items: auspiciousList,
          ),
          const SizedBox(height: 8),
        ],

        // Events section (collapsed by default)
        if (events.isNotEmpty) ...[
          _buildCollapsibleSection(
            icon: Icons.event,
            title: l10n.event,
            color: Colors.orange,
            count: events.length,
            isExpanded: _eventsExpanded,
            onToggle: () => setState(() => _eventsExpanded = !_eventsExpanded),
            items: events,
          ),
          const SizedBox(height: 8),
        ],

        // Holidays section (collapsed by default)
        if (holidays.isNotEmpty) ...[
          _buildCollapsibleSection(
            icon: Icons.celebration,
            title: l10n.holiday,
            color: Colors.red,
            count: holidays.length,
            isExpanded: _holidaysExpanded,
            onToggle: () => setState(() => _holidaysExpanded = !_holidaysExpanded),
            items: holidays,
          ),
        ],
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required IconData icon,
    required String title,
    required Color color,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<MapEntry<int, String>> items,
  }) {
    return Column(
      children: [
        // Header (tappable)
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Content (collapsible)
        AnimatedCrossFade(
          firstChild: Column(
            children: items.map((e) => _buildEventItem(
              day: e.key,
              text: e.value,
              color: color,
              icon: icon,
            )).toList(),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem({
    required int day,
    required String text,
    required Color color,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _selectDay(day),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayEventsExpanded(
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    final l10n = AppLocalizations.of(context);
    final dayInfo = eventsForMonth[_selectedDay];
    final localizedEvents = dayInfo?.getLocalizedEvents(l10n.isNepali) ?? [];
    final auspiciousTypes = auspiciousForMonth?.getAuspiciousTypes(_selectedDay!, l10n) ?? [];
    final bsDate = NepaliDateService.fromBsDate(_currentYear, _currentMonth, _selectedDay!);
    final adDate = NepaliDateService.bsToAd(bsDate);
    final weekdayNp = NepaliDateService.getWeekdayNp(bsDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected day header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _selectedDay.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${NepaliMonth.namesNp[_currentMonth - 1]} $_selectedDay, $_currentYear',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '$weekdayNp • ${adDate.day}/${adDate.month}/${adDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedDay = null),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        // Events content
        Expanded(
          child: localizedEvents.isEmpty && auspiciousTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noEvents,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (localizedEvents.isNotEmpty) ...[
                      if (dayInfo?.isHoliday ?? false)
                        _buildSectionHeader(
                          icon: Icons.celebration,
                          title: l10n.holiday,
                          color: Colors.red,
                          count: localizedEvents.length,
                        )
                      else
                        _buildSectionHeader(
                          icon: Icons.event,
                          title: l10n.event,
                          color: Colors.orange,
                          count: localizedEvents.length,
                        ),
                      ...localizedEvents.map((event) => _buildEventItem(
                        day: _selectedDay!,
                        text: event,
                        color: (dayInfo?.isHoliday ?? false) ? Colors.red : Colors.orange,
                        icon: (dayInfo?.isHoliday ?? false) ? Icons.celebration : Icons.event,
                      )),
                      if (auspiciousTypes.isNotEmpty) const SizedBox(height: 8),
                    ],
                    if (auspiciousTypes.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.auto_awesome,
                        title: l10n.auspicious,
                        color: Colors.green,
                        count: auspiciousTypes.length,
                      ),
                      ...auspiciousTypes.map((type) => _buildEventItem(
                        day: _selectedDay!,
                        text: type,
                        color: Colors.green,
                        icon: Icons.auto_awesome,
                      )),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    final monthNameNp = NepaliMonth.namesNp[_currentMonth - 1];
    final monthNameEn = NepaliMonth.names[_currentMonth - 1];
    final englishMonthRange = _getEnglishMonthRange();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            tooltip: AppLocalizations.of(context).previousMonth,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$monthNameNp $_currentYear',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  monthNameEn,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  englishMonthRange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            tooltip: AppLocalizations.of(context).nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Colors.red, l10n.holiday),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.orange, l10n.event),
          const SizedBox(width: 16),
          _buildLegendItem(Colors.green, l10n.auspicious),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdaysNp = ['आइत', 'सोम', 'मंगल', 'बुध', 'बिही', 'शुक्र', 'शनि'];
    const weekdaysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          final isSaturday = index == 6;
          return Expanded(
            child: Column(
              children: [
                Text(
                  weekdaysNp[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSaturday ? Colors.red : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  weekdaysEn[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSaturday ? Colors.red[300] : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarGrid(
    int daysInMonth,
    int firstWeekday,
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth, {
    double maxCellHeight = 100,
  }) {
    // firstWeekday: 1 = Sunday, 7 = Saturday
    final startOffset = firstWeekday - 1; // Convert to 0-indexed (0 = Sunday)
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size - no spacing between cells for grid look
        final cellWidth = constraints.maxWidth / 7;
        // Use aspect ratio for height, capped at maxCellHeight
        final cellHeight = (cellWidth * 1.1).clamp(60.0, maxCellHeight > 60 ? maxCellHeight : 120.0);

        return SingleChildScrollView(
          child: Column(
            children: List.generate(rows, (rowIndex) {
              return Row(
                children: List.generate(7, (colIndex) {
                  final index = rowIndex * 7 + colIndex;
                  final dayNumber = index - startOffset + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return SizedBox(
                      width: cellWidth,
                      height: cellHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                    );
                  }

                  final isToday = _currentYear == _today.year &&
                      _currentMonth == _today.month &&
                      dayNumber == _today.day;
                  final isSaturday = colIndex == 6;
                  final isSelected = _selectedDay == dayNumber;

                  // Get English date for this BS day
                  final bsDate = NepaliDateService.fromBsDate(_currentYear, _currentMonth, dayNumber);
                  final adDate = NepaliDateService.bsToAd(bsDate);

                  // Get events and auspicious info
                  final dayInfo = eventsForMonth[dayNumber];
                  final l10n = AppLocalizations.of(context);
                  final localizedEvents = dayInfo?.getLocalizedEvents(l10n.isNepali) ?? [];
                  final hasEvents = localizedEvents.isNotEmpty;
                  final isHoliday = dayInfo?.isHoliday ?? false;
                  final isAuspicious = auspiciousForMonth?.hasAuspiciousDay(dayNumber) ?? false;

                  // Get event text (first event only)
                  String? eventText;
                  if (localizedEvents.isNotEmpty) {
                    eventText = localizedEvents.first;
                  }

                  return SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: _buildDayCell(
                      dayNumber,
                      adDate.day,
                      isToday,
                      isSaturday,
                      isSelected,
                      hasEvents,
                      isHoliday,
                      isAuspicious,
                      eventText: eventText,
                    ),
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }

  /// Convert number to Nepali numeral
  String _toNepaliNumeral(int number) {
    const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return number.toString().split('').map((d) => nepaliDigits[int.parse(d)]).join();
  }

  Widget _buildDayCell(
    int bsDay,
    int adDay,
    bool isToday,
    bool isSaturday,
    bool isSelected,
    bool hasEvents,
    bool isHoliday,
    bool isAuspicious, {
    String? eventText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on state
    Color bgColor;
    Color bsDayColor;
    Color adDayColor;
    Color eventTextColor;

    if (isToday) {
      bgColor = Theme.of(context).colorScheme.primary;
      bsDayColor = Colors.white;
      adDayColor = Colors.white.withValues(alpha: 0.7);
      eventTextColor = Colors.white.withValues(alpha: 0.9);
    } else if (isSelected) {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      bsDayColor = Theme.of(context).colorScheme.onPrimaryContainer;
      adDayColor = Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6);
      eventTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if (isSaturday) {
      bgColor = isDark ? Colors.red.withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.03);
      bsDayColor = Colors.red[isDark ? 300 : 700]!;
      adDayColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
      eventTextColor = Colors.red[isDark ? 300 : 600]!;
    } else {
      bgColor = Colors.transparent;
      bsDayColor = Theme.of(context).colorScheme.onSurface;
      adDayColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
      eventTextColor = isHoliday ? Colors.red[isDark ? 300 : 600]! : Colors.grey[600]!;
    }

    // Holiday text color override
    if (isHoliday && !isToday && !isSelected) {
      bsDayColor = Colors.red[isDark ? 300 : 700]!;
      eventTextColor = Colors.red[isDark ? 300 : 600]!;
    }

    return GestureDetector(
      onTap: () => _selectDay(bsDay),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event text at top
              if (eventText != null && eventText.isNotEmpty)
                Text(
                  eventText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: eventTextColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else
                const Text('--', style: TextStyle(fontSize: 15, color: Colors.transparent)),

              const Spacer(),

              // Large Nepali numeral in center
              Center(
                child: Text(
                  _toNepaliNumeral(bsDay),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: bsDayColor,
                    height: 1.0,
                  ),
                ),
              ),

              const Spacer(),

              // Bottom row: indicators and AD date
              Row(
                children: [
                  // Event indicators
                  if (hasEvents || isAuspicious)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHoliday)
                          _buildEventDot(isToday ? Colors.white : Colors.red)
                        else if (hasEvents)
                          _buildEventDot(isToday ? Colors.white : Colors.orange),
                        if (isAuspicious) ...[
                          if (hasEvents) const SizedBox(width: 2),
                          _buildEventDot(isToday ? Colors.white : Colors.green),
                        ],
                      ],
                    ),
                  const Spacer(),
                  // AD date
                  Text(
                    adDay.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: adDayColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact day cell for mobile - no event text, just numbers and dots
  Widget _buildDayCellCompact(
    int bsDay,
    int adDay,
    bool isToday,
    bool isSaturday,
    bool isSelected,
    bool hasEvents,
    bool isHoliday,
    bool isAuspicious,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on state
    Color bgColor;
    Color bsDayColor;
    Color adDayColor;

    if (isToday) {
      bgColor = Theme.of(context).colorScheme.primary;
      bsDayColor = Colors.white;
      adDayColor = Colors.white.withValues(alpha: 0.7);
    } else if (isSelected) {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      bsDayColor = Theme.of(context).colorScheme.onPrimaryContainer;
      adDayColor = Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6);
    } else if (isSaturday || isHoliday) {
      bgColor = isDark ? Colors.red.withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.03);
      bsDayColor = Colors.red[isDark ? 300 : 700]!;
      adDayColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    } else {
      bgColor = Colors.transparent;
      bsDayColor = Theme.of(context).colorScheme.onSurface;
      adDayColor = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    }

    return GestureDetector(
      onTap: () => _selectDay(bsDay),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : isSelected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isToday ? 2 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nepali numeral
            Text(
              _toNepaliNumeral(bsDay),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: bsDayColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            // AD date and indicators row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  adDay.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: adDayColor,
                  ),
                ),
                if (hasEvents || isAuspicious) ...[
                  const SizedBox(width: 4),
                  if (isHoliday)
                    _buildEventDot(isToday ? Colors.white : Colors.red)
                  else if (hasEvents)
                    _buildEventDot(isToday ? Colors.white : Colors.orange),
                  if (isAuspicious) ...[
                    const SizedBox(width: 2),
                    _buildEventDot(isToday ? Colors.white : Colors.green),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSelectedDayEvents(
    Map<int, CalendarDayInfo> eventsForMonth,
    AuspiciousDaysInfo? auspiciousForMonth,
  ) {
    final l10n = AppLocalizations.of(context);
    final dayInfo = eventsForMonth[_selectedDay];
    final localizedEvents = dayInfo?.getLocalizedEvents(l10n.isNepali) ?? [];
    final auspiciousTypes = auspiciousForMonth?.getAuspiciousTypes(_selectedDay!, l10n) ?? [];
    final bsDate = NepaliDateService.fromBsDate(_currentYear, _currentMonth, _selectedDay!);
    final adDate = NepaliDateService.bsToAd(bsDate);

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and close
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${NepaliMonth.namesNp[_currentMonth - 1]} $_selectedDay, $_currentYear • ${adDate.day}/${adDate.month}/${adDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _selectedDay = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Events list
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              children: [
                if (localizedEvents.isNotEmpty)
                  ...localizedEvents.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              (dayInfo?.isHoliday ?? false) ? Icons.celebration : Icons.event,
                              size: 16,
                              color: (dayInfo?.isHoliday ?? false) ? Colors.red : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event,
                                style: TextStyle(
                                  color: (dayInfo?.isHoliday ?? false) ? Colors.red : null,
                                  fontWeight: (dayInfo?.isHoliday ?? false) ? FontWeight.w500 : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                if (auspiciousTypes.isNotEmpty)
                  ...auspiciousTypes.map((type) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                type,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      )),
                if (localizedEvents.isEmpty && auspiciousTypes.isEmpty)
                  Text(
                    l10n.noEvents,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayInfo(Map<int, CalendarDayInfo> eventsForMonth) {
    final l10n = AppLocalizations.of(context);
    final adDate = NepaliDateService.bsToAd(_today);
    final todayDayInfo = _currentYear == _today.year && _currentMonth == _today.month
        ? eventsForMonth[_today.day]
        : null;
    final todayEvents = todayDayInfo?.getLocalizedEvents(l10n.isNepali) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _today.day.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.todayLabel(NepaliDateService.formatNp(_today)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${NepaliDateService.getWeekdayNp(_today)} (${NepaliDateService.getWeekdayEn(_today)})',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  l10n.adDate('${adDate.day}/${adDate.month}/${adDate.year}'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (todayEvents.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    todayEvents.join(' • '),
                    style: TextStyle(
                      fontSize: 12,
                      color: (todayDayInfo?.isHoliday ?? false) ? Colors.red : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
