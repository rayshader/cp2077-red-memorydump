#ifndef REDMEMORYDUMP_MEMORYTARGETADDRESS_H
#define REDMEMORYDUMP_MEMORYTARGETADDRESS_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include "MemoryTarget.h"

namespace RedMemoryDump {

class MemoryTargetAddress : public MemoryTarget {
 private:
  const uint8_t* address;

 public:
  MemoryTargetAddress();
  explicit MemoryTargetAddress(Red::CString p_name, const Red::CName& p_type,
                               const uint8_t* p_address, uint32_t p_size);

  void set_size(uint32_t p_size) override;
  [[nodiscard]] bool is_size_locked() const override;

  [[nodiscard]] uint64_t get_address() const override;
  [[nodiscard]] MemoryProperties get_properties() const override;

  Red::Handle<MemoryFrame> capture() override;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryTargetAddress);
  RTTI_IMPL_ALLOCATOR();
};

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryTargetAddress, {
  RTTI_ALIAS("RedMemoryDump.MemoryTargetAddress");

  RTTI_PARENT(RedMemoryDump::MemoryTarget);

  RTTI_METHOD(set_size, "SetSize");
  RTTI_METHOD(is_size_locked, "IsSizeLocked");

  RTTI_METHOD(get_address, "GetAddress");
  RTTI_METHOD(get_properties, "GetProperties");

  RTTI_METHOD(capture, "Capture");
});

#endif  //REDMEMORYDUMP_MEMORYTARGETADDRESS_H
