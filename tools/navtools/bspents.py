"""Reference extractor for GoldSrc BSP v30 objectives (entity lump + brush model bounds)."""
import struct, sys, re
OBJ = ("func_bomb_target", "info_bomb_target", "func_hostage_rescue", "info_hostage_rescue", "hostage_entity",
       "func_buyzone", "info_player_start", "info_player_deathmatch", "func_vip_safetyzone", "func_escapezone", "info_vip_start")
def parse(path):
    d = open(path, "rb").read()
    ver = struct.unpack_from("<i", d, 0)[0]
    lumps = [struct.unpack_from("<ii", d, 4 + i * 8) for i in range(15)]
    eo, el = lumps[0]; mo, ml = lumps[14]
    ents = [dict(re.findall(r'"([^"]*)"\s*"([^"]*)"', b)) for b in re.findall(r"\{([^}]*)\}", d[eo:eo+el].decode("latin-1"))]
    models = [struct.unpack_from("<9f", d, mo + i * 64) for i in range(ml // 64)]
    out = []
    for e in ents:
        c = e.get("classname")
        if c not in OBJ: continue
        if e.get("model", "").startswith("*"):
            m = models[int(e["model"][1:])]; pos = tuple((m[i] + m[i+3]) / 2 for i in range(3))
        else:
            pos = tuple(float(x) for x in e.get("origin", "0 0 0").split())
        out.append((c, tuple(round(p) for p in pos)))
    return ver, out
if __name__ == "__main__":
    ver, out = parse(sys.argv[1]); print("bsp", ver)
    from collections import Counter; print(Counter(c for c, _ in out))
    for c, p in out:
        if not c.startswith("info_player"): print(c, p)
