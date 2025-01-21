module RedMemoryDump

public native abstract class MemoryTargetWeakHandle extends MemoryTarget {

  public native func SearchHandles(frame: ref<MemoryFrame>, opt force: Bool) -> array<ref<MemorySearchHandle>>;

}