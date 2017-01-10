digit [0-9]
alpha [a-zA-Z]


%{
#include "y.tab.h"
#include <string.h>

extern struct Stack_Node* stack;
extern int comp;
extern int if_block_size;
int linenum = 1;

%}

%%
"include" return INCLUDEKYW;
[0-9a-zA-Z]*\."h"  return FILENAME;
"return" 	return RETURNKYW;
"int"		return INTKYW;
"char"		return CHRKYW;
"float" 	return FLTKYW;
"double"	return DBLKYW;
"main"		return MAINKYW;

"if"        {if_block_size = 0;clearStack();return IFKYW;}
"else"      {if_block_size = 0;clearStack();return ELSEKYW;}
"else if"   {if_block_size = 0;clearStack();return ELSEIFKYW;}

"("			return OPENPAR;
")"			return CLOSEPAR;
"\""		return QUOTE;
"#" 		return HASH;
"<"			{comp = 1;return SMALLER;}
">"			{comp = 1;return GREATER;}
"=" 		return ASSIGNOP;
"+" 		return PLUSOP;
"-" 		return MINUSOP;
"*"		 	return MULTIPLYOP;
"/" 		return DIVIDEOP;
";" 		return SEMICOLUMN;
"{"			return OPENCURLY;
"}"			return CLOSCURLY;
","			return COMMA;
{alpha}({digit}|{alpha})* {yylval.string = strdup(yytext); return VARIABLE;}

{digit}+            {yylval.string = strdup(yytext); return INTEGER;}
\n  ++linenum;
.
%%
