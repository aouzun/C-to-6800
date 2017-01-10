#include <stdio.h>
int main(){
    int a = 10;
    int b = 2;
    int c = 4;
    int d = 6;
    int e;
    if(a < b){
        e = a*b*c*d;
    }
    else if(a < c){
        e = b*c*d;
    }
    else if(a < d){
        e = c*d;
    }
    else{
        e = a*d;
    }
    
    
}