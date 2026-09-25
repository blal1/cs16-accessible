"""Reference parser for CS 1.6 bot .nav files (format from ReGameDLL nav_file.cpp). Used to validate the C++ loader."""
import struct, sys

def parse(path):
    d = open(path, "rb").read(); o = 0
    def rd(fmt):
        nonlocal o
        v = struct.unpack_from("<" + fmt, d, o); o += struct.calcsize("<" + fmt); return v
    magic, version = rd("II")
    assert magic == 0xFEEDFACE, hex(magic)
    if version >= 4: rd("I")
    places = []
    if version >= 5:
        (n,) = rd("H")
        for _ in range(n):
            (ln,) = rd("H"); places.append(d[o:o+ln].rstrip(b"\0").decode("latin-1")); o += ln
    (count,) = rd("I")
    areas = []
    for _ in range(count):
        aid, flags = rd("IB"); lo = rd("3f"); hi = rd("3f"); nez, swz = rd("2f")
        conns = []
        for _d in range(4):
            (c,) = rd("I"); conns.append(list(rd(f"{c}I")) if c else [])
        (hs,) = rd("B")
        if version == 1: o += hs * 12
        else: o += hs * (4 + 12 + 1)
        (ap,) = rd("B"); o += ap * (4 + 4 + 1 + 4 + 1)
        (enc,) = rd("I")
        if version < 3:
            for _e in range(enc):
                o += 8 + 24; (sc,) = rd("B"); o += sc * 16
            place = 0
        else:
            for _e in range(enc):
                o += 4 + 1 + 4 + 1; (sc,) = rd("B"); o += sc * 5
            place = rd("H")[0] if version >= 5 else 0
        areas.append(dict(id=aid, flags=flags, lo=lo, hi=hi, nez=nez, swz=swz, conns=conns,
                          place=places[place-1] if 0 < place <= len(places) else None))
    return version, places, areas, len(d) - o

if __name__ == "__main__":
    v, places, areas, rest = parse(sys.argv[1])
    print(f"version {v}, {len(areas)} areas, {len(places)} places, {rest} trailing bytes")
    print("places:", places)
    ids = {a['id'] for a in areas}
    bad = sum(1 for a in areas for c in a['conns'] for i in c if i not in ids)
    print("dangling connections:", bad, "| sample:", areas[0])
