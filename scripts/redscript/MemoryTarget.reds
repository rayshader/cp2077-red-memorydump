module RedMemoryDump

public native class MemoryTarget {

  public native func GetName() -> String;
  public native func GetType() -> CName;

  public native func GetSize() -> Uint32;
  public native func SetSize(size: Uint32) -> Void;
  public native func IsSizeLocked() -> Bool;

  public native func GetAddress() -> Uint64;
  public native func GetProperties() -> array<ref<MemoryProperty>>;

  public native func GetFrames() -> array<ref<MemoryFrame>>;
  public native func GetLastFrame() -> ref<MemoryFrame>;

  public native func Capture() -> ref<MemoryFrame>;
  public native func RemoveFrame(index: Int32) -> Void;

}