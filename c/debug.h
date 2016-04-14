#ifndef DEBUG_H
#define DEBUG_H

#define dd1(var)                                    \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(#var "=0x%x\n", var);                \
    } while(0)

#define dd2(var1, var2)                             \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(#var1 "=0x%x, ", var1);              \
        printf(#var2 "=0x%x\n", var2);              \
    } while(0)

#define dd3(var1, var2, var3)                       \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(#var1 "=0x%x, ", var1);              \
        printf(#var2 "=0x%x, ", var2);              \
        printf(#var3 "=0x%x\n", var3);              \
    } while(0)

#define dd4(var1, var2, var3, var4)                 \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(#var1 "=0x%x, ", var1);              \
        printf(#var2 "=0x%x, ", var2);              \
        printf(#var3 "=0x%x, ", var3);              \
        printf(#var4 "=0x%x\n", var4);              \
    } while(0)

#define dds(str)                                    \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(#str "=%s\n", str);                  \
    } while(0)

#define dd(fmt, arg...)                                \
    do{                                             \
        printf("[%s:%d] ", __FUNCTION__, __LINE__); \
        printf(fmt "\n", ##arg);                           \
    }while(0);

#define dd_enter()                              \
    dd("ENTER")

#define                                         \
    dd_exit()                                   \
    dd("EXIT")

#endif
