%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

char c;

%}

DIGIT  [0-9]+
ID [a-zA-Z_][0-9a-zA-Z_]*
FLOAT [0-9]+[.][0-9]*

ARITHMETIC_OPERATORS ['+' '\-' '*' '/' '^' '%']
OTHER_CHARACTERS ['=' ';' '(' ')' '{' '}']
TYPES ["int" "float" "long" "char" "double"]

%%
[ \t] ;
[\n] ;


"if" 	{ return (IF); }
"else" 	{ return (ELSE); }

"int"	{ return (TYPES); }
"float"	{ return (TYPES); }
"long"	{ return (TYPES); }
"char"	{ return (TYPES); }
"double"	{ return (TYPES); }

">"	{yylval.sval = strdup(yytext);
		return (REL_OPT);}
"<"	{yylval.sval = strdup(yytext);
		return (REL_OPT);}
">="	{yylval.sval = strdup(yytext);
		return (REL_OPT);}
"<="	{yylval.sval = strdup(yytext);
		return (REL_OPT);}
"!="	{yylval.sval = strdup(yytext);
		return (REL_OPT);}
"=="	{yylval.sval = strdup(yytext);
		return (REL_OPT);}

"||"	{yylval.sval = strdup(yytext);
		return (OR);}
"&&"	{yylval.sval = strdup(yytext);
		return (AND);}
"!"	{yylval.sval = strdup(yytext);
		return (NOT);}
"true"	{yylval.sval = strdup(yytext);
		return (TRUE);}
"false"	{yylval.sval = strdup(yytext);
		return (FALSE);}

{DIGIT}  { yylval.ival = atoi(yytext);
	   return DIGIT; }

{FLOAT}  { yylval.fval = atof(yytext);
	   return FLOAT; }

{ID}"["{DIGIT}"]" {yylval.sval = strdup(yytext);
					return ID;}

{ID} {
	    yylval.sval = strdup(yytext);
	    return ID; }

"printf(".*");" {yylval.sval = strdup(yytext);
					return PRINT;}
					
"scanf(".*");" {yylval.sval = strdup(yytext);
					return SCAN;}

{ARITHMETIC_OPERATORS}   {
            	c = yytext[0];
                 return(c);
              }

{OTHER_CHARACTERS}   {
                 c = yytext[0];
                 return(c);
              }
%%
