#include "MemoryFrame.h"

#include <utility>

namespace RedMemoryDump {

MemoryFrame::MemoryFrame(Red::DynArray<uint8_t> p_buffer)
    : buffer(std::move(p_buffer)) {
  for (const auto& byte : buffer) {
    Red::CString hex = std::format("{:02X}", byte).c_str();

    buffer_view.PushBack(hex);
  }
}

uint32_t MemoryFrame::get_size() const {
  return buffer.size;
}

Red::DynArray<uint8_t> MemoryFrame::get_buffer() const {
  return buffer;
}

Red::DynArray<Red::CString> MemoryFrame::get_buffer_view() const {
  return buffer_view;
}

template <typename T>
T MemoryFrame::get_value(uint32_t p_offset) const {
  if (p_offset + sizeof(T) > buffer.size) {
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

float MemoryFrame::get_fixed_point(uint32_t p_offset) const {
  auto value = get_value<Red::FixedPoint>(p_offset);

  return static_cast<float>(value.Bits) / (2 << 16);
}

Red::RectF MemoryFrame::get_rect_float(uint32_t p_offset) const {
  return get_value<Red::RectF>(p_offset);
}

Red::Point MemoryFrame::get_point(uint32_t p_offset) const {
  return get_value<Red::Point>(p_offset);
}

Red::Point3D MemoryFrame::get_point3d(uint32_t p_offset) const {
  return get_value<Red::Point3D>(p_offset);
}

Red::Box MemoryFrame::get_box(uint32_t p_offset) const {
  return get_value<Red::Box>(p_offset);
}

Red::Quad MemoryFrame::get_quad(uint32_t p_offset) const {
  return get_value<Red::Quad>(p_offset);
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

Red::Quaternion MemoryFrame::get_quaternion(uint32_t p_offset) const {
  return get_value<Red::Quaternion>(p_offset);
}

Red::EulerAngles MemoryFrame::get_euler_angles(uint32_t p_offset) const {
  return get_value<Red::EulerAngles>(p_offset);
}

Red::Matrix MemoryFrame::get_matrix(uint32_t p_offset) const {
  return get_value<Red::Matrix>(p_offset);
}

Red::Transform MemoryFrame::get_transform(uint32_t p_offset) const {
  return get_value<Red::Transform>(p_offset);
}

Red::QsTransform MemoryFrame::get_qs_transform(uint32_t p_offset) const {
  return get_value<Red::QsTransform>(p_offset);
}

Red::WorldPosition MemoryFrame::get_world_position(uint32_t p_offset) const {
  return get_value<Red::WorldPosition>(p_offset);
}

Red::WorldTransform MemoryFrame::get_world_transform(uint32_t p_offset) const {
  return get_value<Red::WorldTransform>(p_offset);
}

Red::Color MemoryFrame::get_color(uint32_t p_offset) const {
  return get_value<Red::Color>(p_offset);
}

Red::ColorBalance MemoryFrame::get_color_balance(uint32_t p_offset) const {
  return get_value<Red::ColorBalance>(p_offset);
}

Red::HDRColor MemoryFrame::get_hdr_color(uint32_t p_offset) const {
  return get_value<Red::HDRColor>(p_offset);
}

Red::Handle<MemoryCurveDataFloat> MemoryFrame::get_curve_data_float(
  uint32_t p_offset) const {
  if (p_offset + sizeof(Red::CurveData<float>) > buffer.size) {
    return {};
  }
  auto* ptr = reinterpret_cast<Red::CurveData<float>*>(buffer.entries + p_offset);

  return Red::MakeHandle<MemoryCurveDataFloat>(ptr);
}

}  // namespace RedMemoryDump