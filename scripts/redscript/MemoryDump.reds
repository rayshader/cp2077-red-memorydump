module RedMemoryDump

public native class MemoryDump {

  public static native func TrackSerializable(object: ref<ISerializable>) -> ref<MemoryTarget>;
  public static native func TrackAddress(name: String, type: CName, address: Uint64, opt size: Uint32) -> ref<MemoryTarget>;

}