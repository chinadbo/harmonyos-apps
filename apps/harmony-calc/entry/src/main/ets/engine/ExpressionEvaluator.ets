export type AngleMode = 'deg' | 'rad';

type TokenType = 'number' | 'operator' | 'function' | 'leftParen' | 'rightParen';

class Token {
  type: TokenType;
  value: string;

  constructor(type: TokenType, value: string) {
    this.type = type;
    this.value = value;
  }
}

export class ExpressionEvaluator {
  private static readonly FUNCTIONS: Array<string> = ['sin', 'cos', 'tan', 'log', 'ln', 'sqrt', 'abs', 'factorial'];
  private static readonly PRECEDENCE: Record<string, number> = {
    '!': 6,
    '^': 5,
    '~': 4,
    '*': 3,
    '/': 3,
    '%': 3,
    '+': 2,
    '-': 2
  };
  private static readonly RIGHT_ASSOCIATIVE: Array<string> = ['^', '~'];

  static evaluate(expression: string, angleMode: AngleMode = 'deg'): number {
    const tokens: Array<Token> = this.tokenize(expression);
    const rpn: Array<Token> = this.toRpn(tokens);
    return this.evaluateRpn(rpn, angleMode);
  }

  static evaluateToString(expression: string, angleMode: AngleMode = 'deg'): string {
    const result = this.evaluate(expression, angleMode);
    if (!isFinite(result)) {
      throw new Error('结果无效');
    }
    if (Math.abs(result) < 1e-12) {
      return '0';
    }
    if (Math.abs(result) >= 1e12 || (Math.abs(result) > 0 && Math.abs(result) < 1e-9)) {
      return result.toExponential(8).replace(/\.0+e/, 'e').replace(/(\.\d*?[1-9])0+e/, '$1e');
    }
    return result.toFixed(12).replace(/\.0+$/, '').replace(/(\.\d*?[1-9])0+$/, '$1');
  }

  private static tokenize(expression: string): Array<Token> {
    const normalized: string = expression.replace(/×/g, '*').replace(/÷/g, '/').replace(/−/g, '-').replace(/\s+/g, '');
    const tokens: Array<Token> = [];
    let index: number = 0;

    while (index < normalized.length) {
      const char: string = normalized[index];
      if (this.isDigit(char) || char === '.') {
        const start: number = index;
        let dotCount: number = 0;
        while (index < normalized.length && (this.isDigit(normalized[index]) || normalized[index] === '.')) {
          if (normalized[index] === '.') {
            dotCount += 1;
          }
          if (dotCount > 1) {
            throw new Error('数字格式错误');
          }
          index += 1;
        }
        const numberText: string = normalized.slice(start, index);
        if (numberText === '.') {
          throw new Error('数字格式错误');
        }
        tokens.push(new Token('number', numberText));
        continue;
      }

      if (this.isAlpha(char) || char === 'π') {
        const start: number = index;
        index += 1;
        while (index < normalized.length && this.isAlpha(normalized[index])) {
          index += 1;
        }
        const identifier: string = normalized.slice(start, index).toLowerCase();
        if (identifier === 'π' || identifier === 'pi') {
          tokens.push(new Token('number', Math.PI.toString()));
          continue;
        }
        if (identifier === 'e') {
          tokens.push(new Token('number', Math.E.toString()));
          continue;
        }
        if (this.FUNCTIONS.indexOf(identifier) >= 0) {
          tokens.push(new Token('function', identifier));
          continue;
        }
        throw new Error('不支持的函数');
      }

      if (char === '(') {
        tokens.push(new Token('leftParen', char));
        index += 1;
        continue;
      }

      if (char === ')') {
        tokens.push(new Token('rightParen', char));
        index += 1;
        continue;
      }

      if ('+-*/%^!'.indexOf(char) >= 0) {
        const previous: Token | undefined = tokens.length > 0 ? tokens[tokens.length - 1] : undefined;
        if (char === '-' && this.isUnaryContext(previous)) {
          tokens.push(new Token('operator', '~'));
        } else {
          tokens.push(new Token('operator', char));
        }
        index += 1;
        continue;
      }

      throw new Error('包含非法字符');
    }

    return tokens;
  }

