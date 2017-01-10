#include "instructionqueue.h"

struct Queue_Node* tail = NULL;
struct Queue_Node* queue = NULL;
struct Queue_Node* qpeek(){
    return queue;
}

void push_back(struct Queue_Node* q_n){
    q_n->next = NULL;
    q_n->prev = tail;
    if(tail == NULL){
        queue = q_n;
        
    }
    else{
        tail->next = q_n;
    }
    tail = q_n;
    
}

struct Queue_Node* pop_front(void){
    struct Queue_Node* tmp = queue;
    if(queue != NULL) queue = queue->next;
    if(queue != NULL) queue->prev = NULL;
    if(tmp != NULL) tmp->next = NULL;
    if(queue == NULL) tail = NULL;
    return tmp;
}

int qempty(void){
    return queue == NULL;
}
struct Queue_Node* createQueueNode(const char* str){
    struct Queue_Node* tmp = (struct Queue_Node*)malloc(sizeof(struct Queue_Node));
    tmp->instruction = strdup(str);
    tmp->next = NULL;
    tmp->prev = NULL;
}

struct Queue_Node* pop_back(void){
    struct Queue_Node* tmp = tail;
    if(tail != NULL) tail = tail->prev;
    if(tail != NULL) tail->next = NULL;
    if(tmp != NULL) tmp->prev = NULL;
    if(tail == NULL) queue = NULL;
    return tmp;
}