#include "Config.h"
#ifdef _DEBUG
#include "Logger.h"
#endif

namespace RedMemoryDump {

RED4EXT_C_EXPORT bool RED4EXT_CALL Main(RED4ext::v1::PluginHandle p_handle,
                                        RED4ext::v1::EMainReason p_reason,
                                        const RED4ext::v1::Sdk* p_sdk) {
  switch (p_reason) {
    case RED4ext::v1::EMainReason::Load: {
#ifdef _DEBUG
      Logger::load(p_handle, p_sdk->logger);
#endif
      Red::TypeInfoRegistrar::RegisterDiscovered();
      break;
    }
    case RED4ext::v1::EMainReason::Unload: {
#ifdef _DEBUG
      Logger::unload();
#endif
      break;
    }
  }
  return true;
}

RED4EXT_C_EXPORT void RED4EXT_CALL Query(RED4ext::v1::PluginInfo* p_info) {
  p_info->name = L"RedMemoryDump";
  p_info->author = L"Rayshader";
  p_info->version =
    RED4EXT_V1_SEMVER(VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
  p_info->runtime = RED4EXT_V1_RUNTIME_VERSION_LATEST;
  p_info->sdk = RED4EXT_V1_SDK_VERSION_CURRENT;
}

RED4EXT_C_EXPORT uint32_t RED4EXT_CALL Supports() {
  return RED4EXT_API_VERSION_1;
}

}  // namespace RedMemoryDump
