#ifndef DEBUG_H
#define DEBUG_H

#define ASPK_DEBUG_FILE_NAME "/sdcard/aspk_debug_log.txt"
static FILE *aspk_debug_file = NULL;


#define dd1(var)                                                        \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);   \
        fprintf(aspk_debug_file, #var "=0x%x\n", var);                  \
    } while(0)

#define dd2(var1, var2)                                                 \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);   \
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x\n", var2);                \
    } while(0)

#define dd3(var1, var2, var3)                                           \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);   \
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x, ", var2);                \
        fprintf(aspk_debug_file, #var3 "=0x%x\n", var3);                \
    } while(0)

#define dd4(var1, var2, var3, var4)                                     \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);   \
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x, ", var2);                \
        fprintf(aspk_debug_file, #var3 "=0x%x, ", var3);                \
        fprintf(aspk_debug_file, #var4 "=0x%x\n", var4);                \
    } while(0)

#define dds(str)                                                        \
    do{                                                                 \
       if (!aspk_debug_file) {                                          \
           aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");         \
       }                                                                \
       fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);    \
       fprintf(aspk_debug_file, #str "=%s\n", str);                     \
    } while(0)

#define dd(fmt, arg...)                                                 \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        fprintf(aspk_debug_file, "[%s:%d] ", __FUNCTION__, __LINE__);   \
        fprintf(aspk_debug_file, fmt "\n", ##arg);                      \
    }while(0);

#define dd_enter()                              \
    dd("ENTER")

#define                                         \
    dd_exit()                                   \
    dd("EXIT")

#endif
