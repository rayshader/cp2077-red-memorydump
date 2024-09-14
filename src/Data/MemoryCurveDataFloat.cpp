#include "MemoryCurveDataFloat.h"

#include <utility>

namespace RedMemoryDump {

MemoryCurveDataFloat::MemoryCurveDataFloat(Red::CurveData<float>* p_curve) : curve(p_curve) {

}

Red::CString MemoryCurveDataFloat::get_type_name() const {
  return curve->valueType->GetName().ToString();
}

uint32_t MemoryCurveDataFloat::get_size() const {
  return curve->GetSize();
}

Red::DynArray<float> MemoryCurveDataFloat::get_points() const {
  Red::DynArray<float> points;

  for (size_t i = 0; i < curve->GetSize(); i++) {
    points.EmplaceBack(curve->GetPoint(i).point);
  }
  return points;
}

Red::DynArray<float> MemoryCurveDataFloat::get_values() const {
  Red::DynArray<float> values;

  for (size_t i = 0; i < curve->GetSize(); i++) {
    values.EmplaceBack(curve->GetPoint(i).value);
  }
  return values;
}

}  // namespace RedMemoryDump