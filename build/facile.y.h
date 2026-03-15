/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_HOME_NGOME_COMPILATEUR_BUILD_FACILE_Y_H_INCLUDED
# define YY_YY_HOME_NGOME_COMPILATEUR_BUILD_FACILE_Y_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    TOK_NUMBER = 258,              /* "number"  */
    TOK_IDENTIFIER = 259,          /* "identifier"  */
    TOK_AFFECTATION = 260,         /* ":="  */
    TOK_SEMICOLON = 261,           /* ";"  */
    TOK_ADD = 262,                 /* "+"  */
    TOK_SUB = 263,                 /* "-"  */
    TOK_MUL = 264,                 /* "*"  */
    TOK_DIV = 265,                 /* "/"  */
    TOK_OPEN_PAREN = 266,          /* "("  */
    TOK_CLOSE_PAREN = 267,         /* ")"  */
    TOK_READ = 268,                /* "read"  */
    TOK_PRINT = 269,               /* "print"  */
    TOK_IF = 270,                  /* "if"  */
    TOK_THEN = 271,                /* "then"  */
    TOK_ELSE = 272,                /* "else"  */
    TOK_ELSEIF = 273,              /* "elseif"  */
    TOK_END = 274,                 /* "end"  */
    TOK_ENDIF = 275,               /* "endif"  */
    TOK_WHILE = 276,               /* "while"  */
    TOK_DO = 277,                  /* "do"  */
    TOK_ENDWHILE = 278,            /* "endwhile"  */
    TOK_BREAK = 279,               /* "break"  */
    TOK_CONTINUE = 280,            /* "continue"  */
    TOK_TRUE = 281,                /* "true"  */
    TOK_FALSE = 282,               /* "false"  */
    TOK_NOT = 283,                 /* "not"  */
    TOK_AND = 284,                 /* "and"  */
    TOK_OR = 285,                  /* "or"  */
    TOK_EQ = 286,                  /* "="  */
    TOK_NEQ = 287,                 /* "#"  */
    TOK_INF = 288,                 /* "<"  */
    TOK_SUP = 289,                 /* ">"  */
    TOK_LE = 290,                  /* "<="  */
    TOK_GE = 291                   /* ">="  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_HOME_NGOME_COMPILATEUR_BUILD_FACILE_Y_H_INCLUDED  */
