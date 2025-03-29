import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'documentation_service.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _display = '0';
  String _currentNumber = '';
  String _operation = '';
  double? _firstNumber;
  bool _shouldClearDisplay = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldClearDisplay) {
        _display = number;
        _shouldClearDisplay = false;
      } else {
        if (_display == '0') {
          _display = number;
        } else {
          _display += number;
        }
      }
    });
  }

  void _onOperationPressed(String operation) {
    setState(() {
      if (_firstNumber == null) {
        _firstNumber = double.parse(_display);
      } else {
        _calculateResult();
      }
      _operation = operation;
      _shouldClearDisplay = true;
    });
  }

  void _calculateResult() {
    if (_firstNumber == null || _operation.isEmpty) return;

    double secondNumber = double.parse(_display);
    double result;

    switch (_operation) {
      case '+':
        result = _firstNumber! + secondNumber;
        break;
      case '-':
        result = _firstNumber! - secondNumber;
        break;
      case '×':
        result = _firstNumber! * secondNumber;
        break;
      case '÷':
        result = _firstNumber! / secondNumber;
        break;
      case '^':
        result = _firstNumber! * (secondNumber / 100);
        break;
      default:
        return;
    }

    setState(() {
      _display = result.toString();
      _firstNumber = result;
      _operation = '';
      _shouldClearDisplay = true;
    });
  }

  void _onEqualsPressed() {
    _calculateResult();
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _currentNumber = '';
      _operation = '';
      _firstNumber = null;
      _shouldClearDisplay = false;
    });
  }

  void _onDecimalPressed() {
    if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _onPercentPressed() {
    setState(() {
      double number = double.parse(_display);
      _display = (number / 100).toString();
      _shouldClearDisplay = true;
    });
  }

  void _onSquareRootPressed() {
    setState(() {
      double number = double.parse(_display);
      _display = (number * number).toString();
      _shouldClearDisplay = true;
    });
  }

  Widget _buildButton(String text, {Color? color, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[300],
            foregroundColor: color != null ? Colors.white : Colors.black,
            padding: const EdgeInsets.all(24.0),
          ),
          onPressed: onPressed,
          child: Text(text, style: const TextStyle(fontSize: 24.0)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentationScreen(),
                ),
              );
            },
            tooltip: 'View Documentation',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            child: Text(_display, style: const TextStyle(fontSize: 48.0)),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', onPressed: () => _onNumberPressed('7')),
                      _buildButton('8', onPressed: () => _onNumberPressed('8')),
                      _buildButton('9', onPressed: () => _onNumberPressed('9')),
                      _buildButton(
                        '÷',
                        onPressed: () => _onOperationPressed('÷'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4', onPressed: () => _onNumberPressed('4')),
                      _buildButton('5', onPressed: () => _onNumberPressed('5')),
                      _buildButton('6', onPressed: () => _onNumberPressed('6')),
                      _buildButton(
                        '×',
                        onPressed: () => _onOperationPressed('×'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1', onPressed: () => _onNumberPressed('1')),
                      _buildButton('2', onPressed: () => _onNumberPressed('2')),
                      _buildButton('3', onPressed: () => _onNumberPressed('3')),
                      _buildButton(
                        '-',
                        onPressed: () => _onOperationPressed('-'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0', onPressed: () => _onNumberPressed('0')),
                      _buildButton('.', onPressed: _onDecimalPressed),
                      _buildButton('=', onPressed: _onEqualsPressed),
                      _buildButton(
                        '+',
                        onPressed: () => _onOperationPressed('+'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', onPressed: _onClearPressed),
                      _buildButton('√', onPressed: _onSquareRootPressed),
                      _buildButton('%', onPressed: _onPercentPressed),
                      _buildButton(
                        '^',
                        onPressed: () => _onOperationPressed('^'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
