%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <glib.h>

extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;

FILE       *stream;
gchar      *module_name;
GHashTable *table;

void begin_code() {
    fprintf(stream, ".assembly %s {}\n", module_name);
    fprintf(stream, ".assembly extern mscorlib {}\n");
    fprintf(stream, ".method static void Main()\n{\n");
    fprintf(stream, ".entrypoint\n");
    fprintf(stream, ".maxstack 10\n");
    guint n = g_hash_table_size(table);
    fprintf(stream, ".locals init (");
    for (guint i = 0; i < n; i++) {
        if (i > 0) fprintf(stream, ", ");
        fprintf(stream, "int32");
    }
    fprintf(stream, ")\n");
}

void end_code() {
    fprintf(stream, "ret\n}\n");
}

void produce_code(GNode *node) {
    if (node->data == (gpointer)"code") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
    } else if (node->data == (gpointer)"affectation") {
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "stloc\t%ld\n",
            (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    } else if (node->data == (gpointer)"add") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "add\n");
    } else if (node->data == (gpointer)"sub") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "sub\n");
    } else if (node->data == (gpointer)"mul") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "mul\n");
    } else if (node->data == (gpointer)"div") {
        produce_code(g_node_nth_child(node, 0));
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "div\n");
    } else if (node->data == (gpointer)"number") {
        fprintf(stream, "ldc.i4\t%ld\n",
            (long)g_node_nth_child(node, 0)->data);
    } else if (node->data == (gpointer)"identifier") {
        fprintf(stream, "ldloc\t%ld\n",
            (long)g_node_nth_child(node, 0)->data - 1);
    } else if (node->data == (gpointer)"print") {
        produce_code(g_node_nth_child(node, 0));
        fprintf(stream, "call void class [mscorlib]System.Console::WriteLine(int32)\n");
    } else if (node->data == (gpointer)"read") {
        fprintf(stream, "call string class [mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, "call int32 int32::Parse(string)\n");
        fprintf(stream, "stloc\t%ld\n",
            (long)g_node_nth_child(g_node_nth_child(node, 0), 0)->data - 1);
    }
    /* Exercices 4-9 : ajouter ici la gestion de if, while, boolean */
}
%}

%define parse.error verbose

%union {
    gulong  number;
    gchar  *string;
    GNode  *node;
}

%token<number> TOK_NUMBER      "number"
%token<string> TOK_IDENTIFIER  "identifier"
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

%type<node> code instruction affectation read print
%type<node> expression identifier number
%type<node> if elseifs while code_while boolean

%%

program: code {
    begin_code();
    produce_code($1);
    end_code();
    g_node_destroy($1);
} ;

code:
    code instruction {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
  | /* vide */ {
        $$ = g_node_new("");
    }
;

instruction:
    affectation { $$ = $1; }
  | read        { $$ = $1; }
  | print       { $$ = $1; }
  | if          { $$ = $1; }
  | while       { $$ = $1; }
;

affectation:
    TOK_IDENTIFIER TOK_AFFECTATION expression TOK_SEMICOLON {
        $$ = g_node_new("affectation");
        GNode *id = g_node_new("identifier");
        gulong value = (gulong)g_hash_table_lookup(table, $1);
        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($1), (gpointer)value);
        }
        free($1);
        g_node_append_data(id, (gpointer)value);
        g_node_append($$, id);
        g_node_append($$, $3);
    }
;

read:
    TOK_READ TOK_IDENTIFIER TOK_SEMICOLON {
        $$ = g_node_new("read");
        GNode *id = g_node_new("identifier");
        gulong value = (gulong)g_hash_table_lookup(table, $2);
        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($2), (gpointer)value);
        }
        free($2);
        g_node_append_data(id, (gpointer)value);
        g_node_append($$, id);
    }
;

print:
    TOK_PRINT expression TOK_SEMICOLON {
        $$ = g_node_new("print");
        g_node_append($$, $2);
    }
;

if:
    TOK_IF boolean TOK_THEN code TOK_END               { $$ = g_node_new("if"); g_node_append($$,$2); g_node_append($$,$4); }
  | TOK_IF boolean TOK_THEN code TOK_ENDIF             { $$ = g_node_new("if"); g_node_append($$,$2); g_node_append($$,$4); }
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_END { $$ = g_node_new("ifelse"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$6); }
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_ENDIF { $$ = g_node_new("ifelse"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$6); }
  | TOK_IF boolean TOK_THEN code elseifs TOK_END       { $$ = g_node_new("ifelseif"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$5); }
  | TOK_IF boolean TOK_THEN code elseifs TOK_ENDIF     { $$ = g_node_new("ifelseif"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$5); }
  | TOK_IF boolean TOK_THEN code elseifs TOK_ELSE code TOK_END   { $$ = g_node_new("ifelseifelse"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$5); g_node_append($$,$7); }
  | TOK_IF boolean TOK_THEN code elseifs TOK_ELSE code TOK_ENDIF { $$ = g_node_new("ifelseifelse"); g_node_append($$,$2); g_node_append($$,$4); g_node_append($$,$5); g_node_append($$,$7); }
