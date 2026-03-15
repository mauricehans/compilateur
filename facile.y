%{
#include <stdlib.h>
#include <stdio.h>
extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;
%}

%define parse.error verbose

%token TOK_NUMBER      "number"
%token TOK_IDENTIFIER  "identifier"
%token TOK_AFFECTATION ":="
%token TOK_SEMICOLON   ";"
%token TOK_ADD         "+"
%token TOK_SUB         "-"
%token TOK_MUL         "*"
%token TOK_DIV         "/"
%token TOK_OPEN_PAREN  "("
%token TOK_CLOSE_PAREN ")"
%token TOK_READ        "read"
%token TOK_PRINT       "print"
%token TOK_IF          "if"
%token TOK_THEN        "then"
%token TOK_ELSE        "else"
%token TOK_ELSEIF      "elseif"
%token TOK_END         "end"
%token TOK_ENDIF       "endif"
%token TOK_WHILE       "while"
%token TOK_DO          "do"
%token TOK_ENDWHILE    "endwhile"
%token TOK_BREAK       "break"
%token TOK_CONTINUE    "continue"
%token TOK_TRUE        "true"
%token TOK_FALSE       "false"
%token TOK_NOT         "not"
%token TOK_AND         "and"
%token TOK_OR          "or"
%token TOK_EQ          "="
%token TOK_NEQ         "#"
%token TOK_INF         "<"
%token TOK_SUP         ">"
%token TOK_LE          "<="
%token TOK_GE          ">="

%left TOK_OR
%left TOK_AND
%right TOK_NOT
%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

program: code ;

code:
    code instruction
  | /* vide */
;

instruction:
    affectation
  | read
  | print
  | if
  | while
;

affectation:
    TOK_IDENTIFIER TOK_AFFECTATION expression TOK_SEMICOLON
;

read:
    TOK_READ TOK_IDENTIFIER TOK_SEMICOLON
;

print:
    TOK_PRINT expression TOK_SEMICOLON
;

if:
    TOK_IF boolean TOK_THEN code TOK_END
  | TOK_IF boolean TOK_THEN code TOK_ENDIF
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_END
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_ENDIF
  | TOK_IF boolean TOK_THEN code elseifs TOK_END
  | TOK_IF boolean TOK_THEN code elseifs TOK_ENDIF
  | TOK_IF boolean TOK_THEN code elseifs TOK_ELSE code TOK_END
  | TOK_IF boolean TOK_THEN code elseifs TOK_ELSE code TOK_ENDIF
;

elseifs:
    elseifs TOK_ELSEIF boolean TOK_THEN code
  | TOK_ELSEIF boolean TOK_THEN code
;

while:
    TOK_WHILE boolean TOK_DO code_while TOK_END
  | TOK_WHILE boolean TOK_DO code_while TOK_ENDWHILE
;

code_while:
    code_while instruction
  | code_while TOK_BREAK TOK_SEMICOLON
  | code_while TOK_CONTINUE TOK_SEMICOLON
  | /* vide */
;

expression:
    TOK_IDENTIFIER
  | TOK_NUMBER
  | expression TOK_ADD expression
  | expression TOK_SUB expression
  | expression TOK_MUL expression
  | expression TOK_DIV expression
  | TOK_OPEN_PAREN expression TOK_CLOSE_PAREN
;

boolean:
    TOK_TRUE
  | TOK_FALSE
  | expression TOK_EQ  expression
  | expression TOK_NEQ expression
  | expression TOK_INF expression
  | expression TOK_SUP expression
  | expression TOK_LE  expression
  | expression TOK_GE  expression
  | TOK_NOT boolean
  | boolean TOK_AND boolean
  | boolean TOK_OR boolean
  | TOK_OPEN_PAREN boolean TOK_CLOSE_PAREN
;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

int main(int argc, char *argv[]) {
    yyparse();
    return EXIT_SUCCESS;
}
