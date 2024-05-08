#include "MemoryTarget.h"

#include <algorithm>
#include <utility>

namespace RedMemoryDump {

MemoryProperties get_class_properties(Red::CClass* p_class) {
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

MemoryTarget::MemoryTarget()
    : name(""),
      type(""),
      address(nullptr),
      size(0),
      locked(true),
      properties(nullptr),
      frames(nullptr) {}

MemoryTarget::MemoryTarget(const Red::Handle<Red::IScriptable>& p_object)
    : name(p_object->GetType()->GetTypeName()),
      type(p_object->GetType()->GetName()),
      address(reinterpret_cast<const uint8_t*>(p_object.GetPtr())),
      size(p_object->GetType()->GetSize()),
      locked(true),
      properties(get_class_properties(p_object->GetType())),
      frames(nullptr) {

}

MemoryTarget::MemoryTarget(const Red::Handle<Red::ISerializable>& p_object)
    : name(p_object->GetType()->GetTypeName()),
      type(p_object->GetType()->GetName()),
      address(reinterpret_cast<const uint8_t*>(p_object.GetPtr())),
      size(p_object->GetType()->GetSize()),
      locked(true),
      properties(get_class_properties(p_object->GetType())),
      frames(nullptr) {

}

MemoryTarget::MemoryTarget(Red::CString p_name, const Red::CName& p_type,
                           const uint8_t* p_address, uint32_t p_size)
    : name(std::move(p_name)),
      type(p_type),
      address(p_address),
      size(p_size),
      locked(false),
      properties(nullptr),
      frames(nullptr) {}

Red::CString MemoryTarget::get_name() const {
  return name;
}

Red::CName MemoryTarget::get_type() const {
  return type;
}

uint32_t MemoryTarget::get_size() const {
  return size;
}

void MemoryTarget::set_size(uint32_t p_size) {
  if (locked) {
    return;
  }
  size = p_size;
}
bool MemoryTarget::is_locked() const {
  return locked;
}

uint64_t MemoryTarget::get_address() const {
  return (uint64_t)address;
}

MemoryProperties MemoryTarget::get_properties() const {
  return properties;
}

MemoryFrames MemoryTarget::get_frames() const {
  return frames;
}

Red::Handle<MemoryFrame> MemoryTarget::get_last_frame() const {
  if (frames.size == 0) {
    return {};
  }
  return frames[frames.size - 1];
}

// NOTE: capturing is not thread-safe. It might record inconsistent bytes of
//       memory when writing at the same time elsewhere.
Red::Handle<MemoryFrame> MemoryTarget::capture() {
  Red::DynArray<uint8_t> buffer;

  for (uint32_t i = 0; i < size; i++) {
    buffer.PushBack(address[i]);
  }
  auto frame = Red::MakeHandle<MemoryFrame>(buffer);

  frames.PushBack(frame);
  return frame;
}

}  // namespace RedMemoryDump