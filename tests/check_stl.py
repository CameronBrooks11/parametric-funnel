"""Check a binary STL's solid count and bounding-box size.

usage: python3 tests/check_stl.py file.stl SOLIDS X Y Z

Fails unless the mesh has SOLIDS separate solids (triangles sharing a
vertex belong to the same solid) and its size is X by Y by Z mm, to
within 0.01 mm.
"""

import struct
import sys


def measure(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for i in range(n):
        v = struct.unpack_from("<9f", data, 84 + i * 50 + 12)
        corners = [v[0:3], v[3:6], v[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    solids = len({find(v) for v in parent})
    size = [max(p[i] for p in parent) - min(p[i] for p in parent) for i in range(3)]
    return solids, size


path = sys.argv[1]
want_solids = int(sys.argv[2])
want_size = [float(x) for x in sys.argv[3:6]]
solids, size = measure(path)
ok = solids == want_solids and all(abs(a - b) <= 0.01 for a, b in zip(size, want_size))
print(
    f"{path}: {solids} solids, {' x '.join(f'{s:.2f}' for s in size)} mm"
    + ("" if ok else f"; expected {want_solids} solids, {' x '.join(f'{s:.2f}' for s in want_size)} mm")
)
sys.exit(0 if ok else 1)