  private static toRpn(tokens: Array<Token>): Array<Token> {
    const output: Array<Token> = [];
    const operators: Array<Token> = [];

    for (let i: number = 0; i < tokens.length; i += 1) {
      const token: Token = tokens[i];
      if (token.type === 'number') {
        output.push(token);
        continue;
      }

      if (token.type === 'function') {
        operators.push(token);
        continue;
      }

      if (token.type === 'operator') {
        while (operators.length > 0) {
          const top: Token = operators[operators.length - 1];
          if (top.type === 'function') {
            output.push(operators.pop() as Token);
            continue;
          }
          if (top.type !== 'operator') {
            break;
          }
          const currentPrecedence: number = this.PRECEDENCE[token.value];
          const topPrecedence: number = this.PRECEDENCE[top.value];
          const shouldPop: boolean = this.RIGHT_ASSOCIATIVE.indexOf(token.value) >= 0 ? currentPrecedence < topPrecedence : currentPrecedence <= topPrecedence;
          if (!shouldPop) {
            break;
          }
          output.push(operators.pop() as Token);
        }
        operators.push(token);
        continue;
      }

      if (token.type === 'leftParen') {
        operators.push(token);
        continue;
      }

      while (operators.length > 0 && operators[operators.length - 1].type !== 'leftParen') {
        output.push(operators.pop() as Token);
      }
      if (operators.length === 0) {
        throw new Error('括号不匹配');
      }
      operators.pop();
      if (operators.length > 0 && operators[operators.length - 1].type === 'function') {
        output.push(operators.pop() as Token);
      }
    }

    while (operators.length > 0) {
      const top: Token = operators.pop() as Token;
      if (top.type === 'leftParen' || top.type === 'rightParen') {
        throw new Error('括号不匹配');
      }
      output.push(top);
    }

    return output;
  }

  private static evaluateRpn(rpn: Array<Token>, angleMode: AngleMode): number {
    const stack: Array<number> = [];
    for (let i: number = 0; i < rpn.length; i += 1) {
      const token: Token = rpn[i];
      if (token.type === 'number') {
        stack.push(Number(token.value));
        continue;
      }

      if (token.type === 'operator') {
        if (token.value === '~') {
          stack.push(-this.popOne(stack));
          continue;
        }
        if (token.value === '!') {
          stack.push(this.factorial(this.popOne(stack)));
          continue;
        }
        const right: number = this.popOne(stack);
        const left: number = this.popOne(stack);
        switch (token.value) {
          case '+':
            stack.push(left + right);
            break;
          case '-':
            stack.push(left - right);
            break;
          case '*':
            stack.push(left * right);
            break;
          case '/':
            if (Math.abs(right) < 1e-12) {
              throw new Error('除数不能为 0');
            }
            stack.push(left / right);
            break;
          case '%':
            if (Math.abs(right) < 1e-12) {
              throw new Error('除数不能为 0');
            }
            stack.push(left % right);
            break;
          case '^':
            stack.push(Math.pow(left, right));
            break;
          default:
            throw new Error('不支持的运算符');
        }
        continue;
      }

      const value: number = this.popOne(stack);
      switch (token.value) {
        case 'sin':
          stack.push(Math.sin(this.toRadian(value, angleMode)));
          break;
        case 'cos':
          stack.push(Math.cos(this.toRadian(value, angleMode)));
          break;
        case 'tan':
          stack.push(Math.tan(this.toRadian(value, angleMode)));
          break;
        case 'log':
          if (value <= 0) {
            throw new Error('对数参数必须大于 0');
          }
          stack.push(Math.log(value) / Math.LN10);
          break;
        case 'ln':
          if (value <= 0) {
            throw new Error('对数参数必须大于 0');
          }
          stack.push(Math.log(value));
          break;
        case 'sqrt':
          if (value < 0) {
            throw new Error('平方根参数不能为负数');
          }
          stack.push(Math.sqrt(value));
          break;
        case 'abs':
          stack.push(Math.abs(value));
          break;
        case 'factorial':
          stack.push(this.factorial(value));
          break;
        default:
          throw new Error('不支持的函数');
      }
    }

    if (stack.length !== 1) {
      throw new Error('表达式错误');
    }
    return stack[0];
  }

  private static popOne(stack: Array<number>): number {
    if (stack.length === 0) {
      throw new Error('表达式错误');
    }
    return stack.pop() as number;
  }

  private static factorial(value: number): number {
    const integerValue: number = Math.round(value);
    if (value < 0 || Math.abs(value - integerValue) > 1e-10) {
      throw new Error('阶乘只支持非负整数');
    }
    let result: number = 1;
    for (let i: number = 2; i <= integerValue; i += 1) {
      result *= i;
    }
    return result;
  }

  private static toRadian(value: number, angleMode: AngleMode): number {
    if (angleMode === 'rad') {
      return value;
    }
    return value * Math.PI / 180;
  }

  private static isDigit(char: string): boolean {
    return char >= '0' && char <= '9';
  }

  private static isAlpha(char: string): boolean {
    return (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z');
  }

  private static isUnaryContext(token?: Token): boolean {
    if (!token) {
      return true;
    }
    if (token.type === 'leftParen' || token.type === 'function') {
      return true;
    }
    return token.type === 'operator' && token.value !== '!';
  }
}
