// Standalone test: parse every stock map and path from each spawn to every objective.
#include "access_map.h"
#include <stdio.h>
#include <string>
#include <vector>

static std::vector<unsigned char> ReadAll(const std::string &path)
{
	std::vector<unsigned char> d;
	FILE *f = fopen(path.c_str(), "rb");
	if (!f) return d;
	fseek(f, 0, SEEK_END); d.resize(ftell(f)); fseek(f, 0, SEEK_SET);
	fread(d.data(), 1, d.size(), f); fclose(f);
	return d;
}

int main(int argc, char **argv)
{
	int failures = 0;
	for (int i = 2; i < argc; i++)
	{
		std::string base = std::string(argv[1]) + "/" + argv[i];
		std::vector<unsigned char> bsp = ReadAll(base + ".bsp"), nav = ReadAll(base + ".nav");
		AccessMap_LoadFromBuffers(bsp.data(), bsp.size(), nav.data(), nav.size());
		const std::vector<AccessObjective> &objs = AccessMap_Objectives();
		printf("%s: nav=%d objectives=%d\n", argv[i], AccessMap_HasNav(), (int)objs.size());
		for (const AccessObjective &from : objs)
		{
			if (from.type != OBJ_SPAWN_CT && from.type != OBJ_SPAWN_T) continue;
			for (const AccessObjective &to : objs)
			{
				if (&to == &from) continue;
				std::vector<AccessVec> wp;
				float len = AccessMap_FindPath(from.pos, to.pos, wp);
				printf("   %-24s -> %-28s %s %6.0f m, %3d points\n", from.name, to.name,
					len < 0 ? "UNREACHABLE" : "ok", len * 0.0254f, (int)wp.size());
				if (len < 0) failures++;
			}
		}
	}
	printf("unreachable paths: %d\n", failures);
	return 0;
}
