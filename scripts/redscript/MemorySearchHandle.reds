module RedMemoryDump

public native class MemorySearchHandle {
  public native func GetType() -> String;
  public native func GetOffset() -> Uint64;
}