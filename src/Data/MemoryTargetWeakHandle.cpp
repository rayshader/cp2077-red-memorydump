#include "MemoryTargetWeakHandle.h"

#include <algorithm>

namespace RedMemoryDump {

RED4EXT_INLINE MemoryProperties get_class_properties(Red::CClass* p_class) {
  MemoryProperties properties;
  uint32_t size = p_class->size;

  while (p_class != nullptr) {
    for (const auto& property : p_class->props) {
      if (!property->flags.isScripted && property->valueOffset + property->type->GetSize() <= size) {
        properties.PushBack(Red::MakeHandle<MemoryProperty>(property));
      }
    }
    p_class = p_class->parent;
  }
  std::ranges::sort(properties,
                    [](const auto& a, const auto& b) -> bool {
                      return a->get_offset() < b->get_offset();
                    });
  return properties;
}

MemoryTargetWeakHandle::MemoryTargetWeakHandle() : object(nullptr) {}

MemoryTargetWeakHandle::MemoryTargetWeakHandle(const Red::Handle<Red::ISerializable>& p_object)
    : MemoryTarget(p_object->GetType()->GetName().ToString(),
                   p_object->GetType()->GetName(),
                   p_object->GetType()->GetSize()),
      object(p_object),
      properties(get_class_properties(p_object->GetType())) {}

void MemoryTargetWeakHandle::set_size(uint32_t p_size) {}

bool MemoryTargetWeakHandle::is_size_locked() const {
  return true;
}

uint64_t MemoryTargetWeakHandle::get_address() const {
  if (object.Expired()) {
    return 0;
  }
  return reinterpret_cast<uint64_t>(object.Lock().GetPtr());
}

MemoryProperties MemoryTargetWeakHandle::get_properties() const {
  return properties;
}

Red::Handle<MemoryFrame> MemoryTargetWeakHandle::capture() {
  if (object.Expired()) {
    return {};
  }
  auto handle = object.Lock();
  auto* address = reinterpret_cast<uint8_t*>(handle.GetPtr());
  Red::DynArray<uint8_t> buffer;

  buffer.Reserve(size);
  for (uint32_t i = 0; i < size; i++) {
    buffer.EmplaceBack(address[i]);
  }
  auto frame = Red::MakeHandle<MemoryFrame>(buffer);

  frames.PushBack(frame);
  return frame;
}

Red::DynArray<Red::Handle<MemorySearchHandle>> MemoryTargetWeakHandle::search_handles(
  const Red::Handle<MemoryFrame>& p_frame,
  const Red::Optional<bool, false>& p_force) const {
  // Fetch all handles from RedHotTools, keep them in cache unless forced to clear.
  static Red::Memory::CoreAllocator allocator;
  static Red::HashMap<uint64_t, Red::WeakHandle<Red::ISerializable>> cache(&allocator);

  if (p_force.value) {
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
  }
  // Search for handles in memory frame
  Red::DynArray<Red::Handle<MemorySearchHandle>> results;
  constexpr auto SharedPtrBaseSize = sizeof(Red::SharedPtrBase<void>);

  for (uint32_t i = 0; i + SharedPtrBaseSize < p_frame->get_size(); i++) {
    const auto instance = p_frame->get_uint64(i);
    const auto refCnt = p_frame->get_uint64(i + sizeof(void*));

    if (!cache.Contains(instance)) {
      continue;
    }
    const auto handle = cache.Get(instance);

    if (handle->Expired()) {
      continue;
    }
    const auto target = handle->Lock();

    if (refCnt != reinterpret_cast<uint64_t>(target.refCount)) {
      continue;
    }
    const auto type = target->GetType()->GetName().ToString();
    auto result = Red::MakeHandle<MemorySearchHandle>(type, i);

    results.PushBack(result);
    i += SharedPtrBaseSize - 1;
  }
  std::ranges::sort(results,
                    [](const auto& a, const auto& b) -> bool {
                      return a->get_offset() < b->get_offset();
                    });
  return results;
}
}  // namespace RedMemoryDump