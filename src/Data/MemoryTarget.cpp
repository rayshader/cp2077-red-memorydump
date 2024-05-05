#include "MemoryTarget.h"

#include <utility>

namespace RedMemoryDump {

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
      properties(nullptr),
      frames(nullptr) {
  for (const auto& prop : p_object->GetType()->props) {
    auto property = Red::MakeHandle<MemoryProperty>(prop);

    properties.PushBack(property);
  }
}

MemoryTarget::MemoryTarget(const Red::Handle<Red::ISerializable>& p_object)
    : name(p_object->GetType()->GetTypeName()),
      type(p_object->GetType()->GetName()),
      address(reinterpret_cast<const uint8_t*>(p_object.GetPtr())),
      size(p_object->GetType()->GetSize()),
      locked(true),
      properties(nullptr),
      frames(nullptr) {
  for (const auto& prop : p_object->GetType()->props) {
    auto property = Red::MakeHandle<MemoryProperty>(prop);

    properties.PushBack(property);
  }
}

MemoryTarget::MemoryTarget(Red::CString p_name, const Red::CName& p_type,
                           void* p_address, uint32_t p_size)
    : name(std::move(p_name)),
      type(p_type),
      address(static_cast<const uint8_t*>(p_address)),
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

Red::Handle<MemoryFrame> MemoryTarget::capture() {
  Red::Handle<MemoryFrame> frame = Red::MakeHandle<MemoryFrame>();

  for (uint32_t i = 0; i < size; i++) {
    frame->push_back(address[i]);
  }
  frames.PushBack(frame);
  return frame;
}

}  // namespace RedMemoryDump