#include "MemoryDump.h"

#include "MemoryTargetAddress.h"
#include "MemoryTargetWeakHandle.h"

namespace RedMemoryDump {

Red::Handle<MemoryTarget> MemoryDump::track_serializable(
  const Red::Handle<Red::ISerializable>& p_object) {
  if (!p_object) {
    return {};
  }
  auto target = Red::MakeHandle<MemoryTargetWeakHandle>(p_object);

  target->capture();
  return target;
}

Red::Handle<MemoryTarget> MemoryDump::track_address(
  const Red::CString& p_name, const Red::CName& p_type, uint64_t p_address,
  const Red::Optional<uint32_t, 0x38>& p_size) {
  auto target = Red::MakeHandle<MemoryTargetAddress>(
    p_name, p_type, reinterpret_cast<uint8_t*>(p_address), p_size.value);

  target->capture();
  return target;
}

}  // namespace RedMemoryDump