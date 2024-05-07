module RedMemoryDump

public native class MemoryProperty {

  public native func GetName() -> String;
  public native func GetOffset() -> Uint32;

  public native func GetTypeName() -> CName;
  public native func GetTypeSize() -> Uint32;

}