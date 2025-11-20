#include "MemoryTarget.h"

#include <utility>

#include "Logger.h"

namespace RedMemoryDump {

MemoryTarget::MemoryTarget() : name(""), type(""), frames(nullptr), size(0) {}

MemoryTarget::MemoryTarget(Red::CString p_name, const Red::CName& p_type,
                           uint32_t p_size)
    : name(std::move(p_name)), type(p_type), frames(nullptr), size(p_size) {}

Red::CString MemoryTarget::get_name() const {
  return name;
}

Red::CName MemoryTarget::get_type() const {
  return type;
}

uint32_t MemoryTarget::get_size() const {
  return size;
}

MemoryFrames MemoryTarget::get_frames() const {
  return frames;
}

Red::Handle<MemoryFrame> MemoryTarget::get_last_frame() const {
  if (frames.size == 0) {
    return {};
  }
  return frames[frames.size - 1];
}

void MemoryTarget::remove_frame(int index) {
  if (index < 0 || index >= frames.size) {
    return;
  }
  frames.RemoveAt(index);
}

Red::DynArray<Red::Handle<MemorySearchHandle>> MemoryTarget::search_handles(
  const Red::Handle<MemoryFrame>& p_frame,
  const Red::Optional<bool, false>& p_force) const {
  // Fetch all handles from RedHotTools, keep them in cache unless forced to clear.
  static Red::Memory::CoreAllocator allocator;
  static Red::HashMap<uint64_t, Red::WeakHandle<Red::ISerializable>> cache(&allocator);

  if (p_force.value) {
#ifdef _DEBUG
    Logger::log("Clear handle cache.");
#endif
    cache.Clear();
  }

  if (cache.size == 0) {
    Red::DynArray<Red::WeakHandle<Red::ISerializable>> handles;

    handles.Reserve(2100000); // around 2050000, allocate above to minimize round-trip.
    Red::CallStatic("RedHotTools", "GetAllHandles", handles);
    cache.Reserve(handles.size);
    for (const auto& handle : handles) {
      if (handle.Expired()) {
        continue;
      }
      const auto target = handle.Lock();
      const auto instance = reinterpret_cast<uint64_t>(target.instance);

      cache.Insert(instance, handle);
    }
    handles.Clear();
#ifdef _DEBUG
    Logger::logf("Retrieved %d handles from RedHotTools.", cache.size);
#endif
  }

  // Search for handles in the memory frame
  Red::DynArray<Red::Handle<MemorySearchHandle>> results;
  constexpr auto SharedPtrBaseSize = sizeof(Red::SharedPtrBase<void>);

  for (uint32_t i = 0; i + SharedPtrBaseSize < p_frame->get_size();) {
    const auto instance = p_frame->get_uint64(i);
    const auto refCnt = p_frame->get_uint64(i + sizeof(void*));
    if (!cache.Contains(instance)) {
      ++i;
      continue;
    }

    const auto handle = cache.Get(instance);
    if (handle->Expired()) {
      ++i;
      continue;
    }

    const auto target = handle->Lock();
    if (refCnt != reinterpret_cast<uint64_t>(target.refCount)) {
      ++i;
      continue;
    }

    const auto target_type = target->GetType()->GetName().ToString();
    auto result = Red::MakeHandle<MemorySearchHandle>(target_type, i);
    results.PushBack(result);

    i += SharedPtrBaseSize;
  }

#ifdef _DEBUG
  Logger::logf("Found %d handles.", results.size);
#endif

  std::ranges::sort(results,
                    [](const auto& a, const auto& b) -> bool {
                      return a->get_offset() < b->get_offset();
                    });

#ifdef _DEBUG
  Logger::logf("Sorted handles by offset.", results.size);
#endif
  return results;
}
}  // namespace RedMemoryDump