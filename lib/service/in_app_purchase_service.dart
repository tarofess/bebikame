import 'dart:async';
import 'package:bebikame/config/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  final List<String> _productIds = [Env.product_id];

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;

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
      _verifyPurchase(purchase);
    }
  }

  Future<void> _getIOSPastPurchases() async {
    // iOS では `restorePurchases()` を使用
    await _inAppPurchase.restorePurchases();
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 保留中の購入処理
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // エラー処理
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // 購入または復元された商品の処理
        _verifyPurchase(purchaseDetails);
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
  }

  void dispose() {
    _subscription.cancel();
  }
}
