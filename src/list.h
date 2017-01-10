#ifndef __LIST__H
#define __LIST__H

// A simple list node which holds 2 strings - string and id
struct List_Node{
    struct List_Node* left;
    struct List_Node* right;
    char* string;
    char*  id;
};
struct List_Node* head;


// Add to list
void addToList(struct List_Node*);

// Traverse the whole list
void traverseList();
// Clears the list
void clearList();
// creates a list node with given string and id parameters
struct List_Node* createListNode(const char *,const char *);
// Search list if found return corresponding node, if not found return NULL
struct List_Node* searchList(const char*);

#endif 