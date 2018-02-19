ICG: ICG.l ICG.y Input.c
	lex ICG.l
	yacc -d ICG.y
	gcc y.tab.c lex.yy.c -lfl -o ICG
