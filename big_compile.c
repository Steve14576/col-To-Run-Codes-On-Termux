/* 大编译时间C程序 - 编译时间约5-10秒 */
#include <stdio.h>
#include <math.h>

#define LIST_200 \
    X(0) X(1) X(2) X(3) X(4) X(5) X(6) X(7) X(8) X(9) \
    X(10) X(11) X(12) X(13) X(14) X(15) X(16) X(17) X(18) X(19) \
    X(20) X(21) X(22) X(23) X(24) X(25) X(26) X(27) X(28) X(29) \
    X(30) X(31) X(32) X(33) X(34) X(35) X(36) X(37) X(38) X(39) \
    X(40) X(41) X(42) X(43) X(44) X(45) X(46) X(47) X(48) X(49) \
    X(50) X(51) X(52) X(53) X(54) X(55) X(56) X(57) X(58) X(59) \
    X(60) X(61) X(62) X(63) X(64) X(65) X(66) X(67) X(68) X(69) \
    X(70) X(71) X(72) X(73) X(74) X(75) X(76) X(77) X(78) X(79) \
    X(80) X(81) X(82) X(83) X(84) X(85) X(86) X(87) X(88) X(89) \
    X(90) X(91) X(92) X(93) X(94) X(95) X(96) X(97) X(98) X(99) \
    X(100) X(101) X(102) X(103) X(104) X(105) X(106) X(107) X(108) X(109) \
    X(110) X(111) X(112) X(113) X(114) X(115) X(116) X(117) X(118) X(119) \
    X(120) X(121) X(122) X(123) X(124) X(125) X(126) X(127) X(128) X(129) \
    X(130) X(131) X(132) X(133) X(134) X(135) X(136) X(137) X(138) X(139) \
    X(140) X(141) X(142) X(143) X(144) X(145) X(146) X(147) X(148) X(149) \
    X(150) X(151) X(152) X(153) X(154) X(155) X(156) X(157) X(158) X(159) \
    X(160) X(161) X(162) X(163) X(164) X(165) X(166) X(167) X(168) X(169) \
    X(170) X(171) X(172) X(173) X(174) X(175) X(176) X(177) X(178) X(179) \
    X(180) X(181) X(182) X(183) X(184) X(185) X(186) X(187) X(188) X(189) \
    X(190) X(191) X(192) X(193) X(194) X(195) X(196) X(197) X(198) X(199)

/* 批次1: 结构体S */
#define X(n) \
    typedef struct { \
        double f1_##n; double f2_##n; double f3_##n; double f4_##n; \
        double f5_##n; double f6_##n; double f7_##n; double f8_##n; \
        double f9_##n; double f10_##n; double f11_##n; double f12_##n; \
        double f13_##n; double f14_##n; double f15_##n; double f16_##n; \
        struct S##n *next; \
    } S##n;
LIST_200
#undef X

/* 批次2: 结构体T */
#define X(n) \
    typedef struct { \
        int i1_##n; int i2_##n; int i3_##n; int i4_##n; \
        int i5_##n; int i6_##n; int i7_##n; int i8_##n; \
        int i9_##n; int i10_##n; int i11_##n; int i12_##n; \
        int i13_##n; int i14_##n; int i15_##n; int i16_##n; \
        int i17_##n; int i18_##n; int i19_##n; int i20_##n; \
        struct T##n *next; \
    } T##n;
LIST_200
#undef X

/* 批次3: 结构体U */
#define X(n) \
    typedef struct { \
        float a1_##n; float a2_##n; float a3_##n; float a4_##n; \
        float a5_##n; float a6_##n; float a7_##n; float a8_##n; \
        float a9_##n; float a10_##n; float a11_##n; float a12_##n; \
        float a13_##n; float a14_##n; float a15_##n; float a16_##n; \
        float a17_##n; float a18_##n; float a19_##n; float a20_##n; \
        float a21_##n; float a22_##n; float a23_##n; float a24_##n; \
        struct U##n *next; \
    } U##n;
LIST_200
#undef X

