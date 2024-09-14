#ifndef REDMEMORYDUMP_MEMORYCURVEDATAFLOAT_H
#define REDMEMORYDUMP_MEMORYCURVEDATAFLOAT_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

namespace RedMemoryDump {

class MemoryCurveDataFloat : public Red::IScriptable {
 private:
  Red::CurveData<float>* curve = nullptr;

 public:
  MemoryCurveDataFloat() = default;
  explicit MemoryCurveDataFloat(Red::CurveData<float>* p_curve);

  [[nodiscard]] Red::CString get_type_name() const;

  [[nodiscard]] uint32_t get_size() const;
  [[nodiscard]] Red::DynArray<float> get_points() const;
  [[nodiscard]] Red::DynArray<float> get_values() const;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryCurveDataFloat);
  RTTI_IMPL_ALLOCATOR();
};

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryCurveDataFloat, {
  RTTI_ALIAS("RedMemoryDump.MemoryCurveDataFloat");

  RTTI_METHOD(get_type_name, "GetTypeName");
  RTTI_METHOD(get_size, "GetSize");
  RTTI_METHOD(get_points, "GetPoints");
  RTTI_METHOD(get_values, "GetValues");
})

#endif  //REDMEMORYDUMP_MEMORYCURVEDATAFLOAT_H
