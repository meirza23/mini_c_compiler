/* codegen.c - TEST 4 FIX (FINAL VERSION) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

struct Symbol {
    char name[32];
    char type[10];
};

struct Symbol symbolTable[100];
int symCount = 0;

int lookup(char* name) {
    for(int i=0; i<symCount; i++) {
        if(strcmp(symbolTable[i].name, name) == 0) return i;
    }
    return -1;
}

void addSymbol(char* name, char* type) {
    if(lookup(name) != -1) {
        fprintf(stderr, "Semantic Error: Redeclaration of variable '%s'\n", name);
        exit(1);
    }
    strcpy(symbolTable[symCount].name, name);
    strcpy(symbolTable[symCount].type, type);
    symCount++;
}

int tempCount = 0;
int labelCount = 0;
int newTemp() { return tempCount++; }
int newLabel() { return labelCount++; }

/* Expression Generator */
int genExpr(ASTNode* node) {
    if (!node) return -1;

    // String bir ifade ise aritmetik isleme sokma, ozel kod (-2) dondur
    if (node->type == NODE_STRING) {
        return -2; 
    }

    if (node->type == NODE_CONST || node->type == NODE_BOOL) {
        int t = newTemp();
        int val = (node->type == NODE_BOOL) ? (strcmp(node->val, "true")==0 ? 1 : 0) : atoi(node->val);
        printf("  %%t%d = add i32 0, %d\n", t, val);
        return t;
    }
    
    if (node->type == NODE_ID) {
        if(lookup(node->val) == -1) {
            fprintf(stderr, "Semantic Error: Undeclared variable '%s'\n", node->val);
            exit(1);
        }
        int t = newTemp();
        printf("  %%t%d = load i32, i32* %%%s\n", t, node->val);
        return t;
    }

    if (node->type == NODE_MATH) {
        int leftReg = genExpr(node->left);
        int rightReg = genExpr(node->right);

        // String kontrolu
        if (leftReg == -2 || rightReg == -2) {
             fprintf(stderr, "Semantic Error: Type mismatch (Cannot use String in math)\n");
             exit(1);
        }

        int resReg = newTemp();
        char* op = "add";
        if(strcmp(node->val, "-") == 0) op = "sub";
        if(strcmp(node->val, "*") == 0) op = "mul";
        if(strcmp(node->val, "/") == 0) op = "sdiv";

        printf("  %%t%d = %s i32 %%t%d, %%t%d\n", resReg, op, leftReg, rightReg);
        return resReg;
    }

    if (node->type == NODE_OP) {
        int leftReg = genExpr(node->left);
        int rightReg = genExpr(node->right);
        
        if (leftReg == -2 || rightReg == -2) {
             fprintf(stderr, "Semantic Error: Type mismatch (Cannot compare String)\n");
             exit(1);
        }

        int resReg = newTemp(); 
        int extReg = newTemp(); 

        char* pred = "eq";
        if(strcmp(node->val, "<") == 0) pred = "slt";
        if(strcmp(node->val, ">") == 0) pred = "sgt";
        if(strcmp(node->val, "==") == 0) pred = "eq";
        if(strcmp(node->val, "!=") == 0) pred = "ne";

        printf("  %%t%d = icmp %s i32 %%t%d, %%t%d\n", resReg, pred, leftReg, rightReg);
        printf("  %%t%d = zext i1 %%t%d to i32\n", extReg, resReg);
        return extReg;
    }
    
    return -1;
}

void generateCode(ASTNode* node) {
    if (!node) return;

    switch (node->type) {
        case NODE_PROGRAM:
            printf("; ModuleID = 'test'\n");
            printf("declare i32 @printf(i8*, ...)\n");
            printf("define i32 @main() {\nentry:\n");
            generateCode(node->left); 
            printf("  ret i32 0\n}\n");
            break;

        case NODE_FUNC_DEF:
            generateCode(node->left);
            generateCode(node->right);
            break;

        case NODE_VAR_DECL:
            addSymbol(node->left->val, node->val);
            printf("  %%%s = alloca i32\n", node->left->val);
            
            // Expression sonucunu hesapla
            int resReg = genExpr(node->right);
            
            // --- DUZELTME BURADA ---
            // Eger donen deger -2 ise (String), ve degisken tipi int/float/bool ise HATA VER
            if (resReg == -2) {
                 fprintf(stderr, "Semantic Error: Type mismatch (Cannot assign String to %s)\n", node->val);
                 exit(1);
            }
            // -----------------------

            if (resReg != -1)
                printf("  store i32 %%t%d, i32* %%%s\n", resReg, node->left->val);
            break;

        case NODE_ASSIGN:
            if(lookup(node->left->val) == -1) {
                fprintf(stderr, "Semantic Error: Undeclared variable '%s'\n", node->left->val);
                exit(1);
            }
            int assignVal = genExpr(node->right);
            
            // Atamada da String kontrolu yapalim
            if (assignVal == -2) {
                 fprintf(stderr, "Semantic Error: Type mismatch (Cannot assign String to variable)\n");
                 exit(1);
            }

            printf("  store i32 %%t%d, i32* %%%s\n", assignVal, node->left->val);
            break;

        case NODE_IF:
            {
                int condReg = genExpr(node->left); 
                // Condition string olamaz
                if (condReg == -2) {
                     fprintf(stderr, "Semantic Error: Condition cannot be a String\n");
                     exit(1);
                }

                int lblTrue = newLabel();
                int lblElse = newLabel();
                int lblMerge = newLabel();
                int cmpReg = newTemp();

                printf("  %%t%d = icmp ne i32 %%t%d, 0\n", cmpReg, condReg);
                printf("  br i1 %%t%d, label %%L%d, label %%L%d\n", cmpReg, lblTrue, lblElse);

                printf("\nL%d:\n", lblTrue);
                generateCode(node->right);
                printf("  br label %%L%d\n", lblMerge);

                printf("\nL%d:\n", lblElse);
                if (node->elseNode) generateCode(node->elseNode);
                printf("  br label %%L%d\n", lblMerge);

                printf("\nL%d:\n", lblMerge);
                break;
            }

        case NODE_RETURN:
            {
                int retVal = genExpr(node->left);
                if (retVal == -2) {
                     fprintf(stderr, "Semantic Error: Cannot return a String\n");
                     exit(1);
                }
                printf("  ret i32 %%t%d\n", retVal);
            }
            break;

        default: break;
    }

    if (node->next) generateCode(node->next);
}