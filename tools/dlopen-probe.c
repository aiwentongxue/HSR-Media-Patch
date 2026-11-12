#include <dlfcn.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s <mach-o-bundle-or-dylib>\n", argv[0]);
    return 64;
  }

  void *handle = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
  if (handle == NULL) {
    fprintf(stderr, "dlopen failed: %s\n", dlerror());
    return 1;
  }

  printf("dlopen succeeded: %s\n", argv[1]);
  dlclose(handle);
  return 0;
}

