class SearchUtils {
  SearchUtils._();

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static int fuzzyScore(String text, String query) {
    if (query.trim().isEmpty) return 1;
    final normalizedText = normalize(text);
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return 0;
    if (normalizedText == normalizedQuery) return 10000;
    if (normalizedText.contains(normalizedQuery)) {
      final index = normalizedText.indexOf(normalizedQuery);
      return index < 7900 ? 8000 - index : 100;
    }

    final textTokens =
        normalizedText.split(' ').where((e) => e.isNotEmpty).toList();
    final queryTokens =
        normalizedQuery.split(' ').where((e) => e.isNotEmpty).toList();
    if (queryTokens.isEmpty) return 0;

    var score = 0;
    var lastIndex = -1;
    for (final queryToken in queryTokens) {
      var bestTokenScore = 0;
      var bestIndex = -1;
      for (var i = 0; i < textTokens.length; i++) {
        final token = textTokens[i];
        var tokenScore = 0;
        if (token == queryToken) {
          tokenScore = 1000;
        } else if (token.startsWith(queryToken)) {
          tokenScore = 800;
        } else if (token.contains(queryToken)) {
          tokenScore = 600;
        } else if (queryToken.contains(token) && token.length >= 2) {
          tokenScore = 350;
        }
        if (tokenScore > bestTokenScore) {
          bestTokenScore = tokenScore;
          bestIndex = i;
        }
      }

      if (bestTokenScore == 0) return 0;
      if (lastIndex != -1 && bestIndex > lastIndex) {
        bestTokenScore += 50;
      }
      lastIndex = bestIndex;
      score += bestTokenScore;
    }

    final finalScore = score - textTokens.length;
    return finalScore > 0 ? finalScore : 1;
  }

  static List<T> fuzzySort<T>(
    Iterable<T> items,
    String query,
    String Function(T item) textOf,
  ) {
    final scored = <({T item, int score})>[];
    for (final item in items) {
      final score = fuzzyScore(textOf(item), query);
      if (score > 0) scored.add((item: item, score: score));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return textOf(a.item)
          .toLowerCase()
          .compareTo(textOf(b.item).toLowerCase());
    });
    return scored.map((entry) => entry.item).toList();
  }
}
