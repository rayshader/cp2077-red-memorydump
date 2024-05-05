#ifndef REDMEMORYDUMP_MEMORYFRAME_H
#define REDMEMORYDUMP_MEMORYFRAME_H

#include <RED4ext/RED4ext.hpp>
#include <RED4ext/Scripting/Natives/Generated/Vector4.hpp>
#include <RedLib.hpp>

namespace RedMemoryDump {

class MemoryFrame : public Red::IScriptable {
 private:
  Red::DynArray<uint8_t> buffer;

  template <typename T>
  inline T get_value(uint32_t p_offset) const;

 public:
  MemoryFrame() = default;

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

  void push_back(uint8_t byte);

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
});

#endif  //REDMEMORYDUMP_MEMORYFRAME_H