import { allTokens } from './tokens';
const Lexer = require("lex");

var row = 1;
var col = 1;

var indent = [0];

export const lexer = new Lexer(function (char: string) {
    throw new Error("Unexpected character at row " + row + ", col " + col + ": " + char);
});

lexer.addRule(allTokens.NEWLINE, function (lexeme: any) {
    col = 1;
    row += lexeme.length;
    return "NEWLINE";
});

lexer.addRule(allTokens.INDENT, function (lexeme: any) {
    var indentation = lexeme.length;

    col += indentation;

    if (indentation > indent[0]) {
        indent.unshift(indentation);
        return "INDENT";
    }

    var tokens: "DEDENT"[] = [];

    while (indentation < indent[0]) {
        tokens.push("DEDENT");
        indent.shift();
    }

    if (tokens.length) return tokens;
    return undefined;
});

lexer.addRule(/ +/, function (lexeme: any) {
    col += lexeme.length;
});

lexer.addRule(/\d+/, function (lexeme: any) {
    this.yytext = +lexeme;
    col += lexeme.length;
    return "INDEX";
});

lexer.addRule(/[-\+]?\d+(?:\.\d+)?/, function (lexeme: any) {
    this.yytext = +lexeme;
    col += lexeme.length;
    return "NUMBER";
});

lexer.addRule(/if/, function (lexeme: any) {
    col += lexeme.length;
    return "IF";
});

lexer.addRule(/else/, function (lexeme: any) {
    col += lexeme.length;
    return "ELSE";
});

lexer.addRule(/[a-z]+/, function (lexeme: any) {
    col += lexeme.length;
    this.yytext = lexeme;
    return "SYMBOL";
});

lexer.addRule(/\[/, function () {
    col++;
    return "[";
});

lexer.addRule(/\]/, function () {
    col++;
    return "]";
});

lexer.addRule(/\(/, function () {
    col++;
    return "(";
});

lexer.addRule(/\)/, function () {
    col++;
    return ")";
});

lexer.addRule(/\+/, function () {
    col++;
    return "+";
});

lexer.addRule(/\-/, function () {
    col++;
    return "-";
});

lexer.addRule(/\*/, function () {
    col++;
    return "*";
});

lexer.addRule(/\//, function () {
    col++;
    return "/";
});

lexer.addRule(/\%/, function () {
    col++;
    return "%";
});

lexer.addRule(/</, function () {
    col++;
    return "<";
});

lexer.addRule(/>/, function () {
    col++;
    return ">";
});

lexer.addRule(/<=/, function () {
    col++;
    return "<=";
});

lexer.addRule(/>=/, function () {
    col++;
    return ">=";
});

lexer.addRule(/==/, function () {
    col++;
    return "==";
});

lexer.addRule(/!=/, function () {
    col++;
    return "!=";
});

lexer.addRule(/!/, function () {
    col++;
    return "!";
});

lexer.addRule(/\&/, function () {
    col++;
    return "&";
});

lexer.addRule(/\|/, function () {
    col++;
    return "|";
});

lexer.addRule(/=/, function () {
    col++;
    return "=";
});

lexer.addRule(/\+=/, function () {
    col++;
    return "+=";
});

lexer.addRule(/\-=/, function () {
    col++;
    return "-=";
});

lexer.addRule(/\*=/, function () {
    col++;
    return "*=";
});

lexer.addRule(/\/=/, function () {
    col++;
    return "/=";
});

lexer.addRule(/\%=/, function () {
    col++;
    return "%=";
});

lexer.addRule(/,/, function () {
    col++;
    return ",";
});

lexer.addRule(/$/, function () {
    return "EOF";
});
