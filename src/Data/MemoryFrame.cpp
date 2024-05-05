#include "MemoryFrame.h"

namespace RedMemoryDump {

uint32_t MemoryFrame::get_size() const {
  return buffer.size;
}

Red::DynArray<uint8_t> MemoryFrame::get_buffer() const {
  return buffer;
}

Red::DynArray<Red::CString> MemoryFrame::get_buffer_view() const {
  Red::DynArray<Red::CString> view;

  for (const auto& byte : buffer) {
    std::stringstream ss;

    ss << std::hex;
    ss << std::setw(2);
    ss << std::setfill('0');
    ss << std::uppercase;
    ss << (int)byte;
    view.PushBack(ss.str());
  }
  return view;
}

template <typename T>
T MemoryFrame::get_value(uint32_t p_offset) const {
  if (p_offset + sizeof(T) >= buffer.size) {
    return T();
  }
  auto* ptr = reinterpret_cast<T*>(buffer.entries + p_offset);

  return *ptr;
}

bool MemoryFrame::get_bool(uint32_t p_offset) const {
  return get_value<bool>(p_offset);
}

int32_t MemoryFrame::get_int32(uint32_t p_offset) const {
  return get_value<int32_t>(p_offset);
}

int64_t MemoryFrame::get_int64(uint32_t p_offset) const {
  return get_value<int64_t>(p_offset);
}

uint32_t MemoryFrame::get_uint32(uint32_t p_offset) const {
  return get_value<uint32_t>(p_offset);
}

uint64_t MemoryFrame::get_uint64(uint32_t p_offset) const {
  return get_value<uint64_t>(p_offset);
}

float MemoryFrame::get_float(uint32_t p_offset) const {
  return get_value<float>(p_offset);
}

double MemoryFrame::get_double(uint32_t p_offset) const {
  return get_value<double>(p_offset);
}

Red::CString MemoryFrame::get_string(uint32_t p_offset) const {
  return get_value<Red::CString>(p_offset);
}

Red::CName MemoryFrame::get_cname(uint32_t p_offset) const {
  return get_value<Red::CName>(p_offset);
}

Red::Vector2 MemoryFrame::get_vector2(uint32_t p_offset) const {
  return get_value<Red::Vector2>(p_offset);
}

Red::Vector3 MemoryFrame::get_vector3(uint32_t p_offset) const {
  return get_value<Red::Vector3>(p_offset);
}

Red::Vector4 MemoryFrame::get_vector4(uint32_t p_offset) const {
  return get_value<Red::Vector4>(p_offset);
}

void MemoryFrame::push_back(uint8_t byte) {
  buffer.PushBack(byte);
}

}  // namespace RedMemoryDump