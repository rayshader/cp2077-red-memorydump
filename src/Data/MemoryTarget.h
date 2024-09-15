#ifndef REDMEMORYDUMP_MEMORYTARGET_H
#define REDMEMORYDUMP_MEMORYTARGET_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include "MemoryFrame.h"
#include "MemoryProperty.h"

namespace RedMemoryDump {

class MemoryTarget : public Red::IScriptable {
 private:
  const Red::CString name;
  const Red::CName type;

 protected:
  uint32_t size;

  MemoryFrames frames;

 public:
  MemoryTarget();
  explicit MemoryTarget(Red::CString p_name, const Red::CName& p_type,
                        uint32_t p_size);

  [[nodiscard]] Red::CString get_name() const;
  [[nodiscard]] Red::CName get_type() const;

  [[nodiscard]] uint32_t get_size() const;
  [[nodiscard]] virtual bool is_size_locked() const = 0;
  virtual void set_size(uint32_t p_size) = 0;

  [[nodiscard]] virtual uint64_t get_address() const = 0;
  [[nodiscard]] virtual MemoryProperties get_properties() const = 0;

  [[nodiscard]] MemoryFrames get_frames() const;
  [[nodiscard]] Red::Handle<MemoryFrame> get_last_frame() const;

  virtual Red::Handle<MemoryFrame> capture() = 0;
  void remove_frame(int index);

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryTarget);
  RTTI_IMPL_ALLOCATOR();
};

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryTarget, {
  RTTI_ALIAS("RedMemoryDump.MemoryTarget");

  RTTI_METHOD(get_name, "GetName");
  RTTI_METHOD(get_type, "GetType");

  RTTI_METHOD(get_size, "GetSize");
  RTTI_METHOD(set_size, "SetSize");
  RTTI_METHOD(is_size_locked, "IsSizeLocked");

  RTTI_METHOD(get_address, "GetAddress");
  RTTI_METHOD(get_properties, "GetProperties");

  RTTI_METHOD(get_frames, "GetFrames");
  RTTI_METHOD(get_last_frame, "GetLastFrame");

  RTTI_METHOD(capture, "Capture");
  RTTI_METHOD(remove_frame, "RemoveFrame");
});

#endif  //REDMEMORYDUMP_MEMORYTARGET_H
