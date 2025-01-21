#ifndef MEMORYSEARCHHANDLE_H
#define MEMORYSEARCHHANDLE_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

namespace RedMemoryDump {

class MemorySearchHandle : public Red::IScriptable {
  Red::CString type;
  uint64_t offset = 0;

public:
  MemorySearchHandle() = default;
  explicit MemorySearchHandle(const Red::CString& p_type, uint64_t p_offset);

  [[nodiscard]] Red::CString get_type() const;
  [[nodiscard]] uint64_t get_offset() const;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemorySearchHandle);
  RTTI_IMPL_ALLOCATOR();
};

}

RTTI_DEFINE_CLASS(RedMemoryDump::MemorySearchHandle, {
  RTTI_ALIAS("RedMemoryDump.MemorySearchHandle");

  RTTI_GETTER(type, "GetType");
  RTTI_GETTER(offset, "GetOffset");
});

#endif //MEMORYSEARCHHANDLE_H
