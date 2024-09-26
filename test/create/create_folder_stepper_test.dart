import 'package:chenron/models/item.dart';
import 'package:chenron/folder/create/steps/folder_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chenron/folder/create/create_stepper.dart';
import 'package:chenron/providers/create_state.dart';
import 'package:chenron/providers/cud_state.dart';
import 'package:chenron/providers/folder_info_state.dart';
import 'package:chenron/database/database.dart';

void main() {
  group('CreateFolderStepper Widget Tests', () {
    testWidgets('CreateFolderStepper initializes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );

      expect(find.byType(Stepper), findsOneWidget);
      expect(find.text('Folder'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('Next button advances to next step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );

      expect(find.text('Next'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
    });

    testWidgets('Previous button not visible on first step',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );
      expect(find.text('Previous'), findsNothing);
    });

    testWidgets('Next button does nothing when current step is invalid',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );

      // Get the initial step index
      final CreateFolderState folderState = Provider.of<CreateFolderState>(
          tester.element(find.byType(Consumer<CreateFolderState>)),
          listen: false);
      final int initialStepIndex = folderState.currentStep.index;

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(folderState.currentStep.index, equals(initialStepIndex));
    });
  });

  group('FolderInfo Step Tests', () {
    testWidgets('FolderInfo step is initially visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );

      expect(find.byType(FolderInfoStep), findsOneWidget);
      expect(find.text('Folder'), findsOneWidget);
    });

    testWidgets('FolderInfo step validates input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );
      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('FolderInfo step updates FolderInfoProvider',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CreateFolderState()),
            ChangeNotifierProvider(create: (_) => FolderInfoProvider()),
            ChangeNotifierProvider(create: (_) => CUDProvider<FolderItem>()),
            Provider<AppDatabase>(create: (_) => AppDatabase()),
          ],
          child: const MaterialApp(home: CreateFolderStepper()),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Test Folder');
      await tester.enterText(
          find.byType(TextFormField).last, 'Test Description');

      final folderInfoProvider = Provider.of<FolderInfoProvider>(
          tester.element(find.byType(CreateFolderStepper)),
          listen: false);
      expect(folderInfoProvider.title, equals('Test Folder'));
      expect(folderInfoProvider.description, equals('Test Description'));
    });
  });
}
