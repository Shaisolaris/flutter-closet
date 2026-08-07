import 'package:flutter/material.dart';
import 'package:flutter_closet/app.dart';
import 'package:flutter_closet/data/providers.dart';
import 'package:flutter_closet/features/wardrobe/widgets/item_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps a fresh [ClosetApp] backed by an in-memory (mocked)
/// SharedPreferences instance, so every test starts from the same
/// first-run, freshly-seeded state.
Future<void> pumpClosetApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)], child: const ClosetApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('launches on Wardrobe with a 4-tab bottom nav and 20 seeded items', (tester) async {
    await pumpClosetApp(tester);

    expect(find.text('Wardrobe'), findsWidgets); // app bar title + nav label
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Wardrobe'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Outfits'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Plan'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Stats'), findsOneWidget);

    expect(find.text('20 items'), findsOneWidget);
    expect(find.byType(ItemCard), findsNWidgets(20));
    expect(find.text('White Oxford Shirt'), findsWidgets);
  });

  testWidgets('Wardrobe grid filters down when a category chip is tapped', (tester) async {
    await pumpClosetApp(tester);

    expect(find.byType(ItemCard), findsNWidgets(20));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Shoes'));
    await tester.pumpAndSettle();

    // Exactly the 4 seeded shoes remain (see seed_data.dart).
    expect(find.byType(ItemCard), findsNWidgets(4));
    expect(find.text('White Leather Sneakers'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.byType(ItemCard), findsNWidgets(20));
  });

  testWidgets('Outfits tab lists all 4 seeded outfits', (tester) async {
    await pumpClosetApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Outfits'));
    await tester.pumpAndSettle();

    expect(find.text('Monday Client Call'), findsOneWidget);
    // Also appears on the Plan tab's default "today" card (mounted, if not
    // visible, under the IndexedStack), so this one is a plural match.
    expect(find.text('Weekend Errands'), findsWidgets);
    expect(find.text('Date Night'), findsOneWidget);
    expect(find.text('Chilly Weekend'), findsOneWidget);
  });

  testWidgets('Plan tab: "Wear today" marks the day worn and disables itself', (tester) async {
    await pumpClosetApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Plan'));
    await tester.pumpAndSettle();

    // Seeded: today is assigned "Weekend Errands" but not yet worn.
    expect(find.text('Weekend Errands'), findsWidgets);
    expect(find.text('Wear today'), findsOneWidget);

    await tester.tap(find.text('Wear today'));
    await tester.pumpAndSettle();

    expect(find.text('Worn today'), findsOneWidget);
    expect(find.text('Wear today'), findsNothing);
    expect(find.textContaining('Wear counts updated'), findsWidgets);
  });

  testWidgets('Stats tab shows wardrobe-wide numbers and rankings', (tester) async {
    await pumpClosetApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Stats'));
    await tester.pumpAndSettle();

    expect(find.text('Wardrobe value'), findsOneWidget);
    expect(find.text('Avg cost / wear'), findsOneWidget);
    expect(find.text('Category breakdown'), findsOneWidget);
    expect(find.text('Most worn'), findsOneWidget);
    expect(find.text('Least worn'), findsOneWidget);
    // Exactly one seeded item (the Silk Scarf) has never been worn.
    expect(find.text('Never worn (1)'), findsOneWidget);
  });
}
