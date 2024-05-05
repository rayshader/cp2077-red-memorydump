#include "MemoryProperty.h"

namespace RedMemoryDump {

MemoryProperty::MemoryProperty() : property(nullptr) {}

MemoryProperty::MemoryProperty(const Red::CProperty* p_property)
    : property(p_property) {}

Red::CString MemoryProperty::get_name() const {
  return property->name.ToString();
}

uint32_t MemoryProperty::get_offset() const {
  return property->valueOffset;
}

Red::CName MemoryProperty::get_type_name() const {
  return property->type->GetName();
}

uint32_t MemoryProperty::get_type_size() const {
  return property->type->GetSize();
}

}  // namespace RedMemoryDump