%{
#include <stdlib.h>
#include <stdio.h>

extern int yylex(void);
extern int yyerror(const char *msg);
%}
%%
program: ;
%%
/*
* file: facile.y
* version: 0.6.0
*/
int yyerror(const char *msg) {
fprintf(stderr, "%s\n", msg);
}
int main(int argc, char *argv[]) {
yyparse();
return EXIT_SUCCESS;
}