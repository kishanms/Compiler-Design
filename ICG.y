%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
void yyerror(const char *s);
extern FILE *yyin;

struct exprType{

	char *addr;
	char *code;
	
};

int n=1;
int nl = 1;
char *var;
char num_to_concat[10];
char num_to_concat_l[10];
char *ret;
char *temp;

char *label;
char *label2;
char *check;

char *begin;

char *b1;
char *b2;

char *s1;
char *s2;

struct exprType *to_return_expr;

char * newTemp(){
	
	char *newTemp = (char *)malloc(20);
	strcpy(newTemp,"t");
	snprintf(num_to_concat, 10,"%d",n);
	strcat(newTemp,num_to_concat);
		
	n++;
	return newTemp;
}

char * newLabel(){
	
	char *newLabel = (char *)malloc(20);
	strcpy(newLabel,"L");
	snprintf(num_to_concat_l, 10,"%d",nl);
	strcat(newLabel,num_to_concat_l);
		
	nl++;
	return newLabel;
}
%}

%start startSym

%union {
	int ival;
	float fval;
	char *sval;
	struct exprType *EXPRTYPE;
}
%token <ival> DIGIT
%token <fval> FLOAT
%token <sval> ID IF ELSE TYPES REL_OPT OR AND NOT TRUE FALSE PRINT SCAN
%token <sval> '+' '-' '*' '/' '^' '%' '\n' '=' ';'
%type <sval> list text number construct block dec bool program startSym
%type <EXPRTYPE> expr stat

%left OR
%left AND
%left NOT
%left REL_OPT
%right '='
%left '+' '-'
%left '*' '/' '%'
%right '^'

%%

startSym:	program
		{
			//printf("I'm starting startsym");
			s1 = $1;
			label = newLabel();

			check = strstr (s1,"NEXT");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (s1,"NEXT");
				}

			ret = (char *)malloc(strlen(s1)+10);
			ret[0] = 0;

			strcat(ret,s1);
			strcat(ret,"\n");
			strcat(ret,label);
			strcat(ret," : EXIT->^\n");
			
			printf("\n----------  INTERMEDIATE CODE ----------\n");
			puts(ret);

			$$ = ret;
		}
		;

program : 	program construct
		{
			//printf("I'm starting program");
			s1 = $1;
			s2 = $2;

			label = newLabel();

			check = strstr (s1,"NEXT");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (s1,"NEXT");
				}

			ret = (char *)malloc(strlen($1)+strlen($2)+4);
			ret[0] = 0;
			strcat(ret,$1);
			strcat(ret,"\n");
			strcat(ret,label);
			strcat(ret," : ");
			strcat(ret,$2);

			//printf("program construct\n");

			//puts(ret);
			$$ = ret;
		}
		|
		construct
		{
			//printf("Final Construct \n");
			//puts($1);
			$$ = $1;
		}
		|
		list
		{	
			//printf("Final list \n");
			//puts($1);
			$$ = $1;
		}
		;

construct :     block
		{
			$$ = $1;
		}
		|
		IF '(' bool ')' block
		{
			//printf("Inside IF\n");
			
			label = newLabel();
			b1 = $3;

			check = strstr (b1,"TRUE");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"TRUE");
				}
			
			check = strstr (b1,"FAIL");
			
			while(check!=NULL){
				strncpy (check,"NEXT",4);
				//strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"FAIL");
				}

			ret = (char *)malloc(strlen(b1)+strlen($5)+4);
			ret[0] = 0;
			strcat(ret,b1);
			strcat(ret,"\n");
			strcat(ret,label);
			strcat(ret," : ");
			strcat(ret,$5);
			
			//puts(ret);
			$$ = ret;
		}
		|
		IF '(' bool ')' block ELSE block
		{
			//printf("Inside if then else\n");

			b1 = $3;
			label = newLabel();

			check = strstr (b1,"TRUE");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"TRUE");
				}
			

			label2 = newLabel();
			check = strstr (b1,"FAIL");

			while(check!=NULL){
				strncpy (check,label2,strlen(label2));
				strncpy (check+strlen(label2),"    ",(4-strlen(label2)));
				check = strstr (b1,"FAIL");
				}

			ret = (char *)malloc(strlen(b1)+strlen($5)+strlen($7)+20);
			ret[0] = 0;
			strcat(ret,b1);
			strcat(ret,"\n");
			strcat(ret,label);
			strcat(ret," : ");
			strcat(ret,$5);
			strcat(ret,"\n");
			strcat(ret,"goto NEXT");
			strcat(ret,"\n");
			strcat(ret,label2);
			strcat(ret," : ");
			strcat(ret,$7);
			
			//puts(ret);

			$$ = ret;
	
		}
		;

block:		'{' list '}'
		{
			//printf("Inside block\n");
			$$ = $2;
		}
		|
		'{' construct '}'
		{
			$$ = $2;
		}
		|
		'{' list construct '}'
		{
			//printf("Inside list construct\n");
			ret = (char *)malloc(strlen($2)+strlen($3)+2);
			ret[0] = 0;
			strcat(ret, $2);
			strcat(ret, "\n");
			strcat(ret, $3);
			//puts(ret);
			$$ = ret;
		}
		;
	 

list:    stat               /* Base Condition */
		{
			$$ = $1->code;
		}
         |
        list stat
		{
			ret = (char *)malloc(strlen($1)+strlen($2->code)+4);
			ret[0] = 0;

			strcat(ret,$1);
			strcat(ret,"\n");
			strcat(ret,$2->code);
		
			//printf("Inside list stat \n");
			//puts(ret);
			$$ = ret;
		}
	 |
        list error '\n'
         {
           yyerrok;
         }
         ;


stat:    ';'
	 {
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = $1;
		
		to_return_expr->code = (char *)malloc(2);
		to_return_expr->code[0] = 0;
		
		$$ = to_return_expr;
	 }
	 |
	 PRINT
	 {
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->code = (char *)malloc(strlen($1)+2);
		to_return_expr->code[0] = 0;
		to_return_expr->code = $1;
		$$ = to_return_expr;
	 }
	 |
	 SCAN
	 {
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->code = (char *)malloc(strlen($1)+2);
		to_return_expr->code[0] = 0;
		to_return_expr->code = $1;
		$$ = to_return_expr;
	 }
	 |
	 expr ';'
         {
		$$ = $1;
           
         }
	 |
	 dec ';'
         {
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = $1;
		
		to_return_expr->code = (char *)malloc(2);
		to_return_expr->code[0] = 0;
		
		$$ = to_return_expr;
           
         }
         |
         text '=' expr ';'
         {
	    //printf("Assignment statement \n");

		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,$1);

		strcat(ret,"=");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
	    
			
		////printf(" %s = %s \n",$1,$3->addr);
          
	    
         }
	 |
	 dec '=' expr ';'
         {
	    //printf("Dec and Assignment statement \n");
	    
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		//strcat(ret,to_return_expr->addr);
		
		strcat(ret,$1);
		strcat(ret,"=");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
			
		////printf(" %s = %s \n",$1,$3->addr);
          
	    
         }

         ;

dec : 		TYPES text 
		{	
			$$ = $2;
		}
		;

bool : 	 	expr REL_OPT expr
		{
			//printf("Inside rel opt\n");

			temp = (char *)malloc(strlen($1->code)+strlen($3->code)+50);
			temp[0] = 0;
	
			if($1->code[0]!=0){
				strcat(temp,$1->code);
				strcat(temp,"\n");
				}
			if($3->code[0]!=0){
				strcat(temp,$3->code);
				strcat(temp,"\n");
				}

			ret = (char *)malloc(50);
			ret[0] = 0;
			strcat(ret,"if(");
			strcat(ret,$1->addr);
			strcat(ret,$2);
			strcat(ret,$3->addr);
			strcat(ret,") goto TRUE \n goto FAIL");

			strcat(temp,ret);

			$$ = temp;
		}
		|
		bool OR bool
		{
			//printf("Inside OR\n");
			
			b1 = $1;
			b2 = $3;

			label = newLabel();

			check = strstr (b1,"FAIL");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"FAIL");
				}
			
			temp = (char *)malloc(strlen(b1)+strlen(b2)+10);
			temp[0] = 0;

			strcat(temp,b1);
			strcat(temp,"\n");
			strcat(temp,label);
			strcat(temp," : ");
			strcat(temp,b2);

			$$ = temp;
		}
		|
		bool AND bool
		{
			//printf("Inside AND\n");

			b1 = $1;
			b2 = $3;

			label = newLabel();

			check = strstr (b1,"TRUE");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"TRUE");
				}
			
			temp = (char *)malloc(strlen(b1)+strlen(b2)+10);
			temp[0] = 0;

			strcat(temp,b1);
			strcat(temp,"\n");
			strcat(temp,label);
			strcat(temp," : ");
			strcat(temp,b2);

			$$ = temp;
		}
		|
		NOT '(' bool ')'
		{
			//printf("Inside NOT\n");
			//puts($3);

			b1 = $3;

			label = "TEFS";

			check = strstr (b1,"TRUE");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				//strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"TRUE");
				}
			
			label = "TRUE";
			check = strstr (b1,"FAIL");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				//strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"FAIL");
				}

			label = "FAIL";
			check = strstr (b1,"TEFS");
			
			while(check!=NULL){
				strncpy (check,label,strlen(label));
				//strncpy (check+strlen(label),"    ",(4-strlen(label)));
				check = strstr (b1,"TEFS");
				}
			
			$$ = b1;
		}
		|
		'(' bool ')'
		{
			$$ = $2;
		}
		|
		TRUE
		{
			//printf("Inside TRUE\n");

			ret = (char *)malloc(20);
			ret[0] = 0;
			strcat(ret,"\ngoto TRUE");
			
			$$ = ret;
		}
		|
		FALSE
		{
			//printf("Inside FALSE\n");
			
			//printf("Inside TRUE\n");

			ret = (char *)malloc(20);
			ret[0] = 0;
			strcat(ret,"\ngoto FAIL");
			
			$$ = ret;
		}
		;

expr:    '(' expr ')'
         {
           $$ = $2;
         }
         |
	 expr '^' expr
         {
		//printf("Exponential : ");
		
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"^");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
	
         }
	 |
         expr '*' expr
         {

           //printf("Multiplication : ");
	   	to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"*");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
           
         }
         |
         expr '/' expr
         {
           //printf("Division : ");
	  	to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"/");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
	   
         }
         |
         expr '%' expr
         {
           //printf("Modulo Division : ");
	   	to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();
		
		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"%");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
         }
         |
         expr '+' expr
         {
           //printf("Addition : ");
	   	to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();

		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"+");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);

		to_return_expr->code = temp;

           	$$ = to_return_expr;
         }
         |
         expr '-' expr
         {
	   //printf("Subtraction : ");
           	to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = newTemp();

		ret = (char *)malloc(20);
		ret[0] = 0;

		strcat(ret,to_return_expr->addr);

		strcat(ret,"=");
		strcat(ret,$1->addr);
		strcat(ret,"-");
		strcat(ret,$3->addr);
		//printf("RET  = \n");
		//puts(ret);

		temp = (char *)malloc(strlen($1->code)+strlen($3->code)+strlen(ret)+6);

		temp[0] = 0;
		
		if ($1->code[0]!=0){
			strcat(temp,$1->code);
			strcat(temp,"\n");
			}
		if ($3->code[0]!=0){
			strcat(temp,$3->code);
			strcat(temp,"\n");
			}
		strcat(temp,ret);
		//printf("TEMP = \n");

		//puts(temp);
		
		to_return_expr->code = temp;

           	$$ = to_return_expr;
		
         }
         |
	 text {
		//printf("Inside text\n");
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = $1;

		to_return_expr->code = (char *)malloc(2);
		to_return_expr->code[0] = 0;

		$$ = to_return_expr;}
         |
         number {
		//printf("Inside Number\n");
		to_return_expr = (struct exprType *)malloc(sizeof(struct exprType));
		to_return_expr->addr = (char *)malloc(20);
		to_return_expr->addr = $1;
		
		to_return_expr->code = (char *)malloc(2);
		to_return_expr->code[0] = 0;
		
		$$ = to_return_expr;}
         ;

text: 	ID
         {
		//printf("Inside Identifier : %s\n",$1);
           	$$ = $1;
         }
	  ;

number:  DIGIT
         {
		//printf("Inside DIGIT : %d\n",$1);
		var = (char *)malloc(20);
           	snprintf(var, 10,"%d",$1);
		$$ = var;
           
         } 
	 |
         FLOAT
         {
		//printf("Inside FLOAT : %f\n",$1);
		var = (char *)malloc(20);
           	snprintf(var, 10,"%f",$1);
		$$ = var;
           
         } 
	;
	
%%

int main() {
	// open a file handle to a particular file:
	FILE *myfile = fopen("Input.c", "r");
	// make sure it is valid:
	if (!myfile) {
		printf("File open failed: Input.c");
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	return 0;
}

void yyerror(const char *s) {
	//printf("EEK, parse error!  Message: ");
	//puts(s);
	//printf("\n");
	// might as well halt now:
	exit(-1);
}
