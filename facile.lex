%{
#include <assert.h>

#define TOK_IF          258
#define TOK_THEN        259
#define TOK_END         260
#define TOK_ENDIF       261
#define TOK_ELSEIF      262
#define TOK_ELSE        263
#define TOK_READ        264
#define TOK_PRINT       265
#define TOK_SEMICOLON   266
#define TOK_ADD         267
#define TOK_SUB         268
#define TOK_MUL         269
#define TOK_DIV         270
#define TOK_AFFECTATION 271
#define TOK_FACILE      272
#define TOK_WHILE       273
#define TOK_DO          274
#define TOK_ENDWHILE    275
#define TOK_BREAK       276
#define TOK_CONTINUE    277
#define TOK_IDENTIFIER  278
#define TOK_NUMBER      279
#define TOK_OPEN_PAREN  280
#define TOK_CLOSE_PAREN 281
#define TOK_TRUE        282
#define TOK_FALSE       283
#define TOK_NOT         284
#define TOK_AND         285
#define TOK_OR          286
#define TOK_EQ          287
#define TOK_NEQ         288
#define TOK_INF         289
#define TOK_SUP         290
#define TOK_LE          291
#define TOK_GE          292
%}

%%

if {
    assert(printf("'if' found"));
    return TOK_IF;
}

then {
    assert(printf("'then' found"));
    return TOK_THEN;
}

else {
    assert(printf("'else' found"));
    return TOK_ELSE;
}

elseif {
    assert(printf("'elseif' found"));
    return TOK_ELSEIF;
}

end {
    assert(printf("'end' found"));
    return TOK_END;
}

endif {
    assert(printf("'endif' found"));
    return TOK_ENDIF;
}

while {
    assert(printf("'while' found"));
    return TOK_WHILE;
}

do {
    assert(printf("'do' found"));
    return TOK_DO;
}

endwhile {
    assert(printf("'endwhile' found"));
    return TOK_ENDWHILE;
}

break {
    assert(printf("'break' found"));
    return TOK_BREAK;
}

continue {
    assert(printf("'continue' found"));
    return TOK_CONTINUE;
}

read {
    assert(printf("'read' found"));
    return TOK_READ;
}

print {
    assert(printf("'print' found"));
    return TOK_PRINT;
}

true {
    assert(printf("'true' found"));
    return TOK_TRUE;
}

false {
    assert(printf("'false' found"));
    return TOK_FALSE;
}

not {
    assert(printf("'not' found"));
    return TOK_NOT;
}

and {
    assert(printf("'and' found"));
    return TOK_AND;
}

or {
    assert(printf("'or' found"));
    return TOK_OR;
}

facile {
    assert(printf("'facile' found"));
    return TOK_FACILE;
}

":=" {
    assert(printf("':=' found"));
    return TOK_AFFECTATION;
}

";" {
    assert(printf("';' found"));
    return TOK_SEMICOLON;
}

"+" {
    assert(printf("'+' found"));
    return TOK_ADD;
}

"-" {
    assert(printf("'-' found"));
    return TOK_SUB;
}

"*" {
    assert(printf("'*' found"));
    return TOK_MUL;
}

"/" {
    assert(printf("'/' found"));
    return TOK_DIV;
}

"(" {
    assert(printf("'(' found"));
    return TOK_OPEN_PAREN;
}

")" {
    assert(printf("')' found"));
    return TOK_CLOSE_PAREN;
}

">=" {
    assert(printf("'>=' found"));
    return TOK_GE;
}

"<=" {
    assert(printf("'<=' found"));
    return TOK_LE;
}

">" {
    assert(printf("'>' found"));
    return TOK_SUP;
}

"<" {
    assert(printf("'<' found"));
    return TOK_INF;
}

"=" {
    assert(printf("'=' found"));
    return TOK_EQ;
}

"#" {
    assert(printf("'#' found"));
    return TOK_NEQ;
}

[a-zA-Z][a-zA-Z0-9_]* {
    assert(printf("identifier '%s(%d)' found", yytext, yyleng));
    return TOK_IDENTIFIER;
}

[0-9]+ {
    assert(printf("number '%s(%d)' found", yytext, yyleng));
    return TOK_NUMBER;
}

[ \t\r\n]+ {
    /* skip whitespace */
}

. {
    ECHO;
}

%%

/*
 * file: facile.lex
 * version: 0.5.0
 */
