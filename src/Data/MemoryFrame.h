#ifndef REDMEMORYDUMP_MEMORYFRAME_H
#define REDMEMORYDUMP_MEMORYFRAME_H

#include <RED4ext/RED4ext.hpp>
#include <RED4ext/Scripting/Natives/Generated/EulerAngles.hpp>
#include <RED4ext/Scripting/Natives/Generated/Quaternion.hpp>
#include <RED4ext/Scripting/Natives/Generated/Vector2.hpp>
#include <RED4ext/Scripting/Natives/Generated/Vector3.hpp>
#include <RED4ext/Scripting/Natives/Generated/Vector4.hpp>
#include <RED4ext/Scripting/Natives/Generated/WorldPosition.hpp>
#include <RED4ext/Scripting/Natives/Generated/WorldTransform.hpp>
#include <RedLib.hpp>

namespace RedMemoryDump {

class MemoryFrame : public Red::IScriptable {
 private:
  Red::DynArray<uint8_t> buffer;
  Red::DynArray<Red::CString> buffer_view;

  template <typename T>
  inline T get_value(uint32_t p_offset) const;

 public:
  MemoryFrame() = default;
  explicit MemoryFrame(Red::DynArray<uint8_t> p_buffer);

  [[nodiscard]] uint32_t get_size() const;
  [[nodiscard]] Red::DynArray<uint8_t> get_buffer() const;
  [[nodiscard]] Red::DynArray<Red::CString> get_buffer_view() const;

  [[nodiscard]] bool get_bool(uint32_t p_offset) const;
  [[nodiscard]] int32_t get_int32(uint32_t p_offset) const;
  [[nodiscard]] int64_t get_int64(uint32_t p_offset) const;
  [[nodiscard]] uint32_t get_uint32(uint32_t p_offset) const;
  [[nodiscard]] uint64_t get_uint64(uint32_t p_offset) const;
  [[nodiscard]] float get_float(uint32_t p_offset) const;
  [[nodiscard]] double get_double(uint32_t p_offset) const;
  [[nodiscard]] Red::CString get_string(uint32_t p_offset) const;
  [[nodiscard]] Red::CName get_cname(uint32_t p_offset) const;
  [[nodiscard]] Red::Vector2 get_vector2(uint32_t p_offset) const;
  [[nodiscard]] Red::Vector3 get_vector3(uint32_t p_offset) const;
  [[nodiscard]] Red::Vector4 get_vector4(uint32_t p_offset) const;
  [[nodiscard]] Red::Quaternion get_quaternion(uint32_t p_offset) const;
  [[nodiscard]] Red::EulerAngles get_euler_angles(uint32_t p_offset) const;
  [[nodiscard]] Red::WorldPosition get_world_position(uint32_t p_offset) const;
  [[nodiscard]] Red::WorldTransform get_world_transform(
    uint32_t p_offset) const;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryFrame);
  RTTI_IMPL_ALLOCATOR();
};

using MemoryFrames = Red::DynArray<Red::Handle<MemoryFrame>>;

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryFrame, {
  RTTI_ALIAS("RedMemoryDump.MemoryFrame");

  RTTI_METHOD(get_size, "GetSize");
  RTTI_METHOD(get_buffer, "GetBuffer");
  RTTI_METHOD(get_buffer_view, "GetBufferView");

  RTTI_METHOD(get_bool, "GetBool");
  RTTI_METHOD(get_int32, "GetInt32");
  RTTI_METHOD(get_int64, "GetInt64");
  RTTI_METHOD(get_uint32, "GetUint32");
  RTTI_METHOD(get_uint64, "GetUint64");
  RTTI_METHOD(get_float, "GetFloat");
  RTTI_METHOD(get_double, "GetDouble");
  RTTI_METHOD(get_string, "GetString");
  RTTI_METHOD(get_cname, "GetCName");
  RTTI_METHOD(get_vector2, "GetVector2");
  RTTI_METHOD(get_vector3, "GetVector3");
  RTTI_METHOD(get_vector4, "GetVector4");
  RTTI_METHOD(get_quaternion, "GetQuaternion");
  RTTI_METHOD(get_euler_angles, "GetEulerAngles");
  RTTI_METHOD(get_world_position, "GetWorldPosition");
  RTTI_METHOD(get_world_transform, "GetWorldTransform");
})

#endif  //REDMEMORYDUMP_MEMORYFRAME_H
