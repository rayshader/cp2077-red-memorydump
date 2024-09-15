#ifndef REDMEMORYDUMP_MEMORYTARGETWEAKHANDLE_H
#define REDMEMORYDUMP_MEMORYTARGETWEAKHANDLE_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include "MemoryTarget.h"

namespace RedMemoryDump {

class MemoryTargetWeakHandle : public MemoryTarget {
 private:
  const Red::WeakHandle<Red::ISerializable> object;
  const MemoryProperties properties;

 public:
  MemoryTargetWeakHandle();
  explicit MemoryTargetWeakHandle(
    const Red::Handle<Red::ISerializable>& p_object);

  void set_size(uint32_t p_size) override;
  [[nodiscard]] bool is_size_locked() const override;

  [[nodiscard]] uint64_t get_address() const override;
  [[nodiscard]] MemoryProperties get_properties() const override;

  Red::Handle<MemoryFrame> capture() override;

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryTargetWeakHandle);
  RTTI_IMPL_ALLOCATOR();
};

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryTargetWeakHandle, {
  RTTI_ALIAS("RedMemoryDump.MemoryTargetWeakHandle");

  RTTI_PARENT(RedMemoryDump::MemoryTarget);

  RTTI_METHOD(set_size, "SetSize");
  RTTI_METHOD(is_size_locked, "IsSizeLocked");

  RTTI_METHOD(get_address, "GetAddress");
  RTTI_METHOD(get_properties, "GetProperties");

  RTTI_METHOD(capture, "Capture");
});

#endif  //REDMEMORYDUMP_MEMORYTARGETWEAKHANDLE_H
