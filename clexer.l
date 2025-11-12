%{
#include <stdio.h>
%}

%%

"int"|"char"|"float"|"double"|"if"|"else"|"while"|"for"|"return"|"void"|"break"|"continue"|"struct"|"typedef"|"include"|"define"    { printf("TOKEN: KEYWORD (%s)\n", yytext); }

[0-9]+(\.[0-9]+)?     { printf("TOKEN: NUMBER (%s)\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]*    { printf("TOKEN: IDENTIFIER (%s)\n", yytext); }

"//".*              { printf("TOKEN: COMMENT (//...)\n"); }
"/*"([^*]|\*+[^*/])*"\*/"   { printf("TOKEN: COMMENT (/*...*/)\n"); }

"=="|"!="|"<="|">="|"="|"<"|">"|"."  { printf("TOKEN: OPERATOR (%s)\n", yytext); }
"++"|"--"|"+"|"-"|"*"|"/"|"%"    { printf("TOKEN: OPERATOR (%s)\n", yytext); }

";"|"{"|"}"|"("|"["|"]"|","|"#"|")"|"<"|">"    { printf("TOKEN: SYMBOL (%s)\n", yytext); }

\"([^\\\"]|\\.)*\"      { printf("TOKEN: STRING (%s)\n", yytext); }

[ \t\n]+    ;
.           { printf("TOKEN: UNKNOWN (%s)\n", yytext); }

%%

int main(void) {
    yylex();
    return 0;
}

int yywrap(void) {
    return 1;
}