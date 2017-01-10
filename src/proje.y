%{
#include "list.h"
#include "stack.h"
#include "instructionqueue.h"
#include<stdio.h>
#include <string.h>
#include <stdlib.h>
extern FILE* yyin;
FILE* out;
extern int linenum;

// Stack is used for parsing arithmetic operations (reverse polish notation)
// Queue is used for transforming the simple instructions to assembly


extern struct Stack_Node* stack;
extern struct List_Node* list;
void yyerror(const char*);

// Starting addresses
int variable_start = 2000;
int template_start = 3000;
// Total unique if counts
int total_if_count = 0;
// Total unique if block counts
int total_if_block_count = 0;
// Multiplicaton and division variables are used for labels
int division = 1;
int multiplication = 1;
// local current tmp current are used for simple variable names
// if block size is used for total simple instructions in each if-elseif blocks This is resetted from lex file on each if-elseif sight.
int local_current = 0;
int if_block_size = 0;
int tmp_current   = 0;
// This is used for comparison
// If we see comparison then there will be an if statemnt
// So use this to increase if_block_size
int comp = 0;
// Temp variables for storing temp strings and labels
char tmp_id[100];
char tmp_if[100];
char current_id = 'a';


// Convert a single character to string
char* charToStr(char c){
    char* ret = (char*)malloc(sizeof(char));
    ret[0] = c;
    ret[1] = '\0';
    return ret;
}
// Get an address from variable name
// If it starts with a t then it is temp variable it should start from 3000
// If it starts with a l then it is local variable it should start from 2000
int getAddress(const char* var_name){
    return strtol(var_name+1,NULL,10) + ((var_name[0] == 'l') ? 2000 : 3000);
    
}

// Search string with a char
int strFind(const char* str,char c){
    int len = strlen(str);
    int i = 0;
    while(i < len){
        if(str[i] == c){
            break;
        }
        ++i;
    }
    if(i == len) return -1;
    return i;
}

// This function is used to parse simplified instructions to assembly code
void parseInstruction(const char* instruction){
    // Check if there is an assignment operation inside instruction
    int assignIndex = strFind(instruction,'=');
    
    // If there is no assignment goes here
    if(assignIndex < 0){
        // Check if the instruction is final instruction
        // Then put .END
        if(instruction[0] == '.'){
            fprintf(out,"\t.END\n");
        }
        // This checks if the instruction is an if statement
        else if(instruction[0] == 'i' && instruction[1] == 'f'){
            // These are used for labels
            // Every if block has if label and level label
            // Every unique if increases this total_if_count
            // Every blocks in if and else if increases total_block_count
            ++total_if_count;
            ++total_if_block_count;
            // This 2 while loops will get leftSide and rightSide of the comparison in the if statement
            char leftSide[100];
            char rightSide[100];
            int i = 3;
            int option;
            while(instruction[i] != '<' && instruction[i] != '>'){
                leftSide[i-3] = instruction[i];
                ++i;
            }
            if(instruction[i] == '<') option = -1;
            if(instruction[i] == '>') option = 1;
            leftSide[i] = '\0';
            ++i;
            int j = 0;
            while(i < strlen(instruction)){
                rightSide[j] = instruction[i];
                ++j;
                ++i;
            }
            rightSide[j] = '\0';
            
            
            // This ifs are used for getting addresses
            // These check if they are local or temp or it is just integer literal
            // if they are local or temp use their address for further operations
            // if they are integer literals just use the numbers
            
            if(leftSide[0] == 't' || leftSide[0] == 'l'){
                char mode  = '$';
                int address = getAddress(leftSide);
                fprintf(out,"\tLDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tLDAA %c%s\n",mode,leftSide);
            }
            
            if(rightSide[0] == 't' || rightSide[0] == 'l'){
                char mode = '$';
                int address = getAddress(rightSide);
                fprintf(out,"\tCMPA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tCMPA %c%s\n",mode,rightSide);
            }
            
            // Prepare a label for further use
            sprintf(tmp_if,"I%dF%d",total_if_count,total_if_block_count);
           
            // Jump if smaller or equal
            if(option == 1){
                fprintf(out,"\tBLE %s\n",tmp_if);
            }
            // Jump if greater or equal
            else if(option == -1){
                fprintf(out,"\tBGE %s\n",tmp_if);
            }
            
        }
        else if(strlen(instruction) > 7 && instruction[5] == 'i' && instruction[6] == 'f'){
            // Just increase total_if_block_count 
            ++total_if_block_count;
            
            // Still same 2 while loops as before to get leftSide and rightSide of the comparison
            
            char leftSide[100];
            char rightSide[100];
            int i = 8;
            int option;
            while(instruction[i] != '<' && instruction[i] != '>'){
                leftSide[i-8] = instruction[i];
                ++i;
            }
            if(instruction[i] == '<') option = -1;
            if(instruction[i] == '>') option = 1;
            leftSide[i] = '\0';
            ++i;
            int j = 0;
            while(i < strlen(instruction)){
                rightSide[j] = instruction[i];
                ++j;
                ++i;
            }
            rightSide[j] = '\0';
            
            // Check if the leftSide and rightSide are variables or literals
            // If they are variables get their addresses and operate on the addresses
            // If they are literals use integers
            
            if(leftSide[0] == 't' || leftSide[0] == 'l'){
                char mode  = '$';
                int address = getAddress(leftSide);
                fprintf(out,"\tLDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tLDAA %c%s\n",mode,leftSide);
            }
            
            if(rightSide[0] == 't' || rightSide[0] == 'l'){
                char mode = '$';
                int address = getAddress(rightSide);
                fprintf(out,"\tCMPA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tCMPA %c%s\n",mode,rightSide);
            }
            
            // prepare label for future
            sprintf(tmp_if,"I%dF%d",total_if_count,total_if_block_count);
            //++total_if_block_count;
            // Jump if smaller or equal
            if(option == 1){
                fprintf(out,"\tBLE %s\n",tmp_if);
            }
            // Jump if greater or equal
            else if(option == -1){
                fprintf(out,"\tBGE %s\n",tmp_if);
            }
           
        }
        else if(strlen(instruction) == 4){
            
        }
        // This is end of an one if-or-else if block
        // This is used to put labels that will be used if an if statement or else if statement is not satisfied
        else if(instruction[0] == 'e' && instruction[1] == '1'){
            char tmp[100];
            sprintf(tmp,"%s",tmp_if);
            tmp[strlen(tmp)-1] = 'F';
            fprintf(out,"\tBRA %s\n",tmp);
            fprintf(out,"%s\tNOP\n",tmp_if);
        }
        // This is end of whole if-elseif-else block
        // If a condition is satisfied for any of blocks it jumps here after that block ends
        else if(instruction[0] == 'e' && instruction[1] == '2'){
            char tmp[100];
            sprintf(tmp,"%s",tmp_if);
            tmp[strlen(tmp)-1] = 'F';
            fprintf(out,"%s",tmp);
        }
    } 
    else{
        // If we enter here, this place is used for binary operations
        // Something like a=b+c
        // We have to figure which operations is used
        // For those operations write specific code
        
        // Search operation indexes
        // All but one are negative the other one will be used for further operations
        int length = strlen(instruction);
        int plus = strFind(instruction,'+');
        int minus = strFind(instruction,'-');
        int multiply = strFind(instruction,'*');
        int divide = strFind(instruction,'/');
        // Get the leftSide of the assignment operation
        char leftSide[assignIndex];
        memcpy(leftSide,instruction,assignIndex);
        leftSide[assignIndex] = '\0';
        // If it is an addition enter here
        if(plus >= 0){
            
            // This operations are used for getting the 'b' and 'c' in the a=b+c part
            // In other words first and second operands
            char first[plus-assignIndex-1];
            memcpy(first,instruction+assignIndex+1,plus-assignIndex-1);
            first[plus-assignIndex-1] = '\0';
            char second[length-1-plus+1];
            memcpy(second,instruction+plus+1,length-1-plus+1);
            second[length-1-plus+1] = '\0';
            
            // Check if Operands are literals or variables
            // If variables get addresses
            // Load to Acumulator A
            if(first[0] == 't' || first[0] == 'l'){
                int address = getAddress(first);
                char mode = '$';
                fprintf(out,"	LDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"	LDAA %c%s\n",mode,first);
            }
            
            if(second[0] == 't' || second[0] == 'l'){
                int address = getAddress(second);
                char mode = '$';
                fprintf(out,"	ADDA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"	ADDA %c%s\n",mode,second);
            }
            
            fprintf(out,"	STAA $%d\n",getAddress(leftSide));
            
            
        }
        // If it is a subtraction enter here
        else if(minus >= 0){
            
            // Like before get two operands
            char first[minus-assignIndex-1];
            memcpy(first,instruction+assignIndex+1,minus-assignIndex-1);
            first[minus-assignIndex-1] = '\0';
            char second[length-1-minus+1];
            memcpy(second,instruction+minus+1,length-1-minus+1);
            second[length-1-minus+1] = '\0';
            
            // Check if operands are literals or variables
            // IF variables get addresses from them
            if(first[0] == 't' || first[0] == 'l'){
                int address = getAddress(first);
                char mode = '$';
                fprintf(out,"	LDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"	LDAA %c%s\n",mode,first);
            }
            
            if(second[0] == 't' || second[0] == 'l'){
                int address = getAddress(second);
                char mode = '$';
                fprintf(out,"	SUBA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"	SUBA %c%s\n",mode,second);
            }
            
            fprintf(out,"	STAA $%d\n",getAddress(leftSide));
        }
        
        // If it is a multiplication enter here
        else if(multiply >= 0){
            
            // Get 2 operands like before
            
            char first[multiply-assignIndex-1];
            memcpy(first,instruction+assignIndex+1,multiply-assignIndex-1);
            first[multiply-assignIndex-1] = '\0';
            char second[length-1-multiply+1];
            memcpy(second,instruction+multiply+1,length-1-multiply+1);
            second[length-1-multiply+1] = '\0';
            fprintf(out,"	LDAA #0\n");
            fprintf(out,"	LDAB #0\n");
            
            // There is no single instruction in assembly 6800 for multiplication
            // We have to use loops
            
            char mul_tmp[100];
            // Put a label
            sprintf(mul_tmp,"M%dS",multiplication);
            // Find if operands are literals or variables
            // While Accumulator B is not equal to the first add second to Accumulator B
            if(first[0] == 't' || first[0] == 'l'){
                int address = getAddress(first);
                char mode = '$';
                fprintf(out,"%s\tCMPA %c%d\n",mul_tmp,mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"%s\tCMPA %c%s\n",mul_tmp,mode,first);
            }
            mul_tmp[2] = 'E';
            // If it is equal jump to end
            fprintf(out,"\tBEQ %s\n",mul_tmp);
            fprintf(out,"\tINCA\n");
            if(second[0] == 't' || second[0] == 'l'){
                int address = getAddress(second);
                char mode = '$';
                fprintf(out,"\tADDB %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tADDB %c%s\n",mode,second);
            }
            mul_tmp[2] = 'S';
            // Jump back
            fprintf(out,"\tBRA %s\n",mul_tmp);
            mul_tmp[2] = 'E';
            // Put end label
            fprintf(out,"%s\tSTAB $%d\n",mul_tmp,getAddress(leftSide));
            ++multiplication;
        }
        // If it is a division enter here
        else if(divide >= 0){
            // get two operands
            char first[divide-assignIndex-1];
            memcpy(first,instruction+assignIndex+1,divide-assignIndex-1);
            first[divide-assignIndex-1] = '\0';
            char second[length-1-divide+1];
            memcpy(second,instruction+divide+1,length-1-divide+1);
            second[length-1-divide+1] = '\0';
            
            // Check if they are literals or variables
            // Decrease the number until it is smaller then the divisor
            // Increase the count in each step
            if(first[0] == 't' || first[0] == 'l'){
                char mode = '$';
                int address = getAddress(first);
                fprintf(out,"\tLDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"\tLDAA %c%s\n",mode,first);
            }
            fprintf(out,"\tLDAB #0\n");
            char div_tmp[100];
            sprintf(div_tmp,"D%dS",division);
            
            if(second[0] == 't' || second[0] == 'l'){
                char mode = '$';
                int address = getAddress(second);
                fprintf(out,"%s\tCMPA %c%d\n",div_tmp,mode,address);
                div_tmp[2] = 'E';
                // Jump to end if less than
                fprintf(out,"\tBLT %s\n",div_tmp);
                fprintf(out,"\tINCB\n");
                fprintf(out,"\tSUBA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"%s\tCMPA %c%s\n",div_tmp,mode,second);
                div_tmp[2] = 'E';
                // Jump to end if less than
                fprintf(out,"\tBLT %s\n",div_tmp);
                fprintf(out,"\tINCB\n");
                fprintf(out,"\tSUBA %c%s\n",mode,second);
            }
            
            div_tmp[2] = 'S';
            // Jump to back
            fprintf(out,"\tBRA %s\n",div_tmp);
            div_tmp[2] = 'E';
            fprintf(out,"%s\tSTAB $%d\n",div_tmp,getAddress(leftSide));
            ++division;
        }
        else{
            // this is assignment operation like a = b;
            // just load b to accumulator and store it in a
            // First learn if b is a variable or literal
            char rightSide[length-1-assignIndex+1];
            memcpy(rightSide,instruction+assignIndex+1,length-1-assignIndex+1);
            rightSide[length-1-assignIndex+1] = '\0';
            if(rightSide[0] == 't' || rightSide[0] == 'l'){
                int address = getAddress(rightSide);
                char mode = '$';
                fprintf(out,"	LDAA %c%d\n",mode,address);
            }
            else{
                char mode = '#';
                fprintf(out,"	LDAA %c%s\n",mode,rightSide);
            }
            int toAddress = getAddress(leftSide);
            fprintf(out,"	STAA $%d\n",toAddress);
        }
    }
    
    
    
    
}




%}

%union{
    char* string;
}

%token ASSIGNOP PLUSOP MINUSOP MULTIPLYOP DIVIDEOP SEMICOLUMN  OPENPAR CLOSEPAR
%token INCLUDEKYW FILENAME QUOTE HASH SMALLER GREATER RETURNKYW INTKYW CHRKYW FLTKYW DBLKYW
%token MAINKYW ELSEIFKYW ELSEKYW IFKYW
%token COMMA OPENCURLY CLOSCURLY 
%token <string> INTEGER
%token <string> VARIABLE
%type  <string> expression
%type  <string> comp_logics
%left PLUSOP MINUSOP
%left MULTIPLYOP DIVIDEOP
%left OPENPAR CLOSEPAR
%%


program: importing statements
		

;

statements: if_block statements
            |
            function_def
			|
			statement {}
            |
            statement statements {}
            ;
statement : init_variables SEMICOLUMN
			|
            VARIABLE ASSIGNOP expression SEMICOLUMN
            {
                struct List_Node* tmp_node = searchList($1);
                if(tmp_node == NULL){
                    fprintf(stderr,"Variable (%s) not declared\n",$1);
                    exit(0);
                }
                sprintf(tmp_id,"%s=%s",tmp_node->id,peek()->string);
                //fprintf(out,"%s\n",tmp_id);
                // Push back simple instruction
                push_back(createQueueNode(tmp_id));
                if_block_size += (comp ? 0 : 1);
                //clearStack();
                
            }
            |
            
            returnstate SEMICOLUMN
            |
            ;

importing: 	includestate
			|
			includestate importing
;

includestate: 	HASH INCLUDEKYW QUOTE FILENAME QUOTE
				|
				HASH INCLUDEKYW SMALLER FILENAME GREATER

;
returnstate:	RETURNKYW expression
;

// This whole rule uses the same formula
// For each binary opearation pop top 2 expression from stack
// Combine them into one and push it to the stack
// Update if_block_size
// tmp_current is used for tmp variable number
expression: INTEGER {$$ = strdup($1); push(createStackNode($$));}
            |
            VARIABLE    {   
                            // Check if the variable exist in the list
                            // if not raise en error
                            // push variable to stack
                            $$ = strdup($1);
                            struct List_Node* tmp_node = searchList($$);
                            if(tmp_node == NULL) { fprintf(stderr,"Variable (%s) not found ERROR\n",$$);}
                            else{
                                push(createStackNode(tmp_node->id));
                            }
                        }
            |
            OPENPAR expression CLOSEPAR {}
            |
            expression PLUSOP  expression   
            {   
                if(stack_size < 2) fprintf(stderr,"Stack size not enough ERROR\n");
                else{
                    sprintf(tmp_id,"t%d",tmp_current);
                    struct Stack_Node* first = pop();
                    struct Stack_Node* second = pop();
                    push(createStackNode(tmp_id));
                    
                    sprintf(tmp_id,"%s=%s+%s",peek()->string,second->string,first->string);
                    //fprintf(out,"%s\n",tmp_id);
                    push_back(createQueueNode(tmp_id));
                    if_block_size += (comp ? 0 : 1);
                    ++tmp_current;
                }
            }
            |
            expression MULTIPLYOP expression    
            {
                if(stack_size < 2) fprintf(stderr,"Stack size not enough ERROR\n");
                else{
                    sprintf(tmp_id,"t%d",tmp_current);
                    struct Stack_Node* first = pop();
                    struct Stack_Node* second = pop();
                    push(createStackNode(tmp_id));
                    
                    sprintf(tmp_id,"%s=%s*%s",peek()->string,second->string,first->string);
                    //fprintf(out,"%s\n",tmp_id);
                    push_back(createQueueNode(tmp_id));
                    if_block_size += (comp ? 0 : 1);
                    ++tmp_current;
                }
            }
            |
            expression DIVIDEOP expression  
            {
                if(stack_size < 2) fprintf(stderr,"Stack size not enough ERROR\n");
                else{
                    sprintf(tmp_id,"t%d",tmp_current);
                    struct Stack_Node* first = pop();
                    struct Stack_Node* second = pop();
                    push(createStackNode(tmp_id));
                    sprintf(tmp_id,"%s=%s/%s",peek()->string,second->string,first->string);
                    //fprintf(out,"%s\n",tmp_id);
                    push_back(createQueueNode(tmp_id));
                    if_block_size += (comp ? 0 : 1);
                    ++tmp_current;
                }
            }
            |
            expression MINUSOP expression   
            {
                {
                if(stack_size < 2) fprintf(stderr,"Stack size not enough ERROR\n");
                else{
                    sprintf(tmp_id,"t%d",tmp_current);
                    struct Stack_Node* first = pop();
                    struct Stack_Node* second = pop();
                    push(createStackNode(tmp_id));
                    sprintf(tmp_id,"%s=%s-%s",peek()->string,second->string,first->string);
                    //fprintf(out,"%s\n",tmp_id);
                    push_back(createQueueNode(tmp_id));
                    if_block_size += (comp ? 0 : 1);
                    ++tmp_current;
                }
            }
            }
            ;
            
type : INTKYW | FLTKYW | DBLKYW | CHRKYW 
;

function_def : 	 type MAINKYW OPENPAR parameter_list CLOSEPAR OPENCURLY statements CLOSCURLY
				|
				type MAINKYW OPENPAR CLOSEPAR OPENCURLY statements CLOSCURLY
;
// Because of the parse tree instructions inside the if statements pushed onto queue before if statement
// Use if_block_size to know how many instructions to pop and push again
// So we have to pop them back push if statement and push them again in the same order
// I used another stack for this process to keep the order same
// Also reset the if block size
// All 4 rules uses the same formula
if_def :    IFKYW OPENPAR comparison CLOSEPAR OPENCURLY statements CLOSCURLY
            {
                
                while(empty() == 0){
                    push2(pop());
                }
                sprintf(tmp_id,"if %s",pop2()->string);
                clearStack2();
                int i = 0;
                
                for(;i < if_block_size;++i){
                    struct Queue_Node* q = pop_back();
                    
                    push2(createStackNode(q->instruction));
                }
                push_back(createQueueNode(tmp_id));
                while(empty2() == 0){
                    push_back(createQueueNode(pop2()->string));
                }
                sprintf(tmp_id,"e1");
                push_back(createQueueNode(tmp_id));
                if_block_size=0;
            }
            |
            IFKYW OPENPAR comparison CLOSEPAR statement 
            {
                while(empty() == 0){
                    push2(pop());
                }
                sprintf(tmp_id,"if %s",pop2()->string);
                clearStack2();
                int i = 0;
                
                for(;i < if_block_size;++i){
                    push2(createStackNode(pop_back()->instruction));
                }
                push_back(createQueueNode(tmp_id));
                while(empty2() == 0){
                    push_back(createQueueNode(pop2()->string));
                }
                sprintf(tmp_id,"e1");
                push_back(createQueueNode(tmp_id));
                if_block_size=0;
            }
;
else_if_def :   ELSEIFKYW OPENPAR comparison CLOSEPAR OPENCURLY statements CLOSCURLY
                {
                    while(empty() == 0){
                        push2(pop());
                    }
                    sprintf(tmp_id,"else if %s",pop2()->string);
                    clearStack2();
                    int i = 0;
                    
                    for(;i < if_block_size;++i){
                        push2(createStackNode(pop_back()->instruction));
                    }
                    push_back(createQueueNode(tmp_id));
                    while(empty2() == 0){
                        push_back(createQueueNode(pop2()->string));
                    }
                    sprintf(tmp_id,"e1");
                    push_back(createQueueNode(tmp_id));
                    if_block_size=0;
                }
            |
                else_if_def ELSEIFKYW OPENPAR comparison CLOSEPAR OPENCURLY statements CLOSCURLY 
                
                    {
                        
                        while(empty() == 0){
                            push2(pop());
                        }
                        sprintf(tmp_id,"else if %s",pop2()->string);
                        clearStack2();
                        int i = 0;
                        
                        for(;i < if_block_size;++i){
                            push2(createStackNode(pop_back()->instruction));
                        }
                        push_back(createQueueNode(tmp_id));
                        while(empty2() == 0){
                            push_back(createQueueNode(pop2()->string));
                        }
                        sprintf(tmp_id,"e1");
                        push_back(createQueueNode(tmp_id));
                        if_block_size=0;
                    }
                
            |
                ELSEIFKYW OPENPAR comparison CLOSEPAR statement
                
                    {
                        while(empty() == 0){
                            push2(pop());
                        }
                        sprintf(tmp_id,"else if %s",pop2()->string);
                        clearStack2();
                        int i = 0;
                        
                        for(;i < if_block_size;++i){
                            push2(createStackNode(pop_back()->instruction));
                        }
                        push_back(createQueueNode(tmp_id));
                        while(empty2() == 0){
                            push_back(createQueueNode(pop2()->string));
                        }
                        sprintf(tmp_id,"e1");
                        push_back(createQueueNode(tmp_id));
                        if_block_size=0;
                    }
                
            |
                else_if_def ELSEIFKYW OPENPAR comparison CLOSEPAR statement 
                {
                    while(empty() == 0){
                        push2(pop());
                    }
                    sprintf(tmp_id,"else if %s",pop2()->string);
                    clearStack2();
                    int i = 0;
                    
                    for(;i < if_block_size;++i){
                        push2(createStackNode(pop_back()->instruction));
                    }
                    push_back(createQueueNode(tmp_id));
                    while(empty2() == 0){
                        push_back(createQueueNode(pop2()->string));
                    }
                    sprintf(tmp_id,"e1");
                    push_back(createQueueNode(tmp_id));
                    if_block_size=0;
                }
;
else_def :  ELSEKYW OPENCURLY statements CLOSCURLY
            |
            ELSEKYW statement
;

// This are used when an if block reaches end
if_block :  if_def {char tmp[100]; sprintf(tmp,"%s","e2"); push_back(createQueueNode(tmp));}
            |
            if_def else_if_def {char tmp[100]; sprintf(tmp,"%s","e2"); push_back(createQueueNode(tmp));}
            |
            if_def else_if_def else_def {char tmp[100]; sprintf(tmp,"%s","e2"); push_back(createQueueNode(tmp));}
            |
            if_def else_def {char tmp[100]; sprintf(tmp,"%s","e2"); push_back(createQueueNode(tmp));}
;

parameter_list : type VARIABLE
				|
				 type VARIABLE COMMA parameter_list
				 |
;
// First if the variable already exists. If so give an error
// Create simple tag for variable with local current
// Create its list node and add it
// push it onto instruction queue
// Change if block
// Increment local current

// Same for all rules
// If it is an expression look at stack
variable_decl:	VARIABLE  
                    {
                        
                        struct List_Node* tmp_node = searchList($1);
                        if(tmp_node != NULL){
                            printf("%s defined before\n",$1);
                            exit(0);
                        }
                        sprintf(tmp_id,"l%d",local_current);
                        
                        
                        tmp_node = createListNode($1,tmp_id);
		                addToList(tmp_node);
		                sprintf(tmp_id,"%s=%d",tmp_node->id,0);
		                push_back(createQueueNode(tmp_id));
		                if_block_size += (comp ? 0 : 1);
		                //fprintf(out,"%s\n",tmp_id);
                        //clearStack();
                        ++local_current;
                    }
				|
				VARIABLE ASSIGNOP expression 
					{
					
		            struct List_Node* tmp_node = searchList($1);
		            if(tmp_node != NULL){
		            	printf("%s defined before\n",$1);
		            	exit(0);
		            }
		            sprintf(tmp_id,"l%d",local_current);
		            
		            tmp_node = createListNode($1,tmp_id);
		            addToList(tmp_node);
		            
		            sprintf(tmp_id,"%s=%s",tmp_node->id,peek()->string);
		            push_back(createQueueNode(tmp_id));
		            if_block_size += (comp ? 0 : 1);
		            //fprintf(out,"%s\n",tmp_id);
		            //clearStack();
                    ++local_current;
            		}
				|
				variable_decl COMMA VARIABLE 
				{
                        struct List_Node* tmp_node = searchList($3);
                        if(tmp_node != NULL){
                            printf("%s defined before\n",$3);
                            exit(0);
                        }
                        sprintf(tmp_id,"l%d",local_current);
                        
		                tmp_node = createListNode($3,tmp_id);
		                addToList(tmp_node);
		                sprintf(tmp_id,"%s=%d",tmp_node->id,0);
		                push_back(createQueueNode(tmp_id));
		                if_block_size += (comp ? 0 : 1);
		                //fprintf(out,"%s\n",tmp_id);
                        //clearStack();
                        ++local_current;
                }
				|
				variable_decl COMMA VARIABLE ASSIGNOP expression 
				{
					
		            struct List_Node* tmp_node = searchList($3);
		            if(tmp_node != NULL){
		            	printf("%s defined before\n",$3);
		            	exit(0);
		            }
		            sprintf(tmp_id,"l%d",local_current);
		            
		            tmp_node = createListNode($3,tmp_id);
		            addToList(tmp_node);
		            sprintf(tmp_id,"%s=%s",tmp_node->id,peek()->string);
		            push_back(createQueueNode(tmp_id));
		            if_block_size += (comp ? 0 : 1);
		            //fprintf(out,"%s\n",tmp_id);
		            
		            //clearStack();
		            ++local_current;
            	}

;
init_variables: type variable_decl  
;


// Pop to from stack and compare them
comparison: expression comp_logics expression
        {
            
            struct Stack_Node *first = pop();
            struct Stack_Node *second = pop();
            sprintf(tmp_id,"%s%s%s",second->string,$2,first->string);
            push(createStackNode(tmp_id));
            comp = 0;
        }
;


comp_logics :
            SMALLER {char a[1]; a[0]='<'; $$ = strdup(a); $$[1] = '\0';}
            |
            GREATER {char a[1]; a[0]='>'; $$ = strdup(a); $$[1] = '\0';}

%%

void yyerror(const char* c){
    fprintf(stderr,"%s at line %d\n",c,linenum);
}
int yywrap(void){
    return 1;
}
int main(int args,char **argv){
    yyin = fopen(argv[1],"r");
    out = fopen("output.asm","w");
    yyparse();
    
    fclose(yyin);
    push_back(createQueueNode(charToStr('.')));
    while(qempty() == 0) {
        struct Queue_Node* q = pop_front();
        //printf("%s\n",q->instruction);
        parseInstruction(q->instruction); 
    }
    
}   
