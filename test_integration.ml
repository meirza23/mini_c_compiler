int main() {
    int a = 10;
    int b = 20;
    int result = 0;

    // Eger a, b'den kucukse (10 < 20 -> True)
    if (a < b) {
        result = a + b; // 30 olmali
    } else {
        result = a - b;
    }
    
    return result;
}