/* 批次4: 结构体V */
#define X(n) \
    typedef struct { \
        long l1_##n; long l2_##n; long l3_##n; long l4_##n; \
        long l5_##n; long l6_##n; long l7_##n; long l8_##n; \
        long l9_##n; long l10_##n; long l11_##n; long l12_##n; \
        long l13_##n; long l14_##n; long l15_##n; long l16_##n; \
        long l17_##n; long l18_##n; long l19_##n; long l20_##n; \
        long l21_##n; long l22_##n; long l23_##n; long l24_##n; \
        long l25_##n; long l26_##n; long l27_##n; long l28_##n; \
        struct V##n *next; \
    } V##n;
LIST_200
#undef X

/* 批次5: 枚举E */
#define X(n) \
    enum E##n { \
        E##n##_0, E##n##_1, E##n##_2, E##n##_3, E##n##_4, \
        E##n##_5, E##n##_6, E##n##_7, E##n##_8, E##n##_9, \
        E##n##_10, E##n##_11, E##n##_12, E##n##_13, E##n##_14, \
        E##n##_15, E##n##_16, E##n##_17, E##n##_18, E##n##_19, \
        E##n##_20, E##n##_21, E##n##_22, E##n##_23, E##n##_24, \
        E##n##_25, E##n##_26, E##n##_27, E##n##_28, E##n##_29, \
        E##n##_30, E##n##_31, E##n##_32, E##n##_33, E##n##_34, \
        E##n##_35, E##n##_36, E##n##_37, E##n##_38, E##n##_39, \
        E##n##_40, E##n##_41, E##n##_42, E##n##_43, E##n##_44, \
        E##n##_45, E##n##_46, E##n##_47, E##n##_48, E##n##_49 \
    };
LIST_200
#undef X

/* 批次6: 枚举F */
#define X(n) \
    enum F##n { \
        F##n##_0, F##n##_1, F##n##_2, F##n##_3, F##n##_4, \
        F##n##_5, F##n##_6, F##n##_7, F##n##_8, F##n##_9, \
        F##n##_10, F##n##_11, F##n##_12, F##n##_13, F##n##_14, \
        F##n##_15, F##n##_16, F##n##_17, F##n##_18, F##n##_19, \
        F##n##_20, F##n##_21, F##n##_22, F##n##_23, F##n##_24 \
    };
LIST_200
#undef X

/* 批次7: 双精度数组 */
#define X(n) \
    static double arr_##n[200] = { \
        n+0.0, n+0.1, n+0.2, n+0.3, n+0.4, n+0.5, n+0.6, n+0.7, n+0.8, n+0.9, \
        n+1.0, n+1.1, n+1.2, n+1.3, n+1.4, n+1.5, n+1.6, n+1.7, n+1.8, n+1.9, \
        n+2.0, n+2.1, n+2.2, n+2.3, n+2.4, n+2.5, n+2.6, n+2.7, n+2.8, n+2.9, \
        n+3.0, n+3.1, n+3.2, n+3.3, n+3.4, n+3.5, n+3.6, n+3.7, n+3.8, n+3.9, \
        n+4.0, n+4.1, n+4.2, n+4.3, n+4.4, n+4.5, n+4.6, n+4.7, n+4.8, n+4.9, \
        n+5.0, n+5.1, n+5.2, n+5.3, n+5.4, n+5.5, n+5.6, n+5.7, n+5.8, n+5.9, \
        n+6.0, n+6.1, n+6.2, n+6.3, n+6.4, n+6.5, n+6.6, n+6.7, n+6.8, n+6.9, \
        n+7.0, n+7.1, n+7.2, n+7.3, n+7.4, n+7.5, n+7.6, n+7.7, n+7.8, n+7.9, \
        n+8.0, n+8.1, n+8.2, n+8.3, n+8.4, n+8.5, n+8.6, n+8.7, n+8.8, n+8.9, \
        n+9.0, n+9.1, n+9.2, n+9.3, n+9.4, n+9.5, n+9.6, n+9.7, n+9.8, n+9.9, \
        n+10.0, n+10.1, n+10.2, n+10.3, n+10.4, n+10.5, n+10.6, n+10.7, n+10.8, n+10.9, \
        n+11.0, n+11.1, n+11.2, n+11.3, n+11.4, n+11.5, n+11.6, n+11.7, n+11.8, n+11.9, \
        n+12.0, n+12.1, n+12.2, n+12.3, n+12.4, n+12.5, n+12.6, n+12.7, n+12.8, n+12.9, \
        n+13.0, n+13.1, n+13.2, n+13.3, n+13.4, n+13.5, n+13.6, n+13.7, n+13.8, n+13.9, \
        n+14.0, n+14.1, n+14.2, n+14.3, n+14.4, n+14.5, n+14.6, n+14.7, n+14.8, n+14.9, \
        n+15.0, n+15.1, n+15.2, n+15.3, n+15.4, n+15.5, n+15.6, n+15.7, n+15.8, n+15.9, \
        n+16.0, n+16.1, n+16.2, n+16.3, n+16.4, n+16.5, n+16.6, n+16.7, n+16.8, n+16.9, \
        n+17.0, n+17.1, n+17.2, n+17.3, n+17.4, n+17.5, n+17.6, n+17.7, n+17.8, n+17.9, \
        n+18.0, n+18.1, n+18.2, n+18.3, n+18.4, n+18.5, n+18.6, n+18.7, n+18.8, n+18.9, \
        n+19.0, n+19.1, n+19.2, n+19.3, n+19.4, n+19.5, n+19.6, n+19.7, n+19.8, n+19.9 \
    };
LIST_200
#undef X

/* 批次8: 函数1 */
#define X(n) \
    static inline double func1_##n(double a, double b, double c) { \
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
LIST_200
#undef X

/* 批次9: 函数2 */
#define X(n) \
    static inline double func2_##n(double x) { \
        double s = 0.0; \
        for (int i = 0; i < 100; i++) { \
            s += x * i * 0.001; \
            s = s * 1.001 + i * 0.0001; \
            s = s / (1.0 + x * 0.0001); \
            s = s + sin(x * i * 0.01); \
            s = s * cos(x * i * 0.01); \
        } \
        return s; \
    }
LIST_200
#undef X

/* 批次10: 函数3 */
#define X(n) \
    static inline double func3_##n(double x, double y) { \
        double r = 0.0; \
        for (int i = 0; i < 50; i++) { \
            for (int j = 0; j < 50; j++) { \
                r += x * i * j * 0.0001; \
                r = r * y * 0.999 + i * j * 0.00001; \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次11: 函数4 */
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
LIST_200
#undef X

/* 批次12: 函数5 */
#define X(n) \
    static inline double func5_##n(double x) { \
        double result = x; \
        for (int i = 0; i < 80; i++) { \
            result = result * 0.999 + i * 0.0001; \
            result = result / (1.0 + x * 0.00001); \
            result = result + log(1.0 + fabs(x) * i * 0.001); \
        } \
        return result; \
    }
LIST_200
#undef X

/* 批次13: 函数6 */
#define X(n) \
    static inline double func6_##n(double x, double y, double z) { \
        double r = 0.0; \
        for (int i = 0; i < 40; i++) { \
            for (int j = 0; j < 40; j++) { \
                for (int k = 0; k < 40; k++) { \
                    r += x * i + y * j + z * k; \
                    r = r * 0.999; \
                } \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次14: 函数7 */
#define X(n) \
    static inline double func7_##n(double x) { \
        double s = x; \
        for (int i = 0; i < 60; i++) { \
            s = s * 0.998 + sqrt(fabs(x) + i * 0.01); \
            s = s / (1.0 + x * x * 0.0001); \
        } \
        return s; \
    }
LIST_200
#undef X

/* 批次15: 函数8 */
#define X(n) \
    static inline double func8_##n(double a, double b) { \
        double r = 0.0; \
        for (int i = 0; i < 40; i++) { \
            for (int j = 0; j < 40; j++) { \
                r += pow(a, 0.5) * i + pow(b, 0.5) * j; \
                r = r * 0.9999; \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次16: 函数9 */
#define X(n) \
    static inline double func9_##n(double x, double y, double z, double w) { \
        double r = x + y + z + w; \
        for (int i = 0; i < 30; i++) { \
            for (int j = 0; j < 30; j++) { \
                r += x * y * i * j * 0.00001; \
                r = r + z * w * i * j * 0.00001; \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次17: 函数10 */
#define X(n) \
    static inline double func10_##n(double x) { \
        double r = x; \
        for (int i = 0; i < 70; i++) { \
            r = r * exp(x * 0.001 * i); \
            r = r / (1.0 + log(1.0 + fabs(x) * i * 0.01)); \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次18: 函数11 */
#define X(n) \
    static inline double func11_##n(double a, double b, double c) { \
        double r = a * b * c; \
        for (int i = 0; i < 45; i++) { \
            for (int j = 0; j < 45; j++) { \
                r += a * i + b * j + c; \
                r = r * 0.999; \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次19: 函数12 */
#define X(n) \
    static inline double func12_##n(double x) { \
        double s = 0.0; \
        for (int i = 0; i < 55; i++) { \
            s += sin(x * i * 0.1) * cos(x * i * 0.1); \
            s = s * tan(x * i * 0.01 + 0.1); \
        } \
        return s; \
    }
LIST_200
#undef X

/* 批次20: 函数13 */
#define X(n) \
    static inline double func13_##n(double x, double y) { \
        double r = 0.0; \
        for (int i = 0; i < 35; i++) { \
            for (int j = 0; j < 35; j++) { \
                r += x * i * j * 0.0001 + y * i * j * 0.0001; \
                r = r * 0.9999 + i * j * 0.00001; \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次21: 函数14 */
#define X(n) \
    static inline double func14_##n(double a, double b, double c, double d) { \
        double r = a + b + c + d; \
        for (int i = 0; i < 25; i++) { \
            for (int j = 0; j < 25; j++) { \
                for (int k = 0; k < 25; k++) { \
                    r += a * i + b * j + c * k + d; \
                    r = r * 0.999; \
                } \
            } \
        } \
        return r; \
    }
LIST_200
#undef X

/* 批次22: 函数指针类型 */
#define X(n) \
    typedef double (*fp1_##n)(double, double); \
    typedef double (*fp2_##n)(double, double, double); \
    typedef double (*fp3_##n)(double); \
    typedef double (*fp4_##n)(double, double, double, double);
LIST_200
#undef X

/* 批次23: 点结构体 */
#define X(n) \
    typedef struct Point##n { \
        double x; double y; double z; double w; \
        struct Point##n *next; \
    } Point##n;
LIST_200
#undef X

/* 批次24: 矩阵结构体 */
#define X(n) \
    typedef struct Matrix##n { \
        double m[4][4]; \
        struct Matrix##n *next; \
    } Matrix##n;
LIST_200
#undef X

/* 批次25: 节点和树 */
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
LIST_200
#undef X

/* 批次26: 复杂结构体初始化 */
#define X(n) \
    static struct Complex##n { \
        double d1; double d2; double d3; double d4; \
        double d5; double d6; double d7; double d8; \
        int i1; int i2; int i3; int i4; \
        char s[64]; \
    } complex_##n = { \
        n * 1.0, n * 2.0, n * 3.0, n * 4.0, \
        n * 5.0, n * 6.0, n * 7.0, n * 8.0, \
        n, n * 2, n * 3, n * 4, \
        "complex_structure_##n" \
    };
LIST_200
#undef X

/* 批次27: 整数数组 */
#define X(n) \
    static int int_arr_##n[100] = { \
        n, n+1, n+2, n+3, n+4, n+5, n+6, n+7, n+8, n+9, \
        n+10, n+11, n+12, n+13, n+14, n+15, n+16, n+17, n+18, n+19, \
        n+20, n+21, n+22, n+23, n+24, n+25, n+26, n+27, n+28, n+29, \
        n+30, n+31, n+32, n+33, n+34, n+35, n+36, n+37, n+38, n+39, \
        n+40, n+41, n+42, n+43, n+44, n+45, n+46, n+47, n+48, n+49, \
        n+50, n+51, n+52, n+53, n+54, n+55, n+56, n+57, n+58, n+59, \
        n+60, n+61, n+62, n+63, n+64, n+65, n+66, n+67, n+68, n+69, \
        n+70, n+71, n+72, n+73, n+74, n+75, n+76, n+77, n+78, n+79, \
        n+80, n+81, n+82, n+83, n+84, n+85, n+86, n+87, n+88, n+89, \
        n+90, n+91, n+92, n+93, n+94, n+95, n+96, n+97, n+98, n+99 \
    };
LIST_200
#undef X

/* 批次28: 字符串数组 */
#define X(n) \
    static const char *str_arr_##n[] = { \
        "s0_##n", "s1_##n", "s2_##n", "s3_##n", "s4_##n", \
        "s5_##n", "s6_##n", "s7_##n", "s8_##n", "s9_##n", \
        "s10_##n", "s11_##n", "s12_##n", "s13_##n", "s14_##n", \
        "s15_##n", "s16_##n", "s17_##n", "s18_##n", "s19_##n", \
        "s20_##n", "s21_##n", "s22_##n", "s23_##n", "s24_##n" \
    };
LIST_200
#undef X

/* 批次29: 数据初始化 */
#define X(n) \
    static struct Data##n { \
        double values[20]; \
        int indices[20]; \
        char name[64]; \
    } data_##n = { \
        {n*0.1, n*0.2, n*0.3, n*0.4, n*0.5, n*0.6, n*0.7, n*0.8, n*0.9, n*1.0, \
         n*1.1, n*1.2, n*1.3, n*1.4, n*1.5, n*1.6, n*1.7, n*1.8, n*1.9, n*2.0}, \
        {n, n+1, n+2, n+3, n+4, n+5, n+6, n+7, n+8, n+9, \
         n+10, n+11, n+12, n+13, n+14, n+15, n+16, n+17, n+18, n+19}, \
        "data_structure_##n" \
    };
LIST_200
#undef X

/* 批次30: 浮点数组 */
#define X(n) \
    static float float_arr_##n[120] = { \
        n*0.1f, n*0.2f, n*0.3f, n*0.4f, n*0.5f, n*0.6f, n*0.7f, n*0.8f, n*0.9f, n*1.0f, \
        n*1.1f, n*1.2f, n*1.3f, n*1.4f, n*1.5f, n*1.6f, n*1.7f, n*1.8f, n*1.9f, n*2.0f, \
        n*2.1f, n*2.2f, n*2.3f, n*2.4f, n*2.5f, n*2.6f, n*2.7f, n*2.8f, n*2.9f, n*3.0f, \
        n*3.1f, n*3.2f, n*3.3f, n*3.4f, n*3.5f, n*3.6f, n*3.7f, n*3.8f, n*3.9f, n*4.0f, \
        n*4.1f, n*4.2f, n*4.3f, n*4.4f, n*4.5f, n*4.6f, n*4.7f, n*4.8f, n*4.9f, n*5.0f, \
        n*5.1f, n*5.2f, n*5.3f, n*5.4f, n*5.5f, n*5.6f, n*5.7f, n*5.8f, n*5.9f, n*6.0f, \
        n*6.1f, n*6.2f, n*6.3f, n*6.4f, n*6.5f, n*6.6f, n*6.7f, n*6.8f, n*6.9f, n*7.0f, \
        n*7.1f, n*7.2f, n*7.3f, n*7.4f, n*7.5f, n*7.6f, n*7.7f, n*7.8f, n*7.9f, n*8.0f, \
        n*8.1f, n*8.2f, n*8.3f, n*8.4f, n*8.5f, n*8.6f, n*8.7f, n*8.8f, n*8.9f, n*9.0f, \
        n*9.1f, n*9.2f, n*9.3f, n*9.4f, n*9.5f, n*9.6f, n*9.7f, n*9.8f, n*9.9f, n*10.0f, \
        n*10.1f, n*10.2f, n*10.3f, n*10.4f, n*10.5f, n*10.6f, n*10.7f, n*10.8f, n*10.9f, n*11.0f, \
        n*11.1f, n*11.2f, n*11.3f, n*11.4f, n*11.5f, n*11.6f, n*11.7f, n*11.8f, n*11.9f, n*12.0f \
    };
LIST_200
#undef X

/* 主函数 */
int main(void) {
    double result = 0.0;
    
    result += func1_0(1.0, 2.0, 3.0);
    result += func2_0(1.0);
    result += func3_0(1.0, 2.0);
    result += func4_0(1.0, 2.0, 3.0, 4.0);
    result += func5_0(1.0);
    result += func6_0(1.0, 2.0, 3.0);
    result += func7_0(1.0);
    result += func8_0(1.0, 2.0);
    result += func9_0(1.0, 2.0, 3.0, 4.0);
    result += func10_0(1.0);
    result += func11_0(1.0, 2.0, 3.0);
    result += func12_0(1.0);
    result += func13_0(1.0, 2.0);
    result += func14_0(1.0, 2.0, 3.0, 4.0);
    
    printf("编译完成!\\n");
    printf("Result: %f\\n", result);
    printf("大编译时间测试程序 - 编译时间约5-10秒\\n");
    printf("包含200组结构体、枚举、数组、内联函数\\n");
    
    return 0;
}
