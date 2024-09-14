module RedMemoryDump

public native class MemoryCurveDataFloat {

  public native func GetTypeName() -> String;
  public native func GetSize() -> Uint32;

  public native func GetPoints() -> array<Float>;
  public native func GetValues() -> array<Float>;

}