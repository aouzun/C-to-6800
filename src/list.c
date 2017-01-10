#include "list.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct List_Node* list = NULL;

void addToList(struct List_Node* nd){
    nd->right = list;
    nd->left = NULL;
    if(list != NULL) list->left = nd;
    list = nd;
    
}
void traverseList(){
    struct List_Node* tmp = list;
    
    while(tmp != NULL){
        printf("%s\n",tmp->string);
        tmp = tmp->right;
    }
}
void clearList(){
    struct List_Node* tmp = list;
    if(tmp == NULL) return;
    while(tmp->right != NULL){
        tmp = tmp->right;
        free(tmp->left);
    }
    free(tmp);
    list = NULL;
}
struct List_Node* createListNode(const char *str,const char *str2){
    struct List_Node* tmp = (struct List_Node*)malloc(sizeof(struct List_Node));
    tmp->string = strdup(str);
    tmp->id = strdup(str2);
    tmp->left = NULL;
    tmp->right = NULL;
    
    return tmp;
}

struct List_Node* searchList(const char* str){
    struct List_Node* tmp = list;
    while(tmp != NULL){
        if(strcmp(tmp->string,str) == 0) return tmp;
        tmp = tmp->right;
    }
    return tmp;
}
