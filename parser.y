/* parser.y */
%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern int yylex();
extern FILE* yyin;
void yyerror(const char* s);
extern void generateCode(ASTNode* node);

ASTNode* root;
%}

%union {
    char* sval;
    struct ASTNode* node;
}

%token <sval> TOKEN_ID TOKEN_NUMBER TOKEN_STRING
%token TOKEN_INT TOKEN_FLOAT TOKEN_BOOL TOKEN_TRUE TOKEN_FALSE
%token TOKEN_IF TOKEN_ELSE TOKEN_RETURN
%token TOKEN_LBRACE TOKEN_RBRACE TOKEN_SEMI TOKEN_EQ

%token TOKEN_EQEQ TOKEN_NEQ
%left '<' '>' TOKEN_EQEQ TOKEN_NEQ
%left '+' '-'
%left '*' '/'

%type <node> program function_def statement_list statement var_decl assignment if_stmt return_stmt expression

%%

program:
    function_def { root = $1; }
    ;

function_def:
    TOKEN_INT TOKEN_ID '(' ')' TOKEN_LBRACE statement_list TOKEN_RBRACE {
        $$ = createNode(NODE_FUNC_DEF, $2, $6, NULL);
    }
    ;

statement_list:
    statement { $$ = $1; }
    | statement statement_list { $$ = $1; $$->next = $2; }
    ;

statement:
    var_decl { $$ = $1; }
    | assignment { $$ = $1; }
    | if_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    ;

var_decl:
    TOKEN_INT TOKEN_ID TOKEN_EQ expression TOKEN_SEMI {
        ASTNode* idNode = createNode(NODE_ID, $2, NULL, NULL);
        $$ = createNode(NODE_VAR_DECL, "int", idNode, $4);
    }
    | TOKEN_FLOAT TOKEN_ID TOKEN_EQ expression TOKEN_SEMI {
        ASTNode* idNode = createNode(NODE_ID, $2, NULL, NULL);
        $$ = createNode(NODE_VAR_DECL, "float", idNode, $4);
    }
    | TOKEN_BOOL TOKEN_ID TOKEN_EQ expression TOKEN_SEMI {
         ASTNode* idNode = createNode(NODE_ID, $2, NULL, NULL);
         $$ = createNode(NODE_VAR_DECL, "bool", idNode, $4);
    }
    ;

assignment:
    TOKEN_ID TOKEN_EQ expression TOKEN_SEMI {
        ASTNode* idNode = createNode(NODE_ID, $1, NULL, NULL);
        $$ = createNode(NODE_ASSIGN, "=", idNode, $3);
    }
    ;

expression:
    expression '+' expression { $$ = createNode(NODE_MATH, "+", $1, $3); }
    | expression '-' expression { $$ = createNode(NODE_MATH, "-", $1, $3); }
    | expression '*' expression { $$ = createNode(NODE_MATH, "*", $1, $3); }
    | expression '/' expression { $$ = createNode(NODE_MATH, "/", $1, $3); }
    | expression '<' expression { $$ = createNode(NODE_OP, "<", $1, $3); }
    | expression '>' expression { $$ = createNode(NODE_OP, ">", $1, $3); }
    | expression TOKEN_EQEQ expression { $$ = createNode(NODE_OP, "==", $1, $3); }
    | expression TOKEN_NEQ expression { $$ = createNode(NODE_OP, "!=", $1, $3); }
    | '(' expression ')'      { $$ = $2; }
    | TOKEN_NUMBER            { $$ = createNode(NODE_CONST, $1, NULL, NULL); }
    | TOKEN_TRUE              { $$ = createNode(NODE_BOOL, "true", NULL, NULL); }
    | TOKEN_FALSE             { $$ = createNode(NODE_BOOL, "false", NULL, NULL); }
    | TOKEN_ID                { $$ = createNode(NODE_ID, $1, NULL, NULL); }
    | TOKEN_STRING            { $$ = createNode(NODE_STRING, $1, NULL, NULL); }
    ;

if_stmt:
    TOKEN_IF '(' expression ')' TOKEN_LBRACE statement_list TOKEN_RBRACE TOKEN_ELSE TOKEN_LBRACE statement_list TOKEN_RBRACE {
        ASTNode* ifNode = createNode(NODE_IF, "if", $3, $6);
        ifNode->elseNode = $10; /* DUZELTME: elseNode'a atandi */
        $$ = ifNode;
    }
    | TOKEN_IF '(' expression ')' TOKEN_LBRACE statement_list TOKEN_RBRACE {
        $$ = createNode(NODE_IF, "if", $3, $6);
    }
    ;

return_stmt:
    TOKEN_RETURN expression TOKEN_SEMI {
         $$ = createNode(NODE_RETURN, "return", $2, NULL);
    }
    ;

%%

void yyerror(const char* s) { fprintf(stderr, "Hata: %s\n", s); }

int main(int argc, char* argv[]) {
    if (argc > 1) yyin = fopen(argv[1], "r");
    if(yyparse() == 0) generateCode(root);
    return 0;
}