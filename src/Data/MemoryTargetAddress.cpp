#include "MemoryTargetAddress.h"

#include <utility>

namespace RedMemoryDump {

MemoryTargetAddress::MemoryTargetAddress() : address(nullptr) {}

MemoryTargetAddress::MemoryTargetAddress(Red::CString p_name,
                                         const Red::CName& p_type,
                                         const uint8_t* p_address,
                                         uint32_t p_size)
    : MemoryTarget(std::move(p_name), p_type, p_size), address(p_address) {}

void MemoryTargetAddress::set_size(uint32_t p_size) {
  size = p_size;
}

bool MemoryTargetAddress::is_size_locked() const {
  return false;
}

uint64_t MemoryTargetAddress::get_address() const {
  return reinterpret_cast<uint64_t>(address);
}

MemoryProperties MemoryTargetAddress::get_properties() const {
  return {};
}

Red::Handle<MemoryFrame> MemoryTargetAddress::capture() {
  if (size == 0 || address == nullptr) {
    return {};
  }
  Red::DynArray<uint8_t> buffer;

  buffer.Reserve(size);
  for (uint32_t i = 0; i < size; i++) {
    buffer.EmplaceBack(address[i]);
  }
  auto frame = Red::MakeHandle<MemoryFrame>(buffer);

  frames.PushBack(frame);
  return frame;
}

}  // namespace RedMemoryDump