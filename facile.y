%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <glib.h>

extern int yylex(void);
extern int yyerror(const char *msg);
extern int yylineno;

static FILE *stream;
static GHashTable *table;
static gchar *module_name;
static int label_count = 0;

int new_label() { return label_count++; }

void begin_code() {
    fprintf(stream, ".assembly extern mscorlib {}\n");
    fprintf(stream, ".assembly %s {}\n", module_name);
    fprintf(stream, ".method public static void Main() cil managed {\n");
    fprintf(stream, ".entrypoint\n");
    fprintf(stream, ".maxstack 64\n");
    fprintf(stream, ".locals init ()\n");
}

void end_code() {
    fprintf(stream, "ret\n");
    fprintf(stream, "}\n");
}

void declare_variable(gchar *name) {
    if (!g_hash_table_contains(table, name)) {
        gulong index = g_hash_table_size(table);
        g_hash_table_insert(table, strdup(name), GUINT_TO_POINTER(index));
    }
}

gulong get_variable(gchar *name) {
    return GPOINTER_TO_UINT(g_hash_table_lookup(table, name));
}

void produce_code(GNode *node);

void produce_expression(GNode *node) {
    gchar *data = (gchar *)node->data;
    if (strcmp(data, "number") == 0) {
        gulong val = GPOINTER_TO_UINT(node->children->data);
        fprintf(stream, "ldc.i4 %lu\n", val);
    } else if (strcmp(data, "identifier") == 0) {
        gchar *name = (gchar *)node->children->data;
        declare_variable(name);
        fprintf(stream, "ldloc %lu\n", get_variable(name));
    } else if (strcmp(data, "+") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "add\n");
    } else if (strcmp(data, "-") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "sub\n");
    } else if (strcmp(data, "*") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "mul\n");
    } else if (strcmp(data, "/") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "div\n");
    }
}

void produce_boolean(GNode *node, int label_true, int label_false) {
    gchar *data = (gchar *)node->data;
    if (strcmp(data, "true") == 0) {
        fprintf(stream, "br IL_%04d\n", label_true);
    } else if (strcmp(data, "false") == 0) {
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, "=") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "beq IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, "#") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "bne.un IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, "<") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "blt IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, ">") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "bgt IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, "<=") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "ble IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, ">=") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "bge IL_%04d\n", label_true);
        fprintf(stream, "br IL_%04d\n", label_false);
    } else if (strcmp(data, "not") == 0) {
        produce_boolean(g_node_nth_child(node, 0), label_false, label_true);
    } else if (strcmp(data, "and") == 0) {
        int mid = new_label();
        produce_boolean(g_node_nth_child(node, 0), mid, label_false);
        fprintf(stream, "IL_%04d:\n", mid);
        produce_boolean(g_node_nth_child(node, 1), label_true, label_false);
    } else if (strcmp(data, "or") == 0) {
        int mid = new_label();
        produce_boolean(g_node_nth_child(node, 0), label_true, mid);
        fprintf(stream, "IL_%04d:\n", mid);
        produce_boolean(g_node_nth_child(node, 1), label_true, label_false);
    }
}

void produce_code(GNode *node) {
    if (!node) return;
    gchar *data = (gchar *)node->data;

    if (strcmp(data, "code") == 0) {
        GNode *child = node->children;
        while (child) {
            produce_code(child);
            child = child->next;
        }
    } else if (strcmp(data, "affectation") == 0) {
        gchar *name = (gchar *)g_node_nth_child(node, 0)->data;
        declare_variable(name);
        produce_expression(g_node_nth_child(node, 1));
        fprintf(stream, "stloc %lu\n", get_variable(name));
    } else if (strcmp(data, "read") == 0) {
        gchar *name = (gchar *)g_node_nth_child(node, 0)->data;
        declare_variable(name);
        fprintf(stream, "call string class [mscorlib]System.Console::ReadLine()\n");
        fprintf(stream, "call int32 int32::Parse(string)\n");
        fprintf(stream, "stloc %lu\n", get_variable(name));
    } else if (strcmp(data, "print") == 0) {
        produce_expression(g_node_nth_child(node, 0));
        fprintf(stream, "call void class [mscorlib]System.Console::WriteLine(int32)\n");
    } else if (strcmp(data, "if") == 0) {
        int label_true = new_label();
        int label_false = new_label();
        int label_end = new_label();
        produce_boolean(g_node_nth_child(node, 0), label_true, label_false);
        fprintf(stream, "IL_%04d:\n", label_true);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "br IL_%04d\n", label_end);
        fprintf(stream, "IL_%04d:\n", label_false);
        if (g_node_n_children(node) > 2) {
            produce_code(g_node_nth_child(node, 2));
        }
        fprintf(stream, "IL_%04d:\n", label_end);
    } else if (strcmp(data, "while") == 0) {
        int label_start = new_label();
        int label_body = new_label();
        int label_end = new_label();
        fprintf(stream, "IL_%04d:\n", label_start);
        produce_boolean(g_node_nth_child(node, 0), label_body, label_end);
        fprintf(stream, "IL_%04d:\n", label_body);
        produce_code(g_node_nth_child(node, 1));
        fprintf(stream, "br IL_%04d\n", label_start);
        fprintf(stream, "IL_%04d:\n", label_end);
    }
}
%}

%define parse.error verbose

%union {
    gulong number;
    gchar *string;
    GNode *node;
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

%type<node> code expression boolean instruction
%type<node> affectation read print if while elseifs code_while

%left TOK_OR
%left TOK_AND
%right TOK_NOT
%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%

program: code {
    begin_code();
    produce_code($1);
    end_code();
    g_node_destroy($1);
};

code:
    code instruction {
        $$ = g_node_new("code");
        g_node_append($$, $1);
        g_node_append($$, $2);
    }
  | /* vide */ {
        $$ = g_node_new("code");
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
        g_node_append($$, g_node_new($1));
        g_node_append($$, $3);
    }
;

read:
    TOK_READ TOK_IDENTIFIER TOK_SEMICOLON {
        $$ = g_node_new("read");
        g_node_append($$, g_node_new($2));
    }
;

print:
    TOK_PRINT expression TOK_SEMICOLON {
        $$ = g_node_new("print");
        g_node_append($$, $2);
    }
;

if:
    TOK_IF boolean TOK_THEN code TOK_END {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
  | TOK_IF boolean TOK_THEN code TOK_ENDIF {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_END {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $6);
    }
  | TOK_IF boolean TOK_THEN code TOK_ELSE code TOK_ENDIF {
        $$ = g_node_new("if");
        g_node_append($$, $2);
        g_node_append($$, $4);
        g_node_append($$, $6);
    }
;

while:
    TOK_WHILE boolean TOK_DO code_while TOK_END {
        $$ = g_node_new("while");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
  | TOK_WHILE boolean TOK_DO code_while TOK_ENDWHILE {
        $$ = g_node_new("while");
        g_node_append($$, $2);
        g_node_append($$, $4);
    }
;

code_while:
    code_while instruction {
        $$ = $1;
        g_node_append($$, $2);
    }
  | code_while TOK_BREAK TOK_SEMICOLON {
        $$ = $1;
        g_node_append($$, g_node_new("break"));
    }
  | code_while TOK_CONTINUE TOK_SEMICOLON {
        $$ = $1;
        g_node_append($$, g_node_new("continue"));
    }
  | /* vide */ {
        $$ = g_node_new("code");
    }
;

expression:
    TOK_IDENTIFIER {
        $$ = g_node_new("identifier");
        g_node_append($$, g_node_new($1));
    }
  | TOK_NUMBER {
        $$ = g_node_new("number");
        g_node_append($$, g_node_new(GUINT_TO_POINTER($1)));
    }
  | expression TOK_ADD expression {
        $$ = g_node_new("+");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
  | expression TOK_SUB expression {
        $$ = g_node_new("-");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
  | expression TOK_MUL expression {
        $$ = g_node_new("*");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
  | expression TOK_DIV expression {
        $$ = g_node_new("/");
        g_node_append($$, $1);
        g_node_append($$, $3);
    }
  | TOK_OPEN_PAREN expression TOK_CLOSE_PAREN { $$ = $2; }
;

boolean:
    TOK_TRUE  { $$ = g_node_new("true"); }
  | TOK_FALSE { $$ = g_node_new("false"); }
  | expression TOK_EQ  expression {
        $$ = g_node_new("=");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | expression TOK_NEQ expression {
        $$ = g_node_new("#");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | expression TOK_INF expression {
        $$ = g_node_new("<");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | expression TOK_SUP expression {
        $$ = g_node_new(">");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | expression TOK_LE  expression {
        $$ = g_node_new("<=");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | expression TOK_GE  expression {
        $$ = g_node_new(">=");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | TOK_NOT boolean {
        $$ = g_node_new("not");
        g_node_append($$, $2);
    }
  | boolean TOK_AND boolean {
        $$ = g_node_new("and");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | boolean TOK_OR boolean {
        $$ = g_node_new("or");
        g_node_append($$, $1); g_node_append($$, $3);
    }
  | TOK_OPEN_PAREN boolean TOK_CLOSE_PAREN { $$ = $2; }
;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "Line %d: %s\n", yylineno, msg);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "No input filename given\n");
        return EXIT_FAILURE;
    }
    char *file_name_input = argv[1];
    char *extension = rindex(file_name_input, '.');
    if (!extension || strcmp(extension, ".facile") != 0) {
        fprintf(stderr, "Input filename extension must be '.facile'\n");
        return EXIT_FAILURE;
    }
    char *directory_delimiter = rindex(file_name_input, '/');
    char *basename;
    if (directory_delimiter) {
        basename = strdup(directory_delimiter + 1);
    } else {
        basename = strdup(file_name_input);
    }
    module_name = strdup(basename);
    *rindex(module_name, '.') = '\0';
    strcpy(rindex(basename, '.'), ".il");

    if ((stdin = fopen(file_name_input, "r"))) {
        if ((stream = fopen(basename, "w"))) {
            table = g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
            yyparse();
            g_hash_table_destroy(table);
            fclose(stream);
            fclose(stdin);
        } else {
            fprintf(stderr, "Output filename cannot be opened\n");
            free(basename);
            return EXIT_FAILURE;
        }
    } else {
        fprintf(stderr, "Input filename cannot be opened\n");
        free(basename);
        return EXIT_FAILURE;
    }
    free(basename);
    return EXIT_SUCCESS;
}
