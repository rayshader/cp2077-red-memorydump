#include "MemorySearchHandle.h"

RedMemoryDump::MemorySearchHandle::MemorySearchHandle(const Red::CString& p_type,
                                                      uint64_t p_offset) : type(p_type), offset(p_offset) {
}

Red::CString RedMemoryDump::MemorySearchHandle::get_type() const {
    return type;
}

uint64_t RedMemoryDump::MemorySearchHandle::get_offset() const {
    return offset;
}
