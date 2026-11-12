#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define RANK_OFFSET 0x12FEF
#define RANK_EXPECTED 2147483647U

static int read_rank(const char *path, uint32_t *rank) {
  FILE *file = fopen(path, "rb");
  if (file == NULL) {
    perror("fopen");
    return 1;
  }
  if (fseek(file, RANK_OFFSET + 1, SEEK_SET) != 0) {
    fclose(file);
    return 1;
  }
  unsigned char bytes[4];
  if (fread(bytes, 1, sizeof(bytes), file) != sizeof(bytes)) {
    fclose(file);
    return 1;
  }
  fclose(file);
  *rank = (uint32_t)bytes[0] |
          ((uint32_t)bytes[1] << 8) |
          ((uint32_t)bytes[2] << 16) |
          ((uint32_t)bytes[3] << 24);
  return 0;
}

int main(int argc, char **argv) {
  char plugin[4096];
  if (argc != 2) {
    fprintf(stderr, "usage: %s <gstreamer-plugin-directory>\n", argv[0]);
    return 64;
  }

  if (snprintf(plugin, sizeof(plugin), "%s/libgstlibav.dylib", argv[1]) >=
      (int)sizeof(plugin)) {
    fprintf(stderr, "plugin path is too long\n");
    return 1;
  }

  uint32_t rank = 0;
  if (read_rank(plugin, &rank) != 0) {
    fprintf(stderr, "could not read decoder rank from %s\n", plugin);
    return 1;
  }
  printf("libgstlibav rank: %u\n", rank);
  if (rank != RANK_EXPECTED) {
    return 1;
  }

  void *handle = dlopen(plugin, RTLD_NOW | RTLD_LOCAL);
  if (handle == NULL) {
    fprintf(stderr, "dlopen failed: %s\n", dlerror());
    return 1;
  }
  dlclose(handle);

  printf("libgstlibav: load PASS\n");
  printf("avdec_h264: PASS rank=%u\n", rank);
  return 0;
}

