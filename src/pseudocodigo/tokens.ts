export const NEWLINE = /\n+/;
export const INDENT = /^ */gm;
export const INDEX = /\d+/;
export const NUMBER = /[-\+]?\d+(?:\.\d+)?/;
export const IF = /if/;
export const ELSE = /else/;
export const SYMBOL = /[a-z]+/;

export const allTokens = {
  NEWLINE,
  INDENT,
  INDEX,
  NUMBER,
  IF,
  ELSE,
  SYMBOL
};
