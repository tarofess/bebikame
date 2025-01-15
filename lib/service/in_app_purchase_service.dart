import 'dart:async';
import 'package:bebikame/env/env.dart';
import 'package:bebikame/model/game.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  final List<String> _productIds = [Env.fireworksGame, Env.musicGame];
  final List<String> _purchasedProductIds = [];
  List<ProductDetails> get products => _products;
  List<String> get purchasedProductIds => _purchasedProductIds;

  final StreamController<bool> _purchaseResultController =
      StreamController<bool>.broadcast();
  Stream<bool> get purchaseResultStream => _purchaseResultController.stream;

  late Completer<void> _purchaseUpdateCompleter;
  bool _isRestoringPurchases = false;

  Future<bool> initialize() async {
    bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return false;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    isAvailable = await _getProducts();
    isAvailable = await getPastPurchases();

    return isAvailable;
  }

  Future<bool> _getProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds.toSet());
      _products = response.productDetails;
      return true;
    } catch (e) {
      return false;
    }
  }

  ProductDetails? getProductByName(Game game) {
    if (game.name == '花火ゲーム') {
      return _products.firstWhere((product) => product.id == Env.fireworksGame);
    } else if (game.name == '音楽ゲーム') {
      return _products.firstWhere((product) => product.id == Env.musicGame);
    }
    return null;
  }

  Future<bool> getPastPurchases() async {
    try {
      _isRestoringPurchases = true;
      _purchaseUpdateCompleter = Completer<void>();

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _getAndroidPastPurchases();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _getIOSPastPurchases();
      }

      await _purchaseUpdateCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (!_purchaseUpdateCompleter.isCompleted) {
            _purchaseUpdateCompleter.complete();
          }
        },
      );

      _isRestoringPurchases = false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _getAndroidPastPurchases() async {
    final InAppPurchaseAndroidPlatformAddition androidAddition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

    final QueryPurchaseDetailsResponse response =
        await androidAddition.queryPastPurchases();

    if (response.error != null) {
      throw Exception('アプリ内課金購入履歴の取得に失敗しました。\nネットワーク接続を確認してください。');
    }

    for (var purchase in response.pastPurchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _purchasedProductIds.add(purchase.productID);
      }
    }
  }

  Future<void> _getIOSPastPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      throw Exception('アプリ内課金購入履歴の取得に失敗しました。\nネットワーク接続を確認してください。');
    }
  }

  bool isProductPurchased(String productId) {
    return _purchasedProductIds.contains(productId);
  }

  Future<bool> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      final bool success = await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      throw Exception('購入処理中にエラーが発生しました。');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _purchaseResultController.add(true);
        _purchasedProductIds.add(purchaseDetails.productID);

        if (_isRestoringPurchases && !_purchaseUpdateCompleter.isCompleted) {
          _purchaseUpdateCompleter.complete();
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _purchaseResultController.add(false);
        _inAppPurchase.completePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _purchaseResultController.add(false);
        _inAppPurchase.completePurchase(purchaseDetails);
      } else if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    try {
      _purchaseResultController.add(false);
    } catch (e) {
      throw Exception('アプリ内課金の購入結果の取得に失敗しました。');
    }
  }

  void dispose() {
    _subscription.cancel();
    _purchaseResultController.close();
  }
}
