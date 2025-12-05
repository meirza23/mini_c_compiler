/* ast.h */
#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    NODE_PROGRAM,
    NODE_FUNC_DEF,
    NODE_VAR_DECL,
    NODE_ASSIGN,
    NODE_IF,
    NODE_CONST,
    NODE_ID,
    NODE_FUNC_CALL,
    NODE_STRING,
    NODE_RETURN,
    NODE_MATH,
    NODE_BOOL,
    NODE_OP
} NodeType;

typedef struct ASTNode {
    NodeType type;
    char* val;
    struct ASTNode* left;
    struct ASTNode* right;
    struct ASTNode* elseNode; // YENI: Else blogu icin ozel alan
    struct ASTNode* next;     // Sonraki komut zinciri
} ASTNode;

static ASTNode* createNode(NodeType type, char* val, ASTNode* left, ASTNode* right) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory error\n");
        exit(1);
    }
    node->type = type;
    if (val) node->val = strdup(val); else node->val = NULL;
    node->left = left;
    node->right = right;
    node->elseNode = NULL; // Baslangicta bos
    node->next = NULL;
    return node;
}
#endif