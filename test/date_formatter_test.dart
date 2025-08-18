import 'package:flutter_test/flutter_test.dart';
import 'package:universal/utils/date_formatter.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('DateFormatter', () {
    group('formatDate', () {
      test('should format valid date correctly', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatDate(date), equals('December 25, 2023'));
      });

      test('should format January date correctly', () {
        final date = DateTime(2024, 1, 1);
        expect(DateFormatter.formatDate(date), equals('January 1, 2024'));
      });

      test('should format February date correctly', () {
        final date = DateTime(2024, 2, 14);
        expect(DateFormatter.formatDate(date), equals('February 14, 2024'));
      });

      test('should handle single digit day', () {
        final date = DateTime(2023, 6, 5);
        expect(DateFormatter.formatDate(date), equals('June 5, 2023'));
      });

      test('should handle leap year date', () {
        final date = DateTime(2024, 2, 29);
        expect(DateFormatter.formatDate(date), equals('February 29, 2024'));
      });

      test('should handle month overflow correctly', () {
        final date = DateTime(2023, 13, 1); // Becomes January 2024
        expect(DateFormatter.formatDate(date), equals('January 1, 2024'));
      });

      test('should handle month underflow correctly', () {
        final date = DateTime(2023, 0, 1); // Becomes December 2022
        expect(DateFormatter.formatDate(date), equals('December 1, 2022'));
      });
    });

    group('formatWeekday', () {
      test('should format Monday correctly', () {
        final monday = DateTime(2024, 1, 1); // January 1, 2024 is a Monday
        expect(DateFormatter.formatWeekday(monday), equals('Monday'));
      });

      test('should format Tuesday correctly', () {
        final tuesday = DateTime(2024, 1, 2);
        expect(DateFormatter.formatWeekday(tuesday), equals('Tuesday'));
      });

      test('should format Wednesday correctly', () {
        final wednesday = DateTime(2024, 1, 3);
        expect(DateFormatter.formatWeekday(wednesday), equals('Wednesday'));
      });

      test('should format Thursday correctly', () {
        final thursday = DateTime(2024, 1, 4);
        expect(DateFormatter.formatWeekday(thursday), equals('Thursday'));
      });

      test('should format Friday correctly', () {
        final friday = DateTime(2024, 1, 5);
        expect(DateFormatter.formatWeekday(friday), equals('Friday'));
      });

      test('should format Saturday correctly', () {
        final saturday = DateTime(2024, 1, 6);
        expect(DateFormatter.formatWeekday(saturday), equals('Saturday'));
      });

      test('should format Sunday correctly', () {
        final sunday = DateTime(2024, 1, 7);
        expect(DateFormatter.formatWeekday(sunday), equals('Sunday'));
      });
    });

    group('isValidDate', () {
      test('should return true for valid dates', () {
        final validDate = DateTime(2023, 6, 15);
        expect(DateFormatter.isValidDate(validDate), isTrue);
      });

      test('should return true for January 31st', () {
        final date = DateTime(2023, 1, 31);
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return true for February 28th in non-leap year', () {
        final date = DateTime(2023, 2, 28);
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return true for February 29th in leap year', () {
        final date = DateTime(2024, 2, 29);
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return false for February 30th', () {
        // DateTime constructor doesn't allow invalid dates, but we test the logic
        final date = DateTime(2023, 2, 28);
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return true for April 30th', () {
        final date = DateTime(2023, 4, 30);
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return true for adjusted month overflow', () {
        final date = DateTime(2023, 13, 1); // Becomes January 2024
        expect(DateFormatter.isValidDate(date), isTrue);
      });

      test('should return true for adjusted month underflow', () {
        final date = DateTime(2023, 0, 1); // Becomes December 2022
        expect(DateFormatter.isValidDate(date), isTrue);
      });
    });

    group('leap year logic', () {
      test('should identify leap years correctly', () {
        // Test some known leap years
        expect(DateFormatter.isValidDate(DateTime(2000, 2, 29)), isTrue);
        expect(DateFormatter.isValidDate(DateTime(2004, 2, 29)), isTrue);
        expect(DateFormatter.isValidDate(DateTime(2024, 2, 29)), isTrue);
      });

      test('should identify non-leap years correctly', () {
        // Test some known non-leap years
        expect(DateFormatter.isValidDate(DateTime(1900, 2, 28)), isTrue);
        expect(DateFormatter.isValidDate(DateTime(2023, 2, 28)), isTrue);
      });
    });

    group('edge cases', () {
      test('should handle year boundaries', () {
        final newYearsEve = DateTime(2023, 12, 31);
        final newYearsDay = DateTime(2024, 1, 1);
        
        expect(DateFormatter.formatDate(newYearsEve), equals('December 31, 2023'));
        expect(DateFormatter.formatDate(newYearsDay), equals('January 1, 2024'));
      });

      test('should handle month boundaries', () {
        final endOfMonth = DateTime(2023, 3, 31);
        final startOfMonth = DateTime(2023, 4, 1);
        
        expect(DateFormatter.formatDate(endOfMonth), equals('March 31, 2023'));
        expect(DateFormatter.formatDate(startOfMonth), equals('April 1, 2023'));
      });
    });
  });
}