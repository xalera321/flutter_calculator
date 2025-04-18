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
  String _result = '0';
  String _expression = '';
  String? _operation;
  String? _firstNumber;
  bool _shouldClearDisplay = false;
  List<String> _numbers = [];
  List<String> _operations = [];
  bool _isNegative = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_shouldClearDisplay) {
        _result = _isNegative ? '-$number' : number;
        _shouldClearDisplay = false;
      } else {
        if (_result == '0' || _result == '-') {
          _result = _isNegative ? '-$number' : number;
        } else if (_result == '√') {
          _result = '√$number';
        } else {
          _result += number;
        }
      }
      if (_operation != null) {
        _updateExpression();
      } else {
        _expression = _result;
      }
    });
  }

  void _onOperationPressed(String operation) {
    if (_result.isEmpty || _result == '0') {
      if (operation == '-') {
        setState(() {
          _isNegative = true;
          _result = '-';
          _expression = '-';
        });
        return;
      }
      return;
    }

    setState(() {
      if (_firstNumber == null) {
        if (_result.endsWith('%')) {
          // Если первое число заканчивается на %, сохраняем его как есть
          _firstNumber = _result;
          _numbers.add(_result);
        } else {
          _firstNumber = _result;
          _numbers.add(_result);
        }
      } else {
        _numbers.add(_result);
      }
      _operation = operation;
      _operations.add(operation);
      _result = '';
      _isNegative = false;
      _updateExpression();
    });
  }

  void _updateExpression() {
    String expression = '';
    for (int i = 0; i < _numbers.length; i++) {
      if (_numbers[i].startsWith('√')) {
        try {
          double number = double.parse(_numbers[i].substring(1));
          if (number < 0) {
            throw Exception('Отрицательное число под корнем');
          }
          expression += '√${number.toInt()}';
        } catch (e) {
          expression += _numbers[i];
        }
      } else {
        expression += _numbers[i];
      }
      if (i < _operations.length) {
        expression += ' ${_operations[i]} ';
      }
    }
    if (_result.isNotEmpty) {
      expression += _result;
    }
    _expression = expression;
  }

  void _calculateResult() {
    if (_result.isEmpty || _firstNumber == null || _operation == null) {
      // Если нет операции, но есть квадратный корень, вычисляем его
      if (_result.startsWith('√')) {
        try {
          double number = double.parse(_result.substring(1));
          if (number < 0) {
            throw Exception('Отрицательное число под корнем');
          }
          double result = sqrt(number);
          _result = _formatNumber(result);
          _expression = '√${number.toInt()} =';
          _clearAll();
          return;
        } catch (e) {
          _result = 'Ошибка';
          _expression = '';
          _clearAll();
          return;
        }
      }
      return;
    }

    setState(() {
      String currentNumber = _result;
      _updateExpression();
      _expression += ' =';

      // Обрабатываем первое число
      double result;
      if (_numbers[0].startsWith('√')) {
        double number = double.parse(_numbers[0].substring(1));
        if (number < 0) {
          _result = 'Ошибка';
          _clearAll();
          return;
        }
        result = sqrt(number);
      } else if (_numbers[0].endsWith('%')) {
        // Если первое число - процент, нам нужно дождаться второго числа
        double percentValue =
            double.parse(_numbers[0].substring(0, _numbers[0].length - 1));
        // Получаем второе число (текущее число)
        double nextNumber;
        if (currentNumber.startsWith('√')) {
          nextNumber = sqrt(double.parse(currentNumber.substring(1)));
        } else {
          nextNumber = double.parse(currentNumber);
        }
        // Вычисляем процент от второго числа
        result = nextNumber;
        double percentAmount = (nextNumber * percentValue) / 100;

        // В зависимости от операции применяем процент
        String operation = _operations[0];
        switch (operation) {
          case '+':
            result = nextNumber + percentAmount;
            break;
          case '-':
            result = nextNumber - percentAmount;
            break;
          case '×':
            result = percentAmount;
            break;
          case '÷':
            if (percentValue == 0) {
              _result = 'Ошибка';
              _clearAll();
              return;
            }
            result = (nextNumber * 100) / percentValue;
            break;
          default:
            result = nextNumber + percentAmount;
        }
      } else {
        result = double.parse(_numbers[0]);
      }

      // Обрабатываем все числа и операции
      for (int i = 1; i < _numbers.length; i++) {
        double number;
        if (_numbers[i].startsWith('√')) {
          number = double.parse(_numbers[i].substring(1));
          if (number < 0) {
            _result = 'Ошибка';
            _clearAll();
            return;
          }
          number = sqrt(number);
        } else if (_numbers[i].endsWith('%')) {
          number =
              double.parse(_numbers[i].substring(0, _numbers[i].length - 1));
        } else {
          number = double.parse(_numbers[i]);
        }
        String operation = _operations[i - 1];

        switch (operation) {
          case '+':
            result += number;
            break;
          case '-':
            result -= number;
            break;
          case '×':
            result *= number;
            break;
          case '÷':
            if (number == 0) {
              _result = 'Ошибка';
              _clearAll();
              return;
            }
            result /= number;
            break;
          case '%':
            result = (result * number) / 100;
            break;
          case '^':
            result = pow(result, number).toDouble();
            break;
        }
      }

      // Обрабатываем последнее число
      double lastNumber;
      if (currentNumber.endsWith('%')) {
        lastNumber =
            double.parse(currentNumber.substring(0, currentNumber.length - 1));
        String lastOperation = _operations.last;
        switch (lastOperation) {
          case '+':
            result += (result * lastNumber / 100);
            break;
          case '-':
            result -= (result * lastNumber / 100);
            break;
          case '×':
            result = (result * lastNumber) / 100;
            break;
          case '÷':
            if (lastNumber == 0) {
              _result = 'Ошибка';
              _clearAll();
              return;
            }
            result = (result * 100) / lastNumber;
            break;
          case '%':
            result = (result * lastNumber) / 100;
            break;
          case '^':
            result = pow(result, lastNumber).toDouble();
            break;
        }
      } else if (currentNumber.startsWith('√')) {
        lastNumber = double.parse(currentNumber.substring(1));
        if (lastNumber < 0) {
          _result = 'Ошибка';
          _clearAll();
          return;
        }
        lastNumber = sqrt(lastNumber);
        String lastOperation = _operations.last;

        switch (lastOperation) {
          case '+':
            result += lastNumber;
            break;
          case '-':
            result -= lastNumber;
            break;
          case '×':
            result *= lastNumber;
            break;
          case '÷':
            if (lastNumber == 0) {
              _result = 'Ошибка';
              _clearAll();
              return;
            }
            result /= lastNumber;
            break;
          case '%':
            result = (result * lastNumber) / 100;
            break;
          case '^':
            result = pow(result, lastNumber).toDouble();
            break;
        }
      } else {
        lastNumber = double.parse(currentNumber);
        String lastOperation = _operations.last;

        switch (lastOperation) {
          case '+':
            result += lastNumber;
            break;
          case '-':
            result -= lastNumber;
            break;
          case '×':
            result *= lastNumber;
            break;
          case '÷':
            if (lastNumber == 0) {
              _result = 'Ошибка';
              _clearAll();
              return;
            }
            result /= lastNumber;
            break;
          case '%':
            result = (result * lastNumber) / 100;
            break;
          case '^':
            result = pow(result, lastNumber).toDouble();
            break;
        }
      }

      _result = _formatNumber(result);
      _clearAll();
    });
  }

  void _clearAll() {
    _firstNumber = null;
    _operation = null;
    _numbers.clear();
    _operations.clear();
    _shouldClearDisplay = true;
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

  void _onEqualsPressed() {
    if (_result.startsWith('√')) {
      try {
        double number = double.parse(_result.substring(1));
        if (number < 0) {
          throw Exception('Отрицательное число под корнем');
        }
        double result = sqrt(number);
        setState(() {
          _result = _formatNumber(result);
          _expression = '√${number.toInt()} =';
          _clearAll();
        });
        return;
      } catch (e) {
        setState(() {
          _result = 'Ошибка';
          _expression = '';
          _clearAll();
        });
        return;
      }
    }
    _calculateResult();
  }

  void _onClearPressed() {
    setState(() {
      _result = '0';
      _expression = '';
      _isNegative = false;
      _firstNumber = null;
      _operation = null;
      _numbers.clear();
      _operations.clear();
      _shouldClearDisplay = true;
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
    if (_result.isEmpty) return;

    setState(() {
      if (_operation != null) {
        _result += '%';
        _updateExpression();
      } else {
        _result += '%';
        _updateExpression();
      }
    });
  }

  void _onSquareRootPressed() {
    setState(() {
      if (_result.isEmpty || _result == '0') {
        _result = '√';
        _expression = '√';
        _shouldClearDisplay = false;
        return;
      }
      try {
        if (_result.startsWith('√')) {
          double number = double.parse(_result.substring(1));
          if (number < 0) {
            throw Exception('Отрицательное число под корнем');
          }
          double result = sqrt(number);
          _result = _formatNumber(result);
          _expression = '√$number = $result';
          _clearAll();
          return;
        }
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
        _operation = null;
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
            padding: isOperator
                ? const EdgeInsets.all(
                    20.0,
                  ) // Увеличиваем padding для операторов
                : const EdgeInsets.all(24.0), // Обычный padding для цифр
            shape: isOperator
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
              fontSize: isOperator
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
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.centerRight,
            height: 140,
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
