import 'dart:convert';

class SalePaymentEntry {
  final String method;
  final double amount;

  const SalePaymentEntry({
    required this.method,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'amount': amount,
      };

  static SalePaymentEntry fromJson(Map<String, dynamic> json) {
    return SalePaymentEntry(
      method: json['method'] as String? ?? 'Payment',
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }
}

class SaleMetadata {
  static const _marker = '__SSMA_META__';

  final String? visibleComment;
  final List<SalePaymentEntry> payments;
  final String billingMode;

  const SaleMetadata({
    this.visibleComment,
    this.payments = const [],
    this.billingMode = 'creditDebit',
  });

  double get paymentTotal =>
      payments.fold(0.0, (sum, payment) => sum + payment.amount);

  static SaleMetadata parse(String? comment) {
    if (comment == null || !comment.contains(_marker)) {
      return SaleMetadata(visibleComment: comment);
    }

    final markerIndex = comment.lastIndexOf(_marker);
    final visible = comment.substring(0, markerIndex).trim();
    final rawJson = comment.substring(markerIndex + _marker.length).trim();

    try {
      final json = jsonDecode(rawJson) as Map<String, dynamic>;
      final paymentsJson = json['payments'] as List<dynamic>? ?? [];
      return SaleMetadata(
        visibleComment: visible.isEmpty ? null : visible,
        billingMode: json['billingMode'] as String? ?? 'creditDebit',
        payments: paymentsJson
            .map((entry) => SalePaymentEntry.fromJson(
                Map<String, dynamic>.from(entry as Map)))
            .where((entry) => entry.amount > 0)
            .toList(),
      );
    } catch (_) {
      return SaleMetadata(visibleComment: comment);
    }
  }

  static String? compose({
    required String? visibleComment,
    required List<SalePaymentEntry> payments,
    required String billingMode,
  }) {
    final cleanComment = visibleComment?.trim() ?? '';
    final hasMetadata = payments.isNotEmpty || billingMode != 'creditDebit';
    if (!hasMetadata) return cleanComment.isEmpty ? null : cleanComment;

    final payload = jsonEncode({
      'billingMode': billingMode,
      'payments': payments.map((payment) => payment.toJson()).toList(),
    });

    if (cleanComment.isEmpty) return '$_marker$payload';
    return '$cleanComment\n$_marker$payload';
  }
}
