import 'package:flutter/material.dart';

void main() => runApp(CalculatriceApp());

class CalculatriceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: Calculatrice(),
    );
  }
}

class Calculatrice extends StatefulWidget {
  @override
  _CalculatriceState createState() => _CalculatriceState();
}

class _CalculatriceState extends State<Calculatrice> {
  String _output = "0";  // Valeur affichée en résultat
  String _expression = ""; // Expression complète en cours
  List<String> _history = []; // Historique des calculs
  int _parenthesesCount = 0; // Compteur de parenthèses ouvertes
  bool _lastPressedEquals = false; // Flag pour savoir si le dernier bouton pressé était "="

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculatrice Flutter'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // Partie affichage
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24.0),
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Affichage de l'expression en cours
                  Container(
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Affichage du résultat
                  Text(
                    _output,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Affichage de l'historique
                  SizedBox(height: 20),
                  Container(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            _history.reversed.toList()[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Partie boutons
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: 20,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                List<String> buttons = [
                  '(', ')', 'C', '⌫',
                  '7', '8', '9', '/',
                  '4', '5', '6', '*',
                  '1', '2', '3', '-',
                  '0', '.', '=', '+'
                ];

                // Déterminer la couleur des boutons
                Color buttonColor;
                if (buttons[index] == 'C' || buttons[index] == '⌫') {
                  buttonColor = Colors.red;
                } else if (buttons[index] == '=') {
                  buttonColor = Colors.green;
                } else if (buttons[index] == '/' ||
                    buttons[index] == '*' ||
                    buttons[index] == '-' ||
                    buttons[index] == '+' ||
                    buttons[index] == '(' ||
                    buttons[index] == ')') {
                  buttonColor = Colors.blue;
                } else {
                  buttonColor = Colors.grey.shade300;
                }

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {
                      boutonAppuye(buttons[index]);
                    },
                    child: Text(
                      buttons[index],
                      style: TextStyle(
                        fontSize: 24,
                        color: (buttons[index] == '/' ||
                            buttons[index] == '*' ||
                            buttons[index] == '-' ||
                            buttons[index] == '+' ||
                            buttons[index] == 'C' ||
                            buttons[index] == '=' ||
                            buttons[index] == '(' ||
                            buttons[index] == ')' ||
                            buttons[index] == '⌫') ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void boutonAppuye(String bouton) {
    setState(() {
      // Si on appuie sur "C", réinitialiser la calculatrice
      if (bouton == "C") {
        _output = "0";
        _expression = "";
        _parenthesesCount = 0;
        _lastPressedEquals = false;
      }
      // Si on appuie sur "⌫" (effacer)
      else if (bouton == "⌫") {
        if (_expression.isNotEmpty) {
          // Mise à jour du compteur de parenthèses
          if (_expression.endsWith('(')) {
            _parenthesesCount--;
          } else if (_expression.endsWith(')')) {
            _parenthesesCount++;
          }

          _expression = _expression.substring(0, _expression.length - 1);
          if (_expression.isEmpty) {
            _output = "0";
          }
        }
      }
      // Si on appuie sur "="
      else if (bouton == "=") {
        try {
          // Fermer les parenthèses manquantes
          String expressionToEvaluate = _expression;
          for (int i = 0; i < _parenthesesCount; i++) {
            expressionToEvaluate += ')';
          }

          // Évaluer l'expression
          double result = evaluateExpression(expressionToEvaluate);

          // Formater le résultat avec arrondi à 4 décimales
          String formattedResult;
          if (result == result.toInt()) {
            // Si le résultat est un entier, pas besoin de décimales
            formattedResult = result.toInt().toString();
          } else {
            // Arrondir à 4 décimales pour éviter l'overflow
            formattedResult = result.toStringAsFixed(4);
            // Supprimer les zéros finaux inutiles
            while (formattedResult.endsWith('0')) {
              formattedResult = formattedResult.substring(0, formattedResult.length - 1);
            }
            // Supprimer le point décimal s'il est en fin de chaîne
            if (formattedResult.endsWith('.')) {
              formattedResult = formattedResult.substring(0, formattedResult.length - 1);
            }
          }

          // Ajouter à l'historique
          _history.add("$expressionToEvaluate = $formattedResult");
          if (_history.length > 10) {
            _history.removeAt(0);
          }

          // Mettre à jour les affichages
          _output = formattedResult;
          _expression = formattedResult;
          _parenthesesCount = 0;
          _lastPressedEquals = true;
        } catch (e) {
          _output = "Erreur";
        }
      }
      // Si on appuie sur "("
      else if (bouton == "(") {
        if (_expression.isEmpty ||
            isOperator(_expression[_expression.length - 1]) ||
            _expression[_expression.length - 1] == '(') {
          _expression += bouton;
          _parenthesesCount++;
        }
      }
      // Si on appuie sur ")"
      else if (bouton == ")") {
        if (_parenthesesCount > 0 && !isOperator(_expression[_expression.length - 1])) {
          _expression += bouton;
          _parenthesesCount--;
        }
      }
      // Si on appuie sur un opérateur
      else if (isOperator(bouton)) {
        _lastPressedEquals = false; // Réinitialiser le flag puisque nous continuons le calcul

        if (_expression.isNotEmpty && !isOperator(_expression[_expression.length - 1]) && _expression[_expression.length - 1] != '(') {
          _expression += bouton;
        } else if (_expression.isEmpty && bouton == '-') {
          // Permettre le signe négatif au début
          _expression += bouton;
        } else if (_expression.isNotEmpty && _expression[_expression.length - 1] != '(' && isOperator(_expression[_expression.length - 1])) {
          // Remplacer l'opérateur existant
          _expression = _expression.substring(0, _expression.length - 1) + bouton;
        }
      }
      // Si on appuie sur un point décimal
      else if (bouton == ".") {
        if (_expression.isEmpty) {
          _expression = "0.";
        } else {
          // Vérifier si le dernier nombre contient déjà un point
          bool canAddDecimal = true;
          for (int i = _expression.length - 1; i >= 0; i--) {
            if (_expression[i] == '.') {
              canAddDecimal = false;
              break;
            }
            if (isOperator(_expression[i]) || _expression[i] == '(' || _expression[i] == ')') {
              break;
            }
          }

          if (canAddDecimal) {
            if (isOperator(_expression[_expression.length - 1]) ||
                _expression[_expression.length - 1] == '(' ||
                _expression[_expression.length - 1] == ')') {
              _expression += "0.";
            } else {
              _expression += ".";
            }
          }
        }
      }
      // Si on appuie sur un chiffre
      else {
        _expression += bouton;

        try {
          // Essayer d'évaluer l'expression pour fournir un feedback immédiat
          double result = evaluateExpression(_expression);

          // Formater le résultat avec arrondi à 4 décimales
          String formattedResult;
          if (result == result.toInt()) {
            // Si le résultat est un entier, pas besoin de décimales
            formattedResult = result.toInt().toString();
          } else {
            // Arrondir à 4 décimales pour éviter l'overflow
            formattedResult = result.toStringAsFixed(4);
            // Supprimer les zéros finaux inutiles
            while (formattedResult.endsWith('0')) {
              formattedResult = formattedResult.substring(0, formattedResult.length - 1);
            }
            // Supprimer le point décimal s'il est en fin de chaîne
            if (formattedResult.endsWith('.')) {
              formattedResult = formattedResult.substring(0, formattedResult.length - 1);
            }
          }

          _output = formattedResult;
        } catch (e) {
          // Si l'expression n'est pas encore complète, afficher simplement le nombre en cours
          _output = _expression;
        }
      }
    });
  }

  // Vérifier si un caractère est un opérateur
  bool isOperator(String char) {
    return char == '+' || char == '-' || char == '*' || char == '/';
  }

  // Évaluer une expression mathématique
  double evaluateExpression(String expression) {
    // Cette méthode implémente un évaluateur d'expression simple
    // Note: Dans une application réelle, on pourrait utiliser une bibliothèque dédiée

    // Fonction pour évaluer une sous-expression sans parenthèses
    double evaluateSimpleExpression(String expr) {
      // Traiter d'abord les multiplications et divisions
      List<String> tokens = tokenizeExpression(expr);

      // Première passe: multiplications et divisions
      for (int i = 1; i < tokens.length - 1; i += 2) {
        if (tokens[i] == "*" || tokens[i] == "/") {
          double a = double.parse(tokens[i - 1]);
          double b = double.parse(tokens[i + 1]);
          double result;

          if (tokens[i] == "*") {
            result = a * b;
          } else {
            if (b == 0) throw Exception("Division par zéro");
            result = a / b;
          }

          tokens[i - 1] = result.toString();
          tokens.removeAt(i);
          tokens.removeAt(i);
          i -= 2;
        }
      }

      // Deuxième passe: additions et soustractions
      double result = double.parse(tokens[0]);
      for (int i = 1; i < tokens.length; i += 2) {
        double b = double.parse(tokens[i + 1]);

        if (tokens[i] == "+") {
          result += b;
        } else if (tokens[i] == "-") {
          result -= b;
        }
      }

      return result;
    }

    // Traiter les parenthèses récursivement
    while (expression.contains('(')) {
      int startIndex = expression.lastIndexOf('(');
      int endIndex = expression.indexOf(')', startIndex);

      if (endIndex == -1) throw Exception("Parenthèses mal formées");

      String subExpr = expression.substring(startIndex + 1, endIndex);
      double subResult = evaluateSimpleExpression(subExpr);

      expression = expression.substring(0, startIndex) +
          subResult.toString() +
          expression.substring(endIndex + 1);
    }

    return evaluateSimpleExpression(expression);
  }

  // Segmenter une expression en tokens (nombres et opérateurs)
  List<String> tokenizeExpression(String expr) {
    List<String> tokens = [];
    String currentNumber = "";

    for (int i = 0; i < expr.length; i++) {
      if (isOperator(expr[i])) {
        // Cas spécial: signe négatif au début ou après un opérateur
        if (expr[i] == '-' && (i == 0 || isOperator(expr[i-1]) || expr[i-1] == '(')) {
          currentNumber += expr[i];
        } else {
          if (currentNumber.isNotEmpty) {
            tokens.add(currentNumber);
            currentNumber = "";
          }
          tokens.add(expr[i]);
        }
      } else if (expr[i] == '(' || expr[i] == ')') {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = "";
        }
      } else {
        currentNumber += expr[i];
      }
    }

    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    return tokens;
  }
}