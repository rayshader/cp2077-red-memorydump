#ifndef REDMEMORYDUMP_MEMORYDUMP_H
#define REDMEMORYDUMP_MEMORYDUMP_H

#include <RED4ext/RED4ext.hpp>
#include <RedLib.hpp>

#include "MemoryTarget.h"

namespace RedMemoryDump {

class MemoryDump : public Red::IScriptable {
 public:
  static Red::Handle<MemoryTarget> track_scriptable(
    const Red::Handle<Red::IScriptable>& p_object);
  static Red::Handle<MemoryTarget> track_serializable(
    const Red::Handle<Red::ISerializable>& p_object);
  static Red::Handle<MemoryTarget> track_address(
    const Red::CString& p_name, const Red::CName& p_type, uint64_t p_address,
    const Red::Optional<uint32_t, 0x38>& p_size);

  RTTI_IMPL_TYPEINFO(RedMemoryDump::MemoryDump);
  RTTI_IMPL_ALLOCATOR();
};

}  // namespace RedMemoryDump

RTTI_DEFINE_CLASS(RedMemoryDump::MemoryDump, {
  RTTI_ALIAS("RedMemoryDump.MemoryDump");

  RTTI_METHOD(track_scriptable, "TrackScriptable");
  RTTI_METHOD(track_serializable, "TrackSerializable");
  RTTI_METHOD(track_address, "TrackAddress");
});

#endif  //REDMEMORYDUMP_MEMORYDUMP_H
