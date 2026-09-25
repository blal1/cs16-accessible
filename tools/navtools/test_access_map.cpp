// Standalone test: parse every stock map and path from each spawn to every objective.
#include "access_map.h"
#include <stdio.h>
#include <string.h>
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
	bool showPlaces = false;
	for (int i = 2; i < argc; i++)
	{
		if (!strcmp(argv[i], "-places"))
		{
			showPlaces = true;
			continue;
		}
		std::string base = std::string(argv[1]) + "/" + argv[i];
		std::vector<unsigned char> bsp = ReadAll(base + ".bsp"), nav = ReadAll(base + ".nav");
		AccessMap_LoadFromBuffers(bsp.data(), bsp.size(), nav.data(), nav.size());
		const std::vector<AccessObjective> &objs = AccessMap_Objectives();
		int features[3] = { 0, 0, 0 };
		for (const AccessFeature &f : AccessMap_Features())
			features[f.type]++;
		printf("%s: nav=%d objectives=%d ladders=%d doors=%d breakables=%d\n", argv[i], AccessMap_HasNav(),
			(int)objs.size(), features[FEAT_LADDER], features[FEAT_DOOR], features[FEAT_BREAKABLE]);
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
				// Places crossed along the way (argument -places): one line per change.
				if (showPlaces && from.type == OBJ_SPAWN_T)
				{
					int lastKey = -2;
					for (const AccessVec &w : wp)
					{
						char place[160];
						int key = -1;
						if (AccessMap_PlaceName(w, place, sizeof(place), &key) && key != lastKey)
						{
							printf("        %s\n", place);
							lastKey = key;
						}
					}
				}
			}
		}
	}
	printf("unreachable paths: %d\n", failures);
	return 0;
}
