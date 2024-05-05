#ifndef REDMEMORYDUMP_MEMORYPROPERTY_H
#define REDMEMORYDUMP_MEMORYPROPERTY_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

namespace RedMemoryDump {

class MemoryProperty : public Red::IScriptable {
 private:
  const Red::CProperty* property;

 public:
  MemoryProperty();
  explicit MemoryProperty(const Red::CProperty* p_property);

  [[nodiscard]] Red::CString get_name() const;
  [[nodiscard]] uint32_t get_offset() const;

  [[nodiscard]] Red::CName get_type_name() const;
  [[nodiscard]] uint32_t get_type_size() const;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryProperty);
  RTTI_IMPL_ALLOCATOR();
};

using MemoryProperties = Red::DynArray<Red::Handle<MemoryProperty>>;

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryProperty, {
  RTTI_ALIAS("RedMemoryDump.MemoryProperty");

  RTTI_METHOD(get_name, "GetName");
  RTTI_METHOD(get_offset, "GetOffset");

  RTTI_METHOD(get_type_name, "GetTypeName");
  RTTI_METHOD(get_type_size, "GetTypeSize");
});

#endif  //REDMEMORYDUMP_MEMORYPROPERTY_H
