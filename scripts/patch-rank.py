#!/usr/bin/env python3
import pathlib
import sys

RANK_OFFSET = 0x12FEF
OLD_RANK = b"\xba\x00\x01\x00\x00"
NEW_RANK = b"\xba\xff\xff\xff\x7f"


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: patch-rank.py <libgstlibav.dylib>", file=sys.stderr)
        return 64

    plugin = pathlib.Path(sys.argv[1])
    data = bytearray(plugin.read_bytes())
    current = bytes(data[RANK_OFFSET:RANK_OFFSET + 5])
    if current == NEW_RANK:
        print("rank already patched")
        return 0
    if current != OLD_RANK:
        print(
            f"unexpected rank bytes at {RANK_OFFSET:#x}: {current.hex()}",
            file=sys.stderr,
        )
        return 1

    data[RANK_OFFSET:RANK_OFFSET + 5] = NEW_RANK
    plugin.write_bytes(data)
    print("patched FFmpeg H.264 decoder rank: 256 -> 2147483647")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