;

elseifs:
    elseifs TOK_ELSEIF boolean TOK_THEN code {
        $$ = $1;
        g_node_append($$, $3);
        g_node_append($$, $5);
    }
  | TOK_ELSEIF boolean TOK_THEN code {
        $$ = g_node_new("elseifs");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
;

while:
    TOK_WHILE boolean TOK_DO code_while TOK_END      { $$ = g_node_new("while"); g_node_append($$,$2); g_node_append($$,$4); }
  | TOK_WHILE boolean TOK_DO code_while TOK_ENDWHILE { $$ = g_node_new("while"); g_node_append($$,$2); g_node_append($$,$4); }
;

code_while:
    code_while instruction {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
  | code_while TOK_BREAK TOK_SEMICOLON {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, g_node_new("break"));
    }
  | code_while TOK_CONTINUE TOK_SEMICOLON {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, g_node_new("continue"));
    }
  | /* vide */ { $$ = g_node_new(""); }
;

expression:
    identifier { $$ = $1; }
  | number     { $$ = $1; }
  | expression TOK_ADD expression { $$ = g_node_new("add"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_SUB expression { $$ = g_node_new("sub"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_MUL expression { $$ = g_node_new("mul"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_DIV expression { $$ = g_node_new("div"); g_node_append($$,$1); g_node_append($$,$3); }
  | TOK_OPEN_PAREN expression TOK_CLOSE_PAREN { $$ = $2; }
;

boolean:
    TOK_TRUE  { $$ = g_node_new("true"); }
  | TOK_FALSE { $$ = g_node_new("false"); }
  | expression TOK_EQ  expression { $$ = g_node_new("eq");  g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_NEQ expression { $$ = g_node_new("neq"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_INF expression { $$ = g_node_new("inf"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_SUP expression { $$ = g_node_new("sup"); g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_LE  expression { $$ = g_node_new("le");  g_node_append($$,$1); g_node_append($$,$3); }
  | expression TOK_GE  expression { $$ = g_node_new("ge");  g_node_append($$,$1); g_node_append($$,$3); }
  | TOK_NOT boolean { $$ = g_node_new("not"); g_node_append($$,$2); }
  | boolean TOK_AND boolean { $$ = g_node_new("and"); g_node_append($$,$1); g_node_append($$,$3); }
  | boolean TOK_OR  boolean { $$ = g_node_new("or");  g_node_append($$,$1); g_node_append($$,$3); }
  | TOK_OPEN_PAREN boolean TOK_CLOSE_PAREN { $$ = $2; }
;

identifier:
    TOK_IDENTIFIER {
        $$ = g_node_new("identifier");
        gulong value = (gulong)g_hash_table_lookup(table, $1);
        if (!value) {
            value = g_hash_table_size(table) + 1;
            g_hash_table_insert(table, strdup($1), (gpointer)value);
        }
        free($1);
        g_node_append_data($$, (gpointer)value);
    }
;

number:
    TOK_NUMBER {
        $$ = g_node_new("number");
        g_node_append_data($$, (gpointer)$1);
    }
;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
}

int main(int argc, char *argv[]) {
    if (argc == 2) {
        char *file_name_input = argv[1];
        char *extension = rindex(file_name_input, '.');
        if (!extension || strcmp(extension, ".facile") != 0) {
            fprintf(stderr, "Input filename extension must be '.facile'\n");
            return EXIT_FAILURE;
        }
        char *directory_delimiter = rindex(file_name_input, '/');
        if (!directory_delimiter)
            directory_delimiter = rindex(file_name_input, '\\');
        char *basename = directory_delimiter
            ? strdup(directory_delimiter + 1)
            : strdup(file_name_input);
        module_name = strdup(basename);
        *rindex(module_name, '.') = '\0';
        strcpy(rindex(basename, '.'), ".il");
        char *onechar = module_name;
        if (!isalpha(*onechar) && *onechar != '_') {
            free(basename);
            fprintf(stderr, "Base input filename must start with a letter or an underscore\n");
            return EXIT_FAILURE;
        }
        for (onechar++; *onechar; onechar++) {
            if (!isalnum(*onechar) && *onechar != '_') {
                free(basename);
                fprintf(stderr, "Base input filename cannot contain special characters\n");
                return EXIT_FAILURE;
            }
        }
        if ((stdin = fopen(file_name_input, "r"))) {
            if ((stream = fopen(basename, "w"))) {
                table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
                yyparse();
                g_hash_table_destroy(table);
                fclose(stream);
                fclose(stdin);
            } else {
                free(basename); fclose(stdin);
                fprintf(stderr, "Output filename cannot be opened\n");
                return EXIT_FAILURE;
            }
        } else {
            free(basename);
            fprintf(stderr, "Input filename cannot be opened\n");
            return EXIT_FAILURE;
        }
        free(basename);
    } else {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
