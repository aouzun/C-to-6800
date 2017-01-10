#ifndef __QUEUE__H
#define __QUEUE__H
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


// A simple node which holds a string
struct Queue_Node{
    struct Queue_Node* prev;
    struct Queue_Node* next;
    char* instruction;
};

struct Queue_Node* queue;
struct Queue_Node* tail;


// Peek front
struct Queue_Node* qpeek(void);
// Push back a node
void push_back(struct Queue_Node*);
// Pop from front
struct Queue_Node* pop_front(void);
// Empty the queue
int qempty();
// Creates a node with a given string
struct Queue_Node* createQueueNode(const char*);
// Pops from back Used for if statements
struct Queue_Node* pop_back(void);


#endif