#ifndef __STACK__H
#define __STACK__H

struct Stack_Node{
    struct Stack_Node* prev;
    struct Stack_Node* next;
    char* string;
};

// Two stacks first for parsing the arithmatic operations
// Second is used in if statements
struct Stack_Node* stack;
struct Stack_Node* stack2;
int stack_size;
int stack2_size;
// Peek returns the top of the stack
struct Stack_Node* peek(void);
// Add an item at the top of the stack
void push(struct Stack_Node*);
// remove an item from top of the stack
struct Stack_Node* pop(void);
// Check if the stack is empty
int empty(void);
// Delete all items from stack
void clearStack(void);
// Create a stack node with given parameters
struct Stack_Node* createStackNode(const char*);
// Returns the top of the stack2
struct Stack_Node* peek2(void);
// Push a node to top of the stack2
void push2(struct Stack_Node*);
// Remove a node from top of the stack2
struct Stack_Node* pop2(void);
// Check if the stack2 is empty
int empty2(void);
// remove all items from stack2
void clearStack2(void);

#endif