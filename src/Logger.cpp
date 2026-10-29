#include "Logger.h"

namespace RedMemoryDump {
RED4ext::v1::PluginHandle Logger::g_handle = nullptr;
RED4ext::v1::Logger* Logger::g_logger = nullptr;
}  // namespace RedMemoryDump