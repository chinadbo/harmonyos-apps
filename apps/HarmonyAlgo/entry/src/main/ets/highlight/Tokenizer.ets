/**
 * 轻量级词法分析器
 * 支持 ArkTS / Python 两种语言，识别：关键字、字符串、注释、数字、函数名
 */

export enum TokenType {
  Plain = 0,
  Keyword = 1,
  String = 2,
  Comment = 3,
  Number = 4,
  Function = 5
}

export class Token {
  type: TokenType;
  text: string;

  constructor(type: TokenType, text: string) {
    this.type = type;
    this.text = text;
  }
}

const ARKTS_KEYWORDS: Set<string> = new Set<string>([
  'function', 'const', 'let', 'var', 'return', 'if', 'else', 'for', 'while', 'do',
  'break', 'continue', 'class', 'extends', 'new', 'this', 'super', 'import', 'export',
  'from', 'default', 'true', 'false', 'null', 'undefined', 'typeof', 'instanceof',
  'in', 'of', 'void', 'enum', 'interface', 'implements', 'public', 'private', 'protected',
  'static', 'readonly', 'async', 'await', 'switch', 'case', 'throw', 'try', 'catch',
  'finally', 'number', 'string', 'boolean', 'any', 'never', 'as', 'is'
]);

const PYTHON_KEYWORDS: Set<string> = new Set<string>([
  'def', 'return', 'if', 'elif', 'else', 'for', 'while', 'in', 'not', 'and', 'or',
  'None', 'True', 'False', 'import', 'from', 'as', 'class', 'self', 'break', 'continue',
  'pass', 'lambda', 'with', 'try', 'except', 'finally', 'raise', 'yield', 'global',
  'nonlocal', 'del', 'is', 'assert'
]);

function isDigit(c: string): boolean {
  return c >= '0' && c <= '9';
}

function isLetter(c: string): boolean {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

function isSpace(c: string): boolean {
  return c === ' ' || c === '\t' || c === '\n' || c === '\r';
}

function isIdentChar(c: string): boolean {
  return isLetter(c) || isDigit(c) || c === '_';
}

export class Tokenizer {
  static tokenize(code: string, language: string): Token[] {
    const isArk: boolean = language !== 'python';
    const keywords: Set<string> = isArk ? ARKTS_KEYWORDS : PYTHON_KEYWORDS;
    const tokens: Token[] = [];
    const n: number = code.length;
    let i = 0;
    while (i < n) {
      const ch: string = code.charAt(i);

      // 空白字符
      if (isSpace(ch)) {
        let j = i;
        while (j < n && isSpace(code.charAt(j))) {
          j++;
        }
        tokens.push(new Token(TokenType.Plain, code.substring(i, j)));
        i = j;
        continue;
      }

      // Python 井号注释
      if (!isArk && ch === '#') {
        let j = i;
        while (j < n && code.charAt(j) !== '\n') {
          j++;
        }
        tokens.push(new Token(TokenType.Comment, code.substring(i, j)));
        i = j;
        continue;
      }

      // ArkTS 行注释 //
      if (isArk && ch === '/' && code.charAt(i + 1) === '/') {
        let j = i;
        while (j < n && code.charAt(j) !== '\n') {
          j++;
        }
        tokens.push(new Token(TokenType.Comment, code.substring(i, j)));
        i = j;
        continue;
      }

      // ArkTS 块注释 /* */
      if (isArk && ch === '/' && code.charAt(i + 1) === '*') {
        let j = i + 2;
        while (j < n && !(code.charAt(j) === '*' && code.charAt(j + 1) === '/')) {
          j++;
        }
        j = Math.min(n, j + 2);
        tokens.push(new Token(TokenType.Comment, code.substring(i, j)));
        i = j;
        continue;
      }

      // 字符串（Python 三引号优先）
      if (ch === '"' || ch === '\'' || (isArk && ch === '`')) {
        if (!isArk && code.substring(i, i + 3) === ch + ch + ch) {
          const triple = ch + ch + ch;
          let j = i + 3;
          while (j < n && code.substring(j, j + 3) !== triple) {
            j++;
          }
          j = Math.min(n, j + 3);
          tokens.push(new Token(TokenType.String, code.substring(i, j)));
          i = j;
          continue;
        }
        let j = i + 1;
        while (j < n) {
          const cur = code.charAt(j);
          if (cur === '\\') {
            j += 2;
            continue;
          }
          if (cur === ch) {
            j++;
            break;
          }
          if (cur === '\n') {
            break;
          }
          j++;
        }
        tokens.push(new Token(TokenType.String, code.substring(i, j)));
        i = j;
        continue;
      }

      // 数字
      if (isDigit(ch)) {
        let j = i;
        while (j < n && (isDigit(code.charAt(j)) || code.charAt(j) === '.')) {
          j++;
        }
        tokens.push(new Token(TokenType.Number, code.substring(i, j)));
        i = j;
        continue;
      }

      // 标识符 / 关键字 / 函数名
      if (isLetter(ch) || ch === '_') {
        let j = i;
        while (j < n && isIdentChar(code.charAt(j))) {
          j++;
        }
        const word = code.substring(i, j);
        if (keywords.has(word)) {
          tokens.push(new Token(TokenType.Keyword, word));
        } else {
          let k = j;
          while (k < n && (code.charAt(k) === ' ' || code.charAt(k) === '\t')) {
            k++;
          }
          if (k < n && code.charAt(k) === '(') {
            tokens.push(new Token(TokenType.Function, word));
          } else {
            tokens.push(new Token(TokenType.Plain, word));
          }
        }
        i = j;
        continue;
      }

      // 其它符号
      tokens.push(new Token(TokenType.Plain, ch));
      i++;
    }
    return tokens;
  }
}
