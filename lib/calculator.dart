import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' show pow, sqrt;
import 'documentation_service.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = '';
  String _result = '0';
  String _operation = '';
  double? _firstNumber;
  bool _shouldClearDisplay = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldClearDisplay) {
        _result = number;
        _shouldClearDisplay = false;
      } else {
        if (_result == '0') {
          _result = number;
        } else {
          _result += number;
        }
      }
      if (_operation.isNotEmpty) {
        _updateExpression();
      }
    });
  }

  void _updateExpression() {
    if (_operation.isNotEmpty && _firstNumber != null) {
      String formattedFirstNumber =
          _firstNumber!.truncateToDouble() == _firstNumber!
              ? _firstNumber!.toInt().toString()
              : _firstNumber!.toString();
      String formattedResult = _result;
      if (!_result.endsWith('%')) {
        formattedResult =
            double.parse(_result).truncateToDouble() == double.parse(_result)
                ? double.parse(_result).toInt().toString()
                : _result;
      }
      _expression = '$formattedFirstNumber$_operation$formattedResult';
    } else {
      _expression = _result;
    }
  }

  String _formatNumber(double number) {
    if (number.isInfinite || number.isNaN) {
      return 'Error';
    }

    // Если число целое и меньше 1e15, показываем его как есть
    if (number.truncateToDouble() == number && number.abs() < 1e15) {
      return number.toInt().toString();
    }

    // Для больших чисел используем toStringAsFixed с максимальной точностью
    return number.toStringAsFixed(10).replaceAll(RegExp(r'\.?0*$'), '');
  }

  void _onOperationPressed(String operation) {
    setState(() {
      try {
        if (_firstNumber == null) {
          // Если число заканчивается на %, вычисляем процент от числа
          if (_result.endsWith('%')) {
            double number = double.parse(_result.replaceAll('%', ''));
            _firstNumber = number / 100;
          } else {
            _firstNumber = double.parse(_result);
          }
        } else {
          _calculateResult();
        }
        _operation = operation;
        _shouldClearDisplay = true;
        String formattedFirstNumber = _formatNumber(_firstNumber!);
        _expression = '$formattedFirstNumber$_operation';
      } catch (e) {
        _result = 'Ошибка';
        _expression = '';
        _firstNumber = null;
        _operation = '';
        _shouldClearDisplay = true;
      }
    });
  }

  void _calculateResult() {
    if (_firstNumber == null) {
      try {
        // Если нет первого числа, просто вычисляем процент
        if (_result.endsWith('%')) {
          double number = double.parse(_result.replaceAll('%', ''));
          double result = number / 100;
          setState(() {
            _result = _formatNumber(result);
            _shouldClearDisplay = true;
            _expression = _result;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _result = 'Ошибка';
          _expression = '';
          _firstNumber = null;
          _operation = '';
          _shouldClearDisplay = true;
        });
        return;
      }
      return;
    }

    if (_operation.isEmpty) return;

    try {
      double secondNumber;
      if (_result.endsWith('%')) {
        // Если число заканчивается на %, вычисляем процент от первого числа
        secondNumber = double.parse(_result.replaceAll('%', ''));
        double result = _firstNumber! + (_firstNumber! * secondNumber / 100);
        _result = _formatNumber(result);
      } else {
        // Обычные вычисления
        secondNumber = double.parse(_result);
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
            if (secondNumber == 0) {
              throw Exception('Деление на ноль');
            }
            result = _firstNumber! / secondNumber;
            break;
          case '^':
            result = pow(_firstNumber!, secondNumber).toDouble();
            break;
          default:
            return;
        }

        _result = _formatNumber(result);
      }

      setState(() {
        _firstNumber = double.parse(_result);
        _operation = '';
        _shouldClearDisplay = true;
        _expression = _result;
      });
    } catch (e) {
      setState(() {
        _result = 'Ошибка';
        _expression = '';
        _firstNumber = null;
        _operation = '';
        _shouldClearDisplay = true;
      });
    }
  }

  void _onEqualsPressed() {
    _calculateResult();
  }

  void _onClearPressed() {
    setState(() {
      _result = '0';
      _expression = '';
      _operation = '';
      _firstNumber = null;
      _shouldClearDisplay = false;
    });
  }

  void _onDecimalPressed() {
    if (!_result.contains('.')) {
      setState(() {
        _result += '.';
        _updateExpression();
      });
    }
  }

  void _onPercentPressed() {
    setState(() {
      try {
        if (_operation.isNotEmpty) {
          // Если есть операция, добавляем % к текущему числу
          _result += '%';
          _updateExpression();
        } else {
          // Если нет операции, вычисляем процент от текущего результата
          double number = double.parse(_result);
          double result = number / 100;
          _result = _formatNumber(result);
          _shouldClearDisplay = true;
          _expression = _result;
        }
      } catch (e) {
        _result = 'Ошибка';
        _expression = '';
        _firstNumber = null;
        _operation = '';
        _shouldClearDisplay = true;
      }
    });
  }

  void _onSquareRootPressed() {
    setState(() {
      try {
        double number = double.parse(_result);
        if (number < 0) {
          throw Exception('Отрицательное число под корнем');
        }
        double result = sqrt(number);
        _result = _formatNumber(result);
        _shouldClearDisplay = true;
        _updateExpression();
      } catch (e) {
        _result = 'Ошибка';
        _expression = '';
        _firstNumber = null;
        _operation = '';
        _shouldClearDisplay = true;
      }
    });
  }

  Widget _buildButton(
    String text, {
    Color? color,
    VoidCallback? onPressed,
    bool isOperator = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF333333),
            foregroundColor: Colors.white,
            padding:
                isOperator
                    ? const EdgeInsets.all(
                      20.0,
                    ) // Увеличиваем padding для операторов
                    : const EdgeInsets.all(24.0), // Обычный padding для цифр
            shape:
                isOperator
                    ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        24,
                      ), // Сохраняем радиус закругления
                    )
                    : CircleBorder(),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize:
                  isOperator
                      ? 30.0
                      : 32.0, // Увеличиваем размер шрифта для операторов
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Калькулятор'),
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
            tooltip: 'Помощь',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            height: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _expression,
                      style: const TextStyle(
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 48.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildButton(
                        '^',
                        color: const Color(0xFF64B5F6),
                        onPressed: () => _onOperationPressed('^'),
                        isOperator: true,
                      ),
                      _buildButton(
                        '√',
                        color: const Color(0xFF64B5F6),
                        onPressed: _onSquareRootPressed,
                        isOperator: true,
                      ),
                      _buildButton(
                        '%',
                        color: const Color(0xFF64B5F6),
                        onPressed: _onPercentPressed,
                        isOperator: true,
                      ),
                      _buildButton(
                        '÷',
                        color: const Color(0xFF64B5F6),
                        onPressed: () => _onOperationPressed('÷'),
                        isOperator: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', onPressed: () => _onNumberPressed('7')),
                      _buildButton('8', onPressed: () => _onNumberPressed('8')),
                      _buildButton('9', onPressed: () => _onNumberPressed('9')),
                      _buildButton(
                        '×',
                        color: const Color(0xFF64B5F6),
                        onPressed: () => _onOperationPressed('×'),
                        isOperator: true,
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
                        '-',
                        color: const Color(0xFF64B5F6),
                        onPressed: () => _onOperationPressed('-'),
                        isOperator: true,
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
                        '+',
                        color: const Color(0xFF64B5F6),
                        onPressed: () => _onOperationPressed('+'),
                        isOperator: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('0', onPressed: () => _onNumberPressed('0')),
                      _buildButton('.', onPressed: _onDecimalPressed),
                      _buildButton(
                        'C',
                        color: const Color(0xFF1A237E),
                        onPressed: _onClearPressed,
                        isOperator: true,
                      ),
                      _buildButton(
                        '=',
                        color: const Color(0xFF64B5F6),
                        onPressed: _onEqualsPressed,
                        isOperator: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
