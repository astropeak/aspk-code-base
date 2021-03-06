#ifndef DEBUG_H
#define DEBUG_H
#include <time.h>

#define ASPK_DEBUG_FILE_NAME "/tmp/aspk_debug_log.txt"
static FILE *aspk_debug_file = NULL;


// Store the formatted string of time in the output
static char* format_time(){
	static char myTime[50];
    time_t rawtime;
    struct tm * timeinfo;

    time ( &rawtime );
    timeinfo = localtime ( &rawtime );

    sprintf(myTime, "%d:%d:%d",timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
	return myTime;
}


#define dd_header() fprintf(aspk_debug_file, "[%s:%s:%d][%s] ", __FILE__, __FUNCTION__, __LINE__, format_time())

#define dd1(var)                                                        \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();   \
        fprintf(aspk_debug_file, #var "=0x%x\n", var);                  \
        fflush(aspk_debug_file);                                        \
    } while(0)

#define dd2(var1, var2)                                                 \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();   \
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x\n", var2);                \
        fflush(aspk_debug_file);                                        \
    } while(0)

#define dd3(var1, var2, var3)                                           \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();\
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x, ", var2);                \
        fprintf(aspk_debug_file, #var3 "=0x%x\n", var3);                \
        fflush(aspk_debug_file);                                        \
    } while(0)

#define dd4(var1, var2, var3, var4)                                     \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();\
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x, ", var2);                \
        fprintf(aspk_debug_file, #var3 "=0x%x, ", var3);                \
        fprintf(aspk_debug_file, #var4 "=0x%x\n", var4);                \
        fflush(aspk_debug_file);                                        \
    } while(0)

#define dd5(var1, var2, var3, var4, var5)                                     \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();\
        fprintf(aspk_debug_file, #var1 "=0x%x, ", var1);                \
        fprintf(aspk_debug_file, #var2 "=0x%x, ", var2);                \
        fprintf(aspk_debug_file, #var3 "=0x%x, ", var3);                \
        fprintf(aspk_debug_file, #var4 "=0x%x, ", var4);                \
        fprintf(aspk_debug_file, #var5 "=0x%x\n", var5);                \
        fflush(aspk_debug_file);                                        \
    } while(0)

#define dds(str)                                                        \
    do{                                                                 \
       if (!aspk_debug_file) {                                          \
           aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");         \
       }                                                                \
       dd_header();\
       fprintf(aspk_debug_file, "%s\n", str);                     \
        fflush(aspk_debug_file);                                        \
    } while(0)

//for vs, arg list should be (fmt, arg, ...)
#define dd(fmt, arg...)                                                 \
    do{                                                                 \
        if (!aspk_debug_file) {                                         \
            aspk_debug_file = fopen(ASPK_DEBUG_FILE_NAME, "a+");        \
        }                                                               \
        dd_header();\
        fprintf(aspk_debug_file, fmt "\n", ##arg);                      \
        fflush(aspk_debug_file);                                        \
    }while(0);

#define dd_enter()                              \
    dd("ENTER")

#define                                         \
    dd_exit()                                   \
    dd("EXIT")

#endif
