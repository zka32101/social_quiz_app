import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_quiz_app/models/user_progress.dart';
import 'package:social_quiz_app/repositories/progress_repository.dart';
import 'package:social_quiz_app/repositories/avatar_shop_repository.dart';
import 'package:social_quiz_app/services/avatar_purchase_service.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockAvatarShopRepository extends Mock implements AvatarShopRepository {}

void main() {
  group('AvatarPurchaseService', () {
    late MockProgressRepository mockProgressRepo;
    late MockAvatarShopRepository mockShopRepo;
    late AvatarPurchaseService service;

    setUp(() {
      mockProgressRepo = MockProgressRepository();
      mockShopRepo = MockAvatarShopRepository();
      service = AvatarPurchaseService(
        progressRepo: mockProgressRepo,
        shopRepo: mockShopRepo,
      );
    });

    test('purchaseAvatar deducts coins successfully', () async {
      // Arrange
      final progress = UserProgress.initial('test_user').copyWith(coins: 200);
      when(mockProgressRepo.loadLocal()).thenReturn(progress);
      when(mockShopRepo.purchaseAvatar(5)).thenAnswer((_) => Future.value());

      // Act
      final result = await service.purchaseAvatar(5, 150);

      // Assert
      expect(result, isTrue);
      verify(mockProgressRepo.loadLocal()).called(1);
      verify(mockProgressRepo.saveLocal(any)).called(1);
      verify(mockShopRepo.purchaseAvatar(5)).called(1);

      final captured =
          verify(mockProgressRepo.saveLocal(captureAny)).captured;
      final updatedProgress = captured.first as UserProgress;
      expect(updatedProgress.coins, equals(50)); // 200 - 150
    });

    test('purchaseAvatar fails when insufficient coins', () async {
      // Arrange
      final progress = UserProgress.initial('test_user').copyWith(coins: 100);
      when(mockProgressRepo.loadLocal()).thenReturn(progress);

      // Act
      final result = await service.purchaseAvatar(5, 150);

      // Assert
      expect(result, isFalse);
      verify(mockProgressRepo.loadLocal()).called(1);
      verifyNever(mockProgressRepo.saveLocal(any));
      verifyNever(mockShopRepo.purchaseAvatar(any));
    });

    test('canAfford returns true when sufficient coins', () {
      // Act & Assert
      expect(service.canAfford(100, 150), isTrue);
      expect(service.canAfford(100, 100), isTrue);
      expect(service.canAfford(100, 50), isTrue);
    });

    test('canAfford returns false when insufficient coins', () {
      // Act & Assert
      expect(service.canAfford(100, 99), isFalse);
      expect(service.canAfford(100, 0), isTrue);
    });

    test('getAvatarInfo returns correct avatar data', () {
      // Act
      final avatar = service.getAvatarInfo(1);

      // Assert
      expect(avatar, isNotNull);
      expect(avatar?.id, equals(1));
      expect(avatar?.nameJa, contains('茶色'));
    });

    test('getAvatarInfo returns null for invalid id', () {
      // Act
      final avatar = service.getAvatarInfo(999);

      // Assert
      expect(avatar, isNull);
    });

    test('getShopAvatars returns only purchasable avatars', () {
      // Act
      final shopAvatars = service.getShopAvatars();

      // Assert
      expect(shopAvatars.length, greaterThan(0));
      for (final avatar in shopAvatars) {
        expect(avatar.isFree, isFalse);
        expect(avatar.priceCoins, isNotNull);
      }
    });

    test('getAvailableAvatars includes defaults and purchased', () {
      // Arrange
      when(mockShopRepo.getPurchasedAvatarIds()).thenReturn([5, 6]);

      // Act
      final available = service.getAvailableAvatars();

      // Assert
      expect(available, isNotEmpty);

      final ids = available.map((a) => a.id).toList();
      // Should include default avatars (1-4)
      expect(ids.contains(1), isTrue);
      expect(ids.contains(2), isTrue);
      // Should include purchased (5, 6)
      expect(ids.contains(5), isTrue);
      expect(ids.contains(6), isTrue);
    });
  });
}
