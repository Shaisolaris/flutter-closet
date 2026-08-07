import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logic/date_math.dart';
import '../../core/logic/plan.dart';
import '../../core/models/outfit.dart';
import '../../core/models/plan_entry.dart';
import '../../data/providers.dart';
import 'widgets/day_detail_card.dart';
import 'widgets/month_calendar.dart';

/// The Plan tab: a month calendar for assigning outfits to specific days,
/// plus the selected day's detail and its "Wear today" action.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(planEntriesProvider);
    final entries = entriesAsync.valueOrNull ?? const <PlanEntry>[];
    final outfits = ref.watch(outfitsProvider).valueOrNull ?? const <Outfit>[];
    final visibleMonth = ref.watch(visibleMonthProvider);
    final selectedDate = ref.watch(selectedPlanDateProvider);
    final today = dateOnly(DateTime.now());

    final plannedDates = entries.map((entry) => entry.date).toSet();
    final wornDates = entries.where((entry) => entry.worn).map((entry) => entry.date).toSet();

    final selectedEntry = resolvePlanForDate(entries, selectedDate);
    Outfit? selectedOutfit;
    if (selectedEntry != null) {
      for (final candidate in outfits) {
        if (candidate.id == selectedEntry.outfitId) {
          selectedOutfit = candidate;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Plan'), centerTitle: false),
      body: entriesAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    child: MonthCalendar(
                      visibleMonth: visibleMonth,
                      selectedDate: selectedDate,
                      plannedDates: plannedDates,
                      wornDates: wornDates,
                      onSelectDate: (date) => ref.read(selectedPlanDateProvider.notifier).state = date,
                      onChangeMonth: (delta) {
                        final current = ref.read(visibleMonthProvider);
                        ref.read(visibleMonthProvider.notifier).state = DateTime(current.year, current.month + delta);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DayDetailCard(
                  date: selectedDate,
                  isToday: isSameDate(selectedDate, today),
                  entry: selectedEntry,
                  outfit: selectedOutfit,
                  hasOutfits: outfits.isNotEmpty,
                ),
              ],
            ),
    );
  }
}
