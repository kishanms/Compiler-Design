#!/usr/bin/env python3
#helios.code
from Lexer import lexer
import sys

class parser:
    def __init__(self, file_name):
        self.file_name = file_name
        self.lex = lexer(self.file_name)
        self.lex.start()
        self.lex_tokens = self.lex.get_tokens()
        self.tokens = list(self.lex_tokens)
        self.current = -1
        self.exprend = [')', '(', ';', '||', '&&', '<', '>', '!', '==']
        self.declared = {}
        self.fill_declared()
        self.optimize()
        self.label_count = 0
        
    def fill_declared(self):
        i = 0
        l = len(self.lex_tokens)
        while(i<l):
            if self.lex_tokens[i][3] == "DataType":
                datatype = self.lex_tokens[i][1]
                i+=1
                while(self.lex_tokens[i][3] == "Identifier" and i<l):
                    arrstr = ""
                    if(i+1<l and self.lex_tokens[i+1][1] == "["):
                        if(self.lex_tokens[i+1] in self.tokens):
                            self.tokens.remove(self.lex_tokens[i+1])
                        arrstr+= str(self.lex_tokens[i][1])+"["
                        i+=2
                        if(i<l and self.lex_tokens[i][3] == "Number"):
                            #helios.code1
                            if(self.lex_tokens[i] in self.tokens):
                                self.tokens.remove(self.lex_tokens[i])
                            arrstr += str(self.lex_tokens[i][1])
                            i+=1
                        if(i<l and self.lex_tokens[i][1] == "]"):
                            if(self.lex_tokens[i] in self.tokens):
                                self.tokens.remove(self.lex_tokens[i])
                            arrstr += "]" 
                            i+=1
                            self.declared[arrstr[0]] = datatype+"Array"
                            
                            if(i<l and self.lex_tokens[i][1] == ","):
                                i+=1
                            elif(i<l and self.lex_tokens[i][1] in [";", "="]):
                                i+=1
                                break
                            else:
                                print("Error parsing after: ",self.lex_tokens[i])
                                i+=1
                                break

                    self.declared[self.lex_tokens[i][1]] = datatype 
                    i+=1
                    if(i<l):
                        if(self.lex_tokens[i][1] == ","):
                            i+=1
                            continue
                        elif(self.lex_tokens[i][1] == ";"):
                            continue
            i+=1   
    
    def optimize(self):
        temp = list(self.tokens)
        for i in self.tokens:
            if "[" in i:
                print("here ",i)
                x = self.tokens.index(i)
                temp.remove(self.tokens[x])
                temp.remove(self.tokens[x+1])
                temp.remove(self.tokens[x+2])
        self.tokens = temp

    def next_token(self):
        if self.current+1 < len(self.tokens):
            #print("Giving next token: ",self.tokens[self.current+1])
            self.current += 1
            return self.tokens[self.current]

    def prev_token(self):
        self.current -= 1
        return self.tokens[self.current]    

    def reset_token(self):
        self.current = -1
        return self.next_token()

    def start(self):
        print("Starting parser")
        tok = self.next_token()
        while(self.check_declaration(tok)):
            tok = self.next_token()
        if(self.check_if(tok)):
            tok = self.next_token()
            if(tok):
                if(self.check_else(tok)):
                    tok = self.next_token()
                    if(tok):
                        if(self.check_statement(tok)):
                            print("Parsing success\n")
                    else:
                        print("Parsing success\n")
                elif(self.check_statement(tok)):
                    print("Parsing success\n")
            else:
                print("Parsing success\n")        
        else:   
            print("Parsing unsuccessful\n")
        return

    def check_if(self,tok):
        print("Check if: ", tok)
        if tok[1] == 'if':
            tok = self.next_token()
            if(self.check_round_paranthesis(tok)):
                tok = self.next_token()
                if(self.check_flower_paranthesis(tok)):
                    return True   
     
    def check_round_paranthesis(self, tok):
        print("Check round braces: ",tok)
        if tok[3] == 'RoundLpar':
            tok = self.next_token()
            if(self.check_condition(tok)):
                tok = self.next_token()
                if tok[3] == 'RoundRpar':
                    return True

    def check_condition(self, tok):
        print("Check condition: ",tok)
        if(self.check_expression(tok)):
            tok = self.next_token()
            if(self.check_logical(tok)):
                tok = self.next_token()
                if(self.check_expression(tok)):
                    return True

            elif(self.check_relational(tok)):
                tok = self.next_token()
                if(self.check_expression(tok)):
                    return True

            elif(tok[3] == 'RoundRpar'):
                self.current -= 1
                return True

    def check_expression(self, tok):
        print("Check expression: ",tok)
        if(tok[3] == "RoundLpar"):
            tok = self.next_token()
            if(self.check_expression(tok)):
                tok = self.next_token()
                if(tok[3] == "RoundRpar"):
                    tok = self.next_token()
                    if(tok[1] in self.exprend):
                        self.current-=1
                        return True
                    elif(self.check_expression1(tok)):
                        return True
        elif(self.check_terminal(tok)):
            tok = self.next_token()
            if(self.check_expression1(tok)):
                return True
    
    def check_expression1(self, tok):
        print("Check expression^: ",tok)
        if(tok[3] in ["MathOp", "RelOp"]):
            tok = self.next_token()
            if(self.check_terminal(tok)):
                tok = self.next_token()
                if(tok[1] in self.exprend):
                    self.current-=1
                    return True
                elif(self.check_expression1(tok)):
                    return True
        elif(tok[3] == 'UnaryOp'):
            return True
        elif(tok[1] in self.exprend):
            self.current-=1
            return True

    def check_math(self, tok):
        print("Check math-operator: ",tok)
        if(tok[3] in ['MathOp', 'UnaryOp']):
            return True

    def check_terminal(self, tok):
        print("Check terminal: ",tok)
        if(tok[3] == "Identifier"):
            if(tok[1] in self.declared):
                return True
            else:
                print(tok[1]," is Undeclared")
                sys.exit(0)
        elif(tok[3] == "Number"):
            return True
        else:
            print("Error parsing after: ",tok);

    def check_logical(self, tok):
        if(tok[3] == "LogicalOp"):
            return True

    def check_relational(self, tok):
        if(tok[3] == "RelOp"):
            return True

    def check_flower_paranthesis(self, tok):
        print("Check flower braces: ",tok)
        if(tok[3] == "FlowerLpar"):
            #helios.code2
            tok = self.next_token()
            while(self.check_statement(tok)):
                tok = self.next_token()
                if(tok[3] == "FlowerRpar"):
                    return True

    def check_statement(self, tok):
        print("Check statement: ", tok)
        if(self.check_if(tok)):
            tok = self.next_token()
            if(self.check_else(tok)):
                return True
            else:
                tok = self.prev_token()
                return True
        elif(self.check_assign(tok)):
            return True
        elif(self.check_printscan(tok)):
            return True

    def check_assign(self, tok):
        print("Check assignment: ", tok)
        if(self.check_declaration(tok)):
            return True

        elif(self.check_identifier(tok)):
            tok = self.next_token()
            if tok[3] == "AssignOp":
                tok = self.next_token()
                if(self.check_expression(tok)):
                    tok = self.next_token()
                    if(self.check_semicolon(tok)):
                        return True
            
            elif tok[3] == "UnaryOp":
                tok = self.next_token()
                if(self.check_semicolon(tok)):
                    return True

    def check_identifier(self, tok):
        print("Check identifier: ", tok)
        if(tok[3] == "Identifier"):
            if(tok[1] in self.declared):
                return True
            else:
                print(tok[1]," is Undeclared")
                sys.exit(0)

    def check_declaration(self, tok):
        print("Check declaration: ", tok);
        if(tok[3] == "DataType"):
            tok = self.next_token()
            if(self.check_identifier(tok)):
                tok =self.next_token()
                if(self.check_semicolon(tok)):
                    return True
                elif(tok[3] == 'AssignOp'):
                    tok = self.next_token();
                    if(self.check_expression(tok)):
                        tok = self.next_token()
                        if(self.check_semicolon(tok)):
                            return True

    def check_printscan(self, tok):
        print("Check printf-scanf: ",tok)
        if(tok[3] in ["PrintFn", "ScanFn"]):
            #helios.code3
            tok = self.next_token()
            if(tok[3] == "RoundLpar"):
                tok = self.next_token()
                if(tok[3] == "String"):
                    temp = tok
                    tok = self.next_token()
                    if(tok[3] == "CommaOp"):
                        tok = self.next_token()
                        if(self.check_print_semantic(temp, tok)):
                            tok = self.next_token()
                        else:
                            return False
                    if(tok[3] == "RoundRpar"):
                        tok = self.next_token()
                        if(self.check_semicolon(tok)):
                            return True

    def check_else(self, tok):
        print("Check else: ", tok)
        if(tok[1] == "else"):
            tok = self.next_token()
            if(self.check_flower_paranthesis(tok)):
                return True

    def check_print_semantic(self, temp, tok):
        print("Check printf semantic", tok)
        print("Declared vars: ",self.declared)
        temp = temp[1].split('"')[1]
        temp = temp.split("%")
        temp.pop(0)
        toks = []
        while(tok[3] in ["Identifier", "Number"]):
            toks.append(tok[1])
            tok = self.next_token()
            if(tok):
                if(tok[1] == ","):
                    tok = self.next_token()
                    continue
                elif(tok[1] == ")"):
                    break
            else:
                print("Semantic mismatch at: ",tok)
                return False
        tok = self.prev_token()
        if(len(toks) != len(temp)):
            print("Semantic mismatch at: ",tok)
            return False
        for i in range(len(temp)):
            if(temp[i] == "d"):
                if(self.declared.get(toks[i])!="int"):
                    if(not isinstance(toks[i],int)):
                        print("int mismatch at: ",tok)
                        return False 

            elif(temp[i] == "c"):
                if(self.declared.get(toks[i])!="char"):
                    print("char mismatch at: ",tok)
                    return False
            
            elif(temp[i] == "f"):
                if(self.declared.get(toks[i])!="float"):
                    if(not isinstance(tok,double)):
                        print("float mismatch at: ",tok)
                        return False
        return True

    def check_semicolon(self, tok):
        print("Check semicolon: ", tok)
        if(tok[3] == "Semicolon"):
            return True

if __name__ == "__main__":
    if(len(sys.argv) < 2):
        print("Error: No input file")
    else:
        sys.exit(parser(sys.argv[1]).start())
        '''x = parser(sys.argv[1])
        print(x.declared)
        x.clear_arrays()
        for i in x.tokens:
            print(i)'''
