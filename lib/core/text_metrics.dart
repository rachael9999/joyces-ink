class TextMetrics {
  // Multilingual word count:
  // - Latin/space-delimited scripts: count whitespace-delimited tokens
  // - CJK (Han, Hiragana, Katakana) & Hangul: count characters individually
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;

    // CJK Unified Ideographs + Ext A + Compatibility Ideographs
    final cjk = RegExp(r"[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]");
    // Hiragana + Katakana + Halfwidth Katakana
    final hiraKata = RegExp(r"[\u3040-\u309F\u30A0-\u30FF\uFF66-\uFF9D]");
    // Hangul syllables
    final hangul = RegExp(r"[\uAC00-\uD7A3]");

    final cjkCount = cjk.allMatches(text).length;
    final hkCount = hiraKata.allMatches(text).length;
    final hangulCount = hangul.allMatches(text).length;

    // Remove CJK/Hiragana/Katakana/Hangul and split the rest by whitespace
    final removed = text
        .replaceAll(cjk, ' ')
        .replaceAll(hiraKata, ' ')
        .replaceAll(hangul, ' ');

    final nonCjkTokens = removed.trim().isEmpty
        ? 0
        : removed
            .trim()
            .split(RegExp(r"\s+"))
            .where((t) => t.isNotEmpty)
            .length;

    return nonCjkTokens + cjkCount + hkCount + hangulCount;
  }
}
