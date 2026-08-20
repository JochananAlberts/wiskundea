class MathParser {
  /// Normaliseert een wiskundige invoerstring door spaties, unicode tekens en syntax te standaardiseren.
  static String normalize(String input) {
    String s = input.trim().toLowerCase();

    // Spaties verwijderen
    s = s.replaceAll(' ', '');

    // Unicode exponenten converteren
    s = s.replaceAll('⁰', '^0');
    s = s.replaceAll('¹', '^1');
    s = s.replaceAll('²', '^2');
    s = s.replaceAll('³', '^3');
    s = s.replaceAll('⁴', '^4');
    s = s.replaceAll('⁵', '^5');
    s = s.replaceAll('⁶', '^6');
    s = s.replaceAll('⁷', '^7');
    s = s.replaceAll('⁸', '^8');
    s = s.replaceAll('⁹', '^9');

    // Vermenigvuldigingstekens
    s = s.replaceAll('·', '*');
    s = s.replaceAll('×', '*');

    // Ongelijkheden tekens
    s = s.replaceAll('≤', '<=');
    s = s.replaceAll('≥', '>=');
    s = s.replaceAll(r'\le', '<=');
    s = s.replaceAll(r'\ge', '>=');

    // Dubbele tekens herleiden
    s = s.replaceAll('+-', '-');
    s = s.replaceAll('-+', '-');
    s = s.replaceAll('--', '+');
    s = s.replaceAll('++', '+');

    // Exponent 1 vereenvoudigen: x^1 -> x
    s = s.replaceAll(RegExp(r'\^1(?![0-9])'), '');

    return s;
  }

  /// Controleert of de invoer algebraïsch equivalent is aan het antwoord.
  static bool isEquivalent({
    required String userInput,
    required String canonicalAnswer,
    List<String> acceptedAlternatives = const [],
    String variable = 'x',
  }) {
    final cleanUser = normalize(userInput);
    final cleanCanonical = normalize(canonicalAnswer);

    // Directe match
    if (cleanUser == cleanCanonical) return true;

    // Alternatieven check
    for (final alt in acceptedAlternatives) {
      if (cleanUser == normalize(alt)) return true;
    }

    // Termen volgorde-onafhankelijke check voor veeltermen (bijv. 6a^2 - ab - 15b^2 vs 6a^2 - 15b^2 - ab)
    if (_matchesTermSet(cleanUser, cleanCanonical)) return true;

    for (final alt in acceptedAlternatives) {
      if (_matchesTermSet(cleanUser, normalize(alt))) return true;
    }

    return false;
  }

  /// Controleert of twee expressies exact dezelfde verzameling termen bevatten (ongeacht volgorde).
  static bool _matchesTermSet(String expr1, String expr2) {
    final terms1 = _splitIntoTerms(expr1);
    final terms2 = _splitIntoTerms(expr2);

    if (terms1.length != terms2.length || terms1.isEmpty) return false;

    terms1.sort();
    terms2.sort();

    for (int i = 0; i < terms1.length; i++) {
      if (terms1[i] != terms2[i]) return false;
    }
    return true;
  }

  /// Splitst een algebraïsche expressie in losse termen met hun tekens (+ of -)
  static List<String> _splitIntoTerms(String expr) {
    if (expr.isEmpty) return [];

    final List<String> terms = [];
    int start = 0;

    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];
      if ((char == '+' || char == '-') && i > 0 && expr[i - 1] != '^' && expr[i - 1] != '(' && expr[i - 1] != '*') {
        terms.add(_cleanTerm(expr.substring(start, i)));
        start = i;
      }
    }
    if (start < expr.length) {
      terms.add(_cleanTerm(expr.substring(start)));
    }

    return terms;
  }

  static String _cleanTerm(String term) {
    var t = term.trim();
    if (t.startsWith('+')) t = t.substring(1);
    return t;
  }

  /// Evalueert een getypt antwoord voor een vergelijking (bijv. "x = 5" of "5" of "t = -3.33").
  static EquationValidationResult validateEquationAnswer({
    required String userInput,
    required String variable,
    required double targetAnswer,
  }) {
    String clean = normalize(userInput);

    // Als de gebruiker bijv. "x = 5" of "5" heeft ingetypt
    double? parsedValue;

    if (clean.contains('=')) {
      final parts = clean.split('=');
      if (parts.length == 2) {
        final left = parts[0].trim();
        final right = parts[1].trim();

        if (left == variable) {
          parsedValue = _parseNumberOrFraction(right);
        } else if (right == variable) {
          parsedValue = _parseNumberOrFraction(left);
        }
      }
    } else {
      parsedValue = _parseNumberOrFraction(clean);
    }

    if (parsedValue == null) {
      return EquationValidationResult(
        isValid: false,
        isFinalSolution: false,
        feedback: "Typ het antwoord in de vorm '$variable = ...' (bijv. $variable = 5).",
      );
    }

    // Tolerantie voor afronding op 2 decimalen (bijv. 7.07 vs 7.0714...)
    final double diff = (parsedValue - targetAnswer).abs();
    final bool isCorrect = diff < 0.03;

    if (isCorrect) {
      return EquationValidationResult(
        isValid: true,
        isFinalSolution: true,
        feedback: "🎉 Uitstekend! Vergelijking correct opgelost!",
      );
    } else {
      return EquationValidationResult(
        isValid: false,
        isFinalSolution: false,
        feedback: "Het berekende antwoord ($parsedValue) klopt niet. Controleer je tussenstappen.",
      );
    }
  }

  /// Evalueert een getypte ongelijkheid (bijv. "t < 3", "x >= -3.33", "t \le 4").
  static InequalityValidationResult validateInequalityAnswer({
    required String userInput,
    required String variable,
    required String expectedOperator, // '<', '>', '<=', '>='
    required double targetValue,
  }) {
    final String clean = normalize(userInput);

    String? foundOp;
    if (clean.contains('<=')) {
      foundOp = '<=';
    } else if (clean.contains('>=')) {
      foundOp = '>=';
    } else if (clean.contains('<')) {
      foundOp = '<';
    } else if (clean.contains('>')) {
      foundOp = '>';
    }

    if (foundOp == null || !clean.contains(variable)) {
      return InequalityValidationResult(
        isValid: false,
        feedback: "Typ je antwoord als '$variable $expectedOperator [waarde]' (bijv. $variable $expectedOperator 3).",
      );
    }

    final parts = clean.split(foundOp);
    if (parts.length != 2) {
      return InequalityValidationResult(
        isValid: false,
        feedback: "Ongeldige opbouw van de ongelijkheid.",
      );
    }

    final double? parsedVal = _parseNumberOrFraction(parts[1]);
    if (parsedVal == null) {
      return InequalityValidationResult(
        isValid: false,
        feedback: "Kon het getal '${parts[1]}' niet herkennen.",
      );
    }

    // Check operator
    final normExpectedOp = normalize(expectedOperator);
    if (foundOp != normExpectedOp) {
      // Specifieke didactische hint als het teken niet is omgeklapt!
      if ((foundOp == '>' && normExpectedOp == '<') ||
          (foundOp == '<' && normExpectedOp == '>') ||
          (foundOp == '>=' && normExpectedOp == '<=') ||
          (foundOp == '<=' && normExpectedOp == '>=')) {
        return InequalityValidationResult(
          isValid: false,
          feedback: "⚠️ Let op de klapregel: heb je gedeeld door een negatief getal? Dan klapt het teken om!",
        );
      }
      return InequalityValidationResult(
        isValid: false,
        feedback: "Het ongelijkheidsteken ($foundOp) is niet juist.",
      );
    }

    // Check waarde met 0.03 tolerantie voor 2 decimalen
    final double diff = (parsedVal - targetValue).abs();
    if (diff < 0.03) {
      return InequalityValidationResult(
        isValid: true,
        feedback: "🎉 Uitstekend! Ongelijkheid correct opgelost!",
      );
    } else {
      return InequalityValidationResult(
        isValid: false,
        feedback: "Het berekende getal ($parsedVal) klopt niet. Controleer je berekening.",
      );
    }
  }

  static double? _parseNumberOrFraction(String str) {
    final s = str.trim().replaceAll(',', '.');
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 2) {
        final num = double.tryParse(parts[0]);
        final den = double.tryParse(parts[1]);
        if (num != null && den != null && den != 0) {
          return num / den;
        }
      }
    }
    return double.tryParse(s);
  }
}

class EquationValidationResult {
  final bool isValid;
  final bool isFinalSolution;
  final String feedback;

  EquationValidationResult({
    required this.isValid,
    required this.isFinalSolution,
    required this.feedback,
  });
}

class InequalityValidationResult {
  final bool isValid;
  final String feedback;

  InequalityValidationResult({
    required this.isValid,
    required this.feedback,
  });
}
