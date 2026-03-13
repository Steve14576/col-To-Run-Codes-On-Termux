/* 中等编译时间C程序 - 安全版本，编译时间约1-2秒 */
#include <stdio.h>
#include <math.h>

/* 使用X-Macros生成代码 */
#define LIST_50 \
    X(0) X(1) X(2) X(3) X(4) X(5) X(6) X(7) X(8) X(9) \
    X(10) X(11) X(12) X(13) X(14) X(15) X(16) X(17) X(18) X(19) \
    X(20) X(21) X(22) X(23) X(24) X(25) X(26) X(27) X(28) X(29) \
    X(30) X(31) X(32) X(33) X(34) X(35) X(36) X(37) X(38) X(39) \
    X(40) X(41) X(42) X(43) X(44) X(45) X(46) X(47) X(48) X(49)

/* 结构体定义 */
#define X(n) \
    typedef struct { \
        double f1_##n; double f2_##n; double f3_##n; double f4_##n; \
        double f5_##n; double f6_##n; double f7_##n; double f8_##n; \
        struct S##n *next; \
    } S##n;
LIST_50
#undef X

#define X(n) \
    typedef struct { \
        int i1_##n; int i2_##n; int i3_##n; int i4_##n; \
        int i5_##n; int i6_##n; int i7_##n; int i8_##n; \
        struct T##n *next; \
    } T##n;
LIST_50
#undef X

/* 枚举定义 */
#define X(n) \
    enum E##n { \
        E##n##_0, E##n##_1, E##n##_2, E##n##_3, E##n##_4, \
        E##n##_5, E##n##_6, E##n##_7, E##n##_8, E##n##_9, \
        E##n##_10, E##n##_11, E##n##_12, E##n##_13, E##n##_14, \
        E##n##_15, E##n##_16, E##n##_17, E##n##_18, E##n##_19, \
        E##n##_20, E##n##_21, E##n##_22, E##n##_23, E##n##_24 \
    };
LIST_50
#undef X

/* 静态数组初始化 */
#define X(n) \
    static double arr_##n[100] = { \
        n+0.0, n+0.1, n+0.2, n+0.3, n+0.4, n+0.5, n+0.6, n+0.7, n+0.8, n+0.9, \
        n+1.0, n+1.1, n+1.2, n+1.3, n+1.4, n+1.5, n+1.6, n+1.7, n+1.8, n+1.9, \
        n+2.0, n+2.1, n+2.2, n+2.3, n+2.4, n+2.5, n+2.6, n+2.7, n+2.8, n+2.9, \
        n+3.0, n+3.1, n+3.2, n+3.3, n+3.4, n+3.5, n+3.6, n+3.7, n+3.8, n+3.9, \
        n+4.0, n+4.1, n+4.2, n+4.3, n+4.4, n+4.5, n+4.6, n+4.7, n+4.8, n+4.9, \
        n+5.0, n+5.1, n+5.2, n+5.3, n+5.4, n+5.5, n+5.6, n+5.7, n+5.8, n+5.9, \
        n+6.0, n+6.1, n+6.2, n+6.3, n+6.4, n+6.5, n+6.6, n+6.7, n+6.8, n+6.9, \
        n+7.0, n+7.1, n+7.2, n+7.3, n+7.4, n+7.5, n+7.6, n+7.7, n+7.8, n+7.9, \
        n+8.0, n+8.1, n+8.2, n+8.3, n+8.4, n+8.5, n+8.6, n+8.7, n+8.8, n+8.9, \
        n+9.0, n+9.1, n+9.2, n+9.3, n+9.4, n+9.5, n+9.6, n+9.7, n+9.8, n+9.9 \
    };
LIST_50
#undef X

/* 内联函数 */
#define X(n) \
    static inline double func_##n(double a, double b, double c) { \
        double r1 = a * b + c; \
        double r2 = r1 * a - b * c; \
        double r3 = r2 / (a + 0.001); \
        double r4 = r3 * r3 - b * b; \
        double r5 = r4 + c * c * a; \
        double r6 = r5 / (b + 0.001); \
        double r7 = r6 * a * b * c; \
        double r8 = r7 - a - b - c; \
        return r8; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func2_##n(double x) { \
        double s = 0.0; \
        for (int i = 0; i < 50; i++) { \
            s += x * i * 0.001; \
            s = s * 1.001 + i * 0.0001; \
            s = s / (1.0 + x * 0.0001); \
            s = s + sin(x * i * 0.01); \
        } \
        return s; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func3_##n(double x, double y) { \
        double r = 0.0; \
        for (int i = 0; i < 30; i++) { \
            for (int j = 0; j < 30; j++) { \
                r += x * i * j * 0.0001; \
                r = r * y * 0.999 + i * j * 0.00001; \
            } \
        } \
        return r; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func4_##n(double a, double b, double c, double d) { \
        double r = a + b + c + d; \
        r = r * a - b * c + d; \
        r = r / (a + b + 0.001); \
        r = r * (c + d + 0.001); \
        r = r - a * b * c * d; \
        r = r + sin(a) * cos(b) * tan(c + 0.001); \
        return r; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func5_##n(double x) { \
        double result = x; \
        for (int i = 0; i < 50; i++) { \
            result = result * 0.999 + i * 0.0001; \
            result = result / (1.0 + x * 0.00001); \
            result = result + log(1.0 + fabs(x) * i * 0.001); \
        } \
        return result; \
    }
LIST_50
#undef X

