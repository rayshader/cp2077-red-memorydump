module RedMemoryDump

public native class MemoryFrame {

  public native func GetSize() -> Uint32;
  public native func GetBuffer() -> array<Uint8>;
  public native func GetBufferView() -> array<String>;

  public native func GetBool(offset: Uint32) -> Bool;
  public native func GetInt32(offset: Uint32) -> Int32;
  public native func GetInt64(offset: Uint32) -> Int64;
  public native func GetUint32(offset: Uint32) -> Uint32;
  public native func GetUint64(offset: Uint32) -> Uint64;
  public native func GetFloat(offset: Uint32) -> Float;
  public native func GetDouble(offset: Uint32) -> Double;
  public native func GetString(offset: Uint32) -> String;
  public native func GetCName(offset: Uint32) -> CName;

  public native func GetFixedPoint(offset: Uint32) -> Float;
  public native func GetRectF(offset: Uint32) -> RectF;
  public native func GetPoint(offset: Uint32) -> Point;
  public native func GetPoint3D(offset: Uint32) -> Point3D;
  public native func GetBox(offset: Uint32) -> Box;
  public native func GetQuad(offset: Uint32) -> Quad;

  public native func GetVector2(offset: Uint32) -> Vector2;
  public native func GetVector3(offset: Uint32) -> Vector3;
  public native func GetVector4(offset: Uint32) -> Vector4;
  public native func GetMatrix(offset: Uint32) -> Matrix;
  public native func GetTransform(offset: Uint32) -> Transform;
  public native func GetQsTransform(offset: Uint32) -> QsTransform;
  public native func GetQuaternion(offset: Uint32) -> Quaternion;
  public native func GetEulerAngles(offset: Uint32) -> EulerAngles;
  public native func GetWorldPosition(offset: Uint32) -> WorldPosition;
  public native func GetWorldTransform(offset: Uint32) -> WorldTransform;

  public native func GetColor(offset: Uint32) -> Color;
  public native func GetColorBalance(offset: Uint32) -> ColorBalance;
  public native func GetHDRColor(offset: Uint32) -> HDRColor;

  public native func GetCurveDataFloat(offset: Uint32) -> ref<MemoryCurveDataFloat>;

}