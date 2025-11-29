C-Mini Compiler (Lexer & Parser)

Bu proje, C programlama dilinin bir alt kümesi için geliştirilmiş Lexer (Sözcük Analizcisi) ve Parser (Sözdizim Analizcisi) uygulamasıdır. Proje iki aşamadan oluşmaktadır:

    Lexer: Kaynak kodunu okuyarak token'larına ayırır.

    Parser: Tokenları alarak gramer kontrolü yapar ve Soyut Sözdizimi Ağacı (AST) oluşturur.

📋 Özellikler

    Lexer (Flex): Anahtar kelimeleri (int, if, while vb.), operatörleri, sayıları ve tanımlayıcıları tanır.

    Parser (Bison): Gramer kurallarına göre sözdizimi denetimi yapar.

    AST: Kodun hiyerarşik yapısını (Değişken tanımları, Fonksiyon blokları, If-Else yapıları) görselleştirir.

🛠 Gereksinimler

Projeyi derlemek ve çalıştırmak için sisteminizde aşağıdaki araçların kurulu olması gerekir:

    GCC (GNU Compiler Collection)

    Flex

    Bison

🚀 Kurulum ve Çalıştırma

Projeyi derlemek ve test.c dosyasını analiz etmek için terminalde aşağıdaki komutları sırasıyla çalıştırın:
Bash

# Parser ve Lexer kodlarını oluştur
bison -d parser.y
flex clexer.l

# Derleyiciyi oluştur (Compile)
gcc parser.tab.c lex.yy.c -o mycompiler

# Test dosyasını çalıştır
./mycompiler test.c

📊 Proje Çıktıları

🔹 Aşama 1: Lexer (Token Ayrıştırma)

Lexer aşamasında kaynak kod anlamsız karakter dizilerinden, anlamlı Token parçalarına dönüştürülür. (Not: Bu çıktı Proje 1 aşamasındaki standalone lexer modundan alınmıştır.)

Girdi: int x = 10;

Çıktı:
Plaintext

TOKEN: KEYWORD (int)
TOKEN: IDENTIFIER (x)
TOKEN: OPERATOR (=)
TOKEN: NUMBER (10)
TOKEN: SYMBOL (;)

🔹 Aşama 2: Parser & AST (Sözdizimi Ağacı)

Parser aşamasında tokenlar birleştirilerek kodun yapısal ağacı (AST) oluşturulur. test.c dosyası için üretilen ağaç yapısı aşağıdadır:

Test Kodu (test.c):
C

int main() {
    int x = 10;
    float y = 2.5;
    if (x > y) {
        printf("X daha büyük\n");
    }
    return 0;
}

AST Çıktısı:
Plaintext

Function Def: main
  VarDecl: int
    ID: x
    Const: 10
  VarDecl: float
    ID: y
    Const: 2.5
  If Statement
    Op: >
      ID: x
      ID: y
    Function Call: printf
      String: "X daha büyük\n"
  Op: return

📂 Dosya Yapısı

    clexer.l: Flex için lexer kuralları (Token tanımları).

    parser.y: Bison için gramer kuralları ve AST oluşturma mantığı.

    ast.h: AST düğüm yapıları (struct) ve yardımcı fonksiyonlar.

    test.c: Test için kullanılan örnek C kodu.
