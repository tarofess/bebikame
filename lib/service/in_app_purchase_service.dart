import 'dart:async';
import 'package:bebikame/config/env/env.dart';
import 'package:bebikame/model/game.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  final List<String> _productIds = [Env.fireworksGame, Env.musicGame];
  final List<String> _purchasedProductIds = []; // 追加：購入済み製品IDのリスト

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;
  List<String> get purchasedProductIds => _purchasedProductIds; // 追加：ゲッター

  final StreamController<bool> _purchaseResultController =
      StreamController<bool>.broadcast();
  Stream<bool> get purchaseResultStream => _purchaseResultController.stream;

  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    await _getProducts();
    await _getPastPurchases();
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      print("Product IDs not found: ${response.notFoundIDs}");
    }

    _products = response.productDetails;
  }

  ProductDetails? getProductByName(Game game) {
    if (game.name == '花火ゲーム') {
      return _products.firstWhere((product) => product.id == Env.fireworksGame);
    } else if (game.name == '音楽ゲーム') {
      return _products.firstWhere((product) => product.id == Env.musicGame);
    }
    return null;
  }

  Future<void> _getPastPurchases() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _getAndroidPastPurchases();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _getIOSPastPurchases();
    }
  }

  Future<void> _getAndroidPastPurchases() async {
    final InAppPurchaseAndroidPlatformAddition androidAddition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

    final QueryPurchaseDetailsResponse response =
        await androidAddition.queryPastPurchases();

    for (var purchase in response.pastPurchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _purchasedProductIds.add(purchase.productID);
        _verifyPurchase(purchase);
      }
    }
  }

  Future<void> _getIOSPastPurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  Future<bool> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      final bool success = await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      print('購入エラー: $e');
      return false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 保留中の購入処理
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _purchaseResultController.add(false);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _purchaseResultController.add(false);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        _verifyPurchase(purchaseDetails);
        _purchaseResultController.add(true);
        _purchasedProductIds.add(purchaseDetails.productID); // 追加：購入済みリストに追加
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // サーバーサイドの検証処理をここに実装
    print('Purchase verified: ${purchaseDetails.productID}');
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    // エラー処理
    print('購入ストリームエラー: $error');
    _purchaseResultController.add(false);
  }

  // 追加：特定の製品が購入済みかどうかを確認するメソッド
  bool isProductPurchased(String productId) {
    return _purchasedProductIds.contains(productId);
  }

  void dispose() {
    _subscription.cancel();
    _purchaseResultController.close();
  }
}
