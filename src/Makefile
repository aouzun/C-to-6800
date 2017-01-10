all: yacc lex
	gcc lex.yy.c y.tab.c -o proje list.c stack.c instructionqueue.c
yacc: proje.y
	yacc -d proje.y
lex:  proje.l
	lex proje.l
	


