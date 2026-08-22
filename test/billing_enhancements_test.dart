import 'package:flutter_test/flutter_test.dart';
import 'package:ssma/utils/sale_metadata.dart';
import 'package:ssma/utils/search_utils.dart';

void main() {
  group('SearchUtils', () {
    test('matches omitted middle words and punctuation differences', () {
      final results = SearchUtils.fuzzySort<String>(
        ['6 no. biscuit open', '6 no closed', 'open wire pack'],
        '6 no open',
        (item) => item,
      );

      expect(results.first, '6 no. biscuit open');
    });

    test('partial party searches match names and phones', () {
      final results = SearchUtils.fuzzySort<String>(
        ['Recent Electronics 9810159367', 'Surana Traders 111'],
        'recent 9810',
        (item) => item,
      );

      expect(results, contains('Recent Electronics 9810159367'));
    });
  });

  group('SaleMetadata', () {
    test('stores and restores split payment methods', () {
      final comment = SaleMetadata.compose(
        visibleComment: 'Deliver tomorrow',
        billingMode: 'ledger',
        payments: const [
          SalePaymentEntry(method: 'Cash', amount: 5000),
          SalePaymentEntry(method: 'UPI', amount: 3000),
          SalePaymentEntry(method: 'Bank Transfer', amount: 2000),
        ],
      );

      final metadata = SaleMetadata.parse(comment);

      expect(metadata.visibleComment, 'Deliver tomorrow');
      expect(metadata.billingMode, 'ledger');
      expect(metadata.paymentTotal, 10000);
      expect(metadata.payments.map((payment) => payment.method),
          ['Cash', 'UPI', 'Bank Transfer']);
    });

    test('keeps old comments readable when no metadata exists', () {
      final metadata = SaleMetadata.parse('Plain old note');

      expect(metadata.visibleComment, 'Plain old note');
      expect(metadata.payments, isEmpty);
      expect(metadata.billingMode, 'creditDebit');
    });
  });
}
