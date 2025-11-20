#ifndef REDMEMORYDUMP_LOGGER_H
#define REDMEMORYDUMP_LOGGER_H

#include <cstdarg>

#include <RED4ext/RED4ext.hpp>

namespace RedMemoryDump {
class Logger {
public:
    static RED4ext::PluginHandle g_handle;
    static RED4ext::Logger *g_logger;

    static void load(const RED4ext::PluginHandle p_handle, RED4ext::Logger *p_logger) {
        g_handle = p_handle;
        g_logger = p_logger;
    }

    static void unload() {
        g_handle = nullptr;
        g_logger = nullptr;
    }

    static void log(const char *message) {
        if (g_handle && g_logger) {
            g_logger->Info(g_handle, message);
        }
    }

    static void logf(const char *p_format, ...) {
        if (g_handle && g_logger) {
            va_list args;
            va_start(args, p_format);
            g_logger->InfoF(g_handle, p_format, args);
            va_end(args);
        }
    }
};
}

#endif //REDMEMORYDUMP_LOGGER_H