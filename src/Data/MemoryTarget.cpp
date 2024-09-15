#include "MemoryTarget.h"

#include <utility>

namespace RedMemoryDump {

MemoryTarget::MemoryTarget() : name(""), type(""), frames(nullptr), size(0) {}

MemoryTarget::MemoryTarget(Red::CString p_name, const Red::CName& p_type,
                           uint32_t p_size)
    : name(std::move(p_name)), type(p_type), frames(nullptr), size(p_size) {}

Red::CString MemoryTarget::get_name() const {
  return name;
}

Red::CName MemoryTarget::get_type() const {
  return type;
}

uint32_t MemoryTarget::get_size() const {
  return size;
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

void MemoryTarget::remove_frame(int index) {
  if (index < 0 || index >= frames.size) {
    return;
  }
  frames.RemoveAt(index);
}

}  // namespace RedMemoryDump