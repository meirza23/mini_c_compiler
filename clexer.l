/* clexer.l */
%{
#include <stdio.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"
%}

%%
^"#".* { }

"int"       { return TOKEN_INT; }
"float"     { return TOKEN_FLOAT; }
"bool"      { return TOKEN_BOOL; } 
"true"      { yylval.sval = strdup("1"); return TOKEN_TRUE; } 
"false"     { yylval.sval = strdup("0"); return TOKEN_FALSE; } 

"if"        { return TOKEN_IF; }
"else"      { return TOKEN_ELSE; }
"return"    { return TOKEN_RETURN; }

[0-9]+(\.[0-9]+)? { 
    yylval.sval = strdup(yytext); 
    return TOKEN_NUMBER; 
}

\"([^\\\"]|\\.)*\" { 
    yylval.sval = strdup(yytext); 
    return TOKEN_STRING; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.sval = strdup(yytext); 
    return TOKEN_ID; 
}

"//".* { }
[ \t\n]+    { }

"="         { return TOKEN_EQ; }
"=="        { return TOKEN_EQEQ; } /* Eklendi */
"!="        { return TOKEN_NEQ; }  /* Eklendi */
"<"         { return '<'; }        /* Eklendi */
">"         { return '>'; }        /* Eklendi */

"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }

";" { return TOKEN_SEMI; }
"{" { return TOKEN_LBRACE; }
"}" { return TOKEN_RBRACE; }
"(" { return '('; }
")" { return ')'; }
"," { return ','; }

.   { printf("Bilinmeyen: %s\n", yytext); }

%%
int yywrap(void) { return 1; }