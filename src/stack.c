#include "stack.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct Stack_Node* stack = NULL;
struct Stack_Node* stack2 = NULL;
int stack_size = 0;
struct Stack_Node* peek(){
    return stack;
}
void push(struct Stack_Node* nd){
    ++stack_size;
    nd->next = stack;
    nd->prev = NULL;
    if(stack != NULL) stack->prev = nd;
    stack = nd;
}

struct Stack_Node* pop(void){
    struct Stack_Node* tmp = stack;
    stack_size = stack_size == 0 ? 0 : stack_size - 1;
    if(stack != NULL) stack = stack->next;
    if(stack != NULL) stack->prev = NULL;
    if(tmp   != NULL) tmp->next = NULL;
    return tmp;
}

void clearStack(void){
    struct Stack_Node* tmp = stack;
    if(tmp == NULL) return;
    while(tmp->next != NULL){
        free(tmp->prev);
        tmp = tmp->next;
    }
    free(tmp);
    stack = NULL;
    stack_size = 0;
}
struct Stack_Node* createStackNode(const char* str){
    struct Stack_Node* tmp = (struct Stack_Node*) malloc(sizeof(struct Stack_Node));
    tmp->prev = NULL;
    tmp->next = NULL;
    tmp->string = strdup(str);
    return tmp;
}

int empty(){
    return stack == NULL;
}

int stack2_size = 0;
struct Stack_Node* peek2(){
    return stack2;
}
void push2(struct Stack_Node* nd){
    ++stack2_size;
    nd->next = stack2;
    nd->prev = NULL;
    if(stack2 != NULL) stack2->prev = nd;
    stack2 = nd;
}

struct Stack_Node* pop2(void){
    struct Stack_Node* tmp = stack2;
    stack2_size = stack2_size == 0 ? 0 : stack2_size - 1;
    if(stack2 != NULL) stack2 = stack2->next;
    if(stack2 != NULL) stack2->prev = NULL;
    if(tmp   != NULL) tmp->next = NULL;
    return tmp;
}

void clearStack2(void){
    struct Stack_Node* tmp = stack2;
    if(tmp == NULL) return;
    while(tmp->next != NULL){
        free(tmp->prev);
        tmp = tmp->next;
    }
    free(tmp);
    stack2 = NULL;
    stack2_size = 0;
}


int empty2(){
    return stack2 == NULL;
}