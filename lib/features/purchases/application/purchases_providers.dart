import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';

final purchasesListProvider = StreamProvider<List<PurchaseWishesData>>(
  (ref) => ref.watch(purchasesDaoProvider).watchAll(),
);
