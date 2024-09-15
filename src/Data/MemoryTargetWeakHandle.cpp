#include "MemoryTargetWeakHandle.h"

#include <algorithm>
#include <utility>

namespace RedMemoryDump {

RED4EXT_INLINE MemoryProperties get_class_properties(Red::CClass* p_class) {
  MemoryProperties properties;
  uint32_t size = p_class->size;

  while (p_class != nullptr) {
    for (const auto& property : p_class->props) {
      if (property->valueOffset + property->type->GetSize() <= size) {
        properties.PushBack(Red::MakeHandle<MemoryProperty>(property));
      }
    }
    p_class = p_class->parent;
  }
  std::sort(properties.begin(), properties.end(),
            [](const auto& a, const auto& b) -> bool {
              return a->get_offset() < b->get_offset();
            });
  return properties;
}

MemoryTargetWeakHandle::MemoryTargetWeakHandle() : object(nullptr) {}

MemoryTargetWeakHandle::MemoryTargetWeakHandle(
  const Red::Handle<Red::ISerializable>& p_object)
    : MemoryTarget(p_object->GetType()->GetName().ToString(),
                   p_object->GetType()->GetName(),
                   p_object->GetType()->GetSize()),
      object(p_object),
      properties(get_class_properties(p_object->GetType())) {}

void MemoryTargetWeakHandle::set_size(uint32_t p_size) {}

bool MemoryTargetWeakHandle::is_size_locked() const {
  return true;
}

uint64_t MemoryTargetWeakHandle::get_address() const {
  if (object.Expired()) {
    return 0;
  }
  return reinterpret_cast<uint64_t>(object.Lock().GetPtr());
}

MemoryProperties MemoryTargetWeakHandle::get_properties() const {
  return properties;
}

Red::Handle<MemoryFrame> MemoryTargetWeakHandle::capture() {
  if (object.Expired()) {
    return {};
  }
  auto handle = object.Lock();
  auto* address = reinterpret_cast<uint8_t*>(handle.GetPtr());
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