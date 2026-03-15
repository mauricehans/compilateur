%{
#include <assert.h>
#include <string.h>
#include "facile.y.h" 

%}
%option yylineno 
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

0|[1-9][0-9]* {
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
