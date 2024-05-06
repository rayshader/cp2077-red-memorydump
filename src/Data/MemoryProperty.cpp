#include "MemoryProperty.h"

namespace RedMemoryDump {

MemoryProperty::MemoryProperty()
    : name(""), offset(0), type_name(""), type_size(0) {}

MemoryProperty::MemoryProperty(const Red::CProperty* p_property)
    : name(p_property->name.ToString()),
      offset(p_property->valueOffset),
      type_name(p_property->type->GetName()),
      type_size(p_property->type->GetSize()) {}

Red::CString MemoryProperty::get_name() const {
  return name;
}

uint32_t MemoryProperty::get_offset() const {
  return offset;
}

Red::CName MemoryProperty::get_type_name() const {
  return type_name;
}

uint32_t MemoryProperty::get_type_size() const {
  return type_size;
}

}  // namespace RedMemoryDump