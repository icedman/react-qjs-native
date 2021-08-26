extern "C" {
#include "quickjs-libc.h"
#include "quickjs.h"
}

#include <cstring>
#include <fstream>
#include <iostream>
#include <istream>
#include <streambuf>
#include <string>

#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>

// if != 0, then there is data to be read on stdin
int kbhit(int timeout = 500)
{
    // timeout structure passed into select
    struct timeval tv;
    // fd_set passed into select
    fd_set fds;
    // Set up the timeout.  here we can wait for 1 second
    tv.tv_sec = 0;
    tv.tv_usec = timeout;

    // Zero out the fd_set - make sure it's pristine
    FD_ZERO(&fds);
    // Set the FD that we want to read
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    // select takes the last file descriptor value + 1 in the fdset to check,
    // the fdset for reads, writes, and errors.  We are only passing in reads.
    // the last parameter is the timeout.  select will return if an FD is ready or
    // the timeout has occurred
    select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv);
    // return 0 if STDIN is not ready to be read.

    return FD_ISSET(STDIN_FILENO, &fds);
}

static JSRuntime* rt = 0;
static JSContext* ctx = 0;

static JSValue js_log(JSContext* ctx, JSValueConst this_val,
    int argc, JSValueConst* argv)
{
    std::cout << "log: ";
    int i;
    const char* str;

    for (i = 0; i < argc; i++) {
        str = JS_ToCString(ctx, argv[i]);
        if (!str)
            return JS_EXCEPTION;
        std::cout << str << std::endl;
        JS_FreeCString(ctx, str);
    }
    return JS_UNDEFINED;
}


/* also used to initialize the worker context */
static JSContext *JS_NewCustomContext(JSRuntime *rt)
{
    JSContext *ctx;
    ctx = JS_NewContext(rt);
    if (!ctx)
        return NULL;
    /* system modules */
    js_init_module_std(ctx, "std");
    js_init_module_os(ctx, "os");
    return ctx;
}

int main(int argc, char **argv)
{
    std::cout << "start" << std::endl;

    rt = JS_NewRuntime();

    js_std_set_worker_new_context_func(JS_NewCustomContext);
    js_std_init_handlers(rt);
    ctx = JS_NewCustomContext(rt);
    if (!ctx) {
        fprintf(stderr, "qjs: cannot allocate JS context\n");
        exit(2);
    }

    /* loader for ES6 modules */
    JS_SetModuleLoaderFunc(rt, NULL, js_module_loader, NULL);

    // ctx = JS_NewContextRaw(rt);

    // JS_AddIntrinsicBaseObjects(ctx);
    // JS_AddIntrinsicEval(ctx);

    JSValue global_obj, app;

    global_obj = JS_GetGlobalObject(ctx);

    app = JS_NewObject(ctx);
    JS_SetPropertyStr(ctx, app, "log", JS_NewCFunction(ctx, js_log, "log", 1));
    JS_SetPropertyStr(ctx, global_obj, "app", app);
    JS_FreeValue(ctx, global_obj);

    JSValue ret;

    std::string imports = "import * as std from 'std';";
                imports += "import * as os from 'os';";
                imports += "globalThis.os = os;";
                imports += "globalThis.std = std;";
    ret = JS_Eval(ctx, imports.c_str(), imports.length(), "<input>", JS_EVAL_TYPE_MODULE);
    if (JS_IsException(ret)) {
        // printf("JS err : %s\n", JS_ToCString(ctx, JS_GetException(ctx)));
        js_std_dump_error(ctx);
        JS_ResetUncatchableError(ctx);
        return 0;
    }

    std::string path = "./dist/app.js";
    std::ifstream file(path, std::ifstream::in);
    std::string script((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
    // std::cout << script << std::endl;    
    ret = JS_Eval(ctx, script.c_str(), script.length(), path.c_str(), JS_EVAL_TYPE_GLOBAL);
    if (JS_IsException(ret)) {
        // printf("JS err : %s\n", JS_ToCString(ctx, JS_GetException(ctx)));
        js_std_dump_error(ctx);
        JS_ResetUncatchableError(ctx);
        return 0;
    }

    std::string input;
    while(true) {

        if (kbhit(500)) {
            std::cout << "?" << std::endl;
            char seq[4];
            read(STDIN_FILENO, &seq[0], 1);
            input += seq[0];

            std::cout << seq[0];
            switch(seq[0]) {
            case 13: {

                JSValue ret = JS_Eval(ctx, input.c_str(), input.length(), "<input>", JS_EVAL_TYPE_GLOBAL);
                if (JS_IsException(ret)) {
                    js_std_dump_error(ctx);
                    JS_ResetUncatchableError(ctx);
                    return 0;
                }

                break;
            }
            }
        }

        js_std_loop(ctx);
        usleep(5000);
    }

    js_std_free_handlers(rt);

    JS_FreeContext(ctx);
    JS_FreeRuntime(rt);

    std::cout << "end" << std::endl;
    
    return 0;
}