/* 函数指针类型 */
#define X(n) \
    typedef double (*fp_##n)(double, double); \
    typedef double (*fp2_##n)(double, double, double); \
    typedef double (*fp3_##n)(double);
LIST_50
#undef X

/* 复杂结构体初始化 */
#define X(n) \
    static struct Complex##n { \
        double d1; double d2; double d3; double d4; \
        int i1; int i2; int i3; int i4; \
        char s[50]; \
    } complex_##n = { \
        n * 1.0, n * 2.0, n * 3.0, n * 4.0, \
        n, n * 2, n * 3, n * 4, \
        "complex initialization" \
    };
LIST_50
#undef X

/* 整数数组 */
#define X(n) \
    static int int_arr_##n[50] = { \
        n, n+1, n+2, n+3, n+4, n+5, n+6, n+7, n+8, n+9, \
        n+10, n+11, n+12, n+13, n+14, n+15, n+16, n+17, n+18, n+19, \
        n+20, n+21, n+22, n+23, n+24, n+25, n+26, n+27, n+28, n+29, \
        n+30, n+31, n+32, n+33, n+34, n+35, n+36, n+37, n+38, n+39, \
        n+40, n+41, n+42, n+43, n+44, n+45, n+46, n+47, n+48, n+49 \
    };
LIST_50
#undef X

/* 字符串数组 */
#define X(n) \
    static const char *str_arr_##n[] = { \
        "s0_##n", "s1_##n", "s2_##n", "s3_##n", "s4_##n", \
        "s5_##n", "s6_##n", "s7_##n", "s8_##n", "s9_##n", \
        "s10_##n", "s11_##n", "s12_##n", "s13_##n", "s14_##n", \
        "s15_##n", "s16_##n", "s17_##n", "s18_##n", "s19_##n" \
    };
LIST_50
#undef X

/* 更多函数 */
#define X(n) \
    static inline double func6_##n(double x, double y, double z) { \
        double r = 0.0; \
        for (int i = 0; i < 20; i++) { \
            for (int j = 0; j < 20; j++) { \
                for (int k = 0; k < 20; k++) { \
                    r += x * i + y * j + z * k; \
                    r = r * 0.999; \
                } \
            } \
        } \
        return r; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func7_##n(double x) { \
        double s = x; \
        for (int i = 0; i < 40; i++) { \
            s = s * 0.998 + sqrt(fabs(x) + i * 0.01); \
            s = s / (1.0 + x * x * 0.0001); \
        } \
        return s; \
    }
LIST_50
#undef X

#define X(n) \
    static inline double func8_##n(double a, double b) { \
        double r = 0.0; \
        for (int i = 0; i < 25; i++) { \
            for (int j = 0; j < 25; j++) { \
                r += pow(a, 0.5) * i + pow(b, 0.5) * j; \
                r = r * 0.9999; \
            } \
        } \
        return r; \
    }
LIST_50
#undef X

/* 节点结构体 */
#define X(n) \
    typedef struct Node##n { \
        int value; \
        struct Node##n *left; \
        struct Node##n *right; \
        struct Node##n *parent; \
    } Node##n; \
    typedef struct Tree##n { \
        Node##n *root; \
        int size; \
        int height; \
    } Tree##n;
LIST_50
#undef X

/* 数据初始化 */
#define X(n) \
    static struct Data##n { \
        double values[10]; \
        int indices[10]; \
        char name[64]; \
    } data_##n = { \
        {n*0.1, n*0.2, n*0.3, n*0.4, n*0.5, n*0.6, n*0.7, n*0.8, n*0.9, n*1.0}, \
        {n, n+1, n+2, n+3, n+4, n+5, n+6, n+7, n+8, n+9}, \
        "data_##n" \
    };
LIST_50
#undef X

/* 浮点数组 */
#define X(n) \
    static float float_arr_##n[80] = { \
        n*0.1f, n*0.2f, n*0.3f, n*0.4f, n*0.5f, n*0.6f, n*0.7f, n*0.8f, n*0.9f, n*1.0f, \
        n*1.1f, n*1.2f, n*1.3f, n*1.4f, n*1.5f, n*1.6f, n*1.7f, n*1.8f, n*1.9f, n*2.0f, \
        n*2.1f, n*2.2f, n*2.3f, n*2.4f, n*2.5f, n*2.6f, n*2.7f, n*2.8f, n*2.9f, n*3.0f, \
        n*3.1f, n*3.2f, n*3.3f, n*3.4f, n*3.5f, n*3.6f, n*3.7f, n*3.8f, n*3.9f, n*4.0f, \
        n*4.1f, n*4.2f, n*4.3f, n*4.4f, n*4.5f, n*4.6f, n*4.7f, n*4.8f, n*4.9f, n*5.0f, \
        n*5.1f, n*5.2f, n*5.3f, n*5.4f, n*5.5f, n*5.6f, n*5.7f, n*5.8f, n*5.9f, n*6.0f, \
        n*6.1f, n*6.2f, n*6.3f, n*6.4f, n*6.5f, n*6.6f, n*6.7f, n*6.8f, n*6.9f, n*7.0f, \
        n*7.1f, n*7.2f, n*7.3f, n*7.4f, n*7.5f, n*7.6f, n*7.7f, n*7.8f, n*7.9f, n*8.0f \
    };
LIST_50
#undef X

/* 主函数 */
int main(void) {
    double result = 0.0;
    
    result += func_0(1.0, 2.0, 3.0);
    result += func2_0(1.0);
    result += func3_0(1.0, 2.0);
    result += func4_0(1.0, 2.0, 3.0, 4.0);
    result += func5_0(1.0);
    result += func6_0(1.0, 2.0, 3.0);
    result += func7_0(1.0);
    result += func8_0(1.0, 2.0);
    
    printf("编译完成!\\n");
    printf("Result: %f\\n", result);
    printf("中等大小测试程序 - 编译时间约1-2秒\\n");
    
    return 0;
}
