/*
 * SETUID Root Binary to set scaling governor from shell scripts.
 *
 * There's probably a better way to do this, but this is a quick and
 * dirty hack.
 *
 * As setuid binaries are dangerous, this program tries to do as
 * little as possibe.
 *
 * To build:
 *
 * gcc set_governor.c -o set_governor
 * sudo chown root:root set_governor
 * sudo chmod +s set_governor
 *
 * Use it like this: ./set_governor 0
 */

#include <stdio.h>

/*
 * There are multiple entries in this directory, but it's only
 * necessary to set one of them for the RPI CM4.
 */
const char *file = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor";

int main(int argc, char **argv) {
  FILE *fp;
  
  if (argc < 2) {
    fprintf(stderr, "invalid number of args\n");
    return 1;
  }

  if (!(fp = fopen(file, "w"))) {
    perror("Couldn't open file");
    return 1;
  }

  /*
   * There is only one argument, which must be either '0' or '1'.
   *
   * - 0 lowest-power governor
   * - 1 waking governor.
   * 
   */
  switch (*argv[1]) {
  case '0':
    fprintf(fp, "powersave");
    break;
  case '1':
    fprintf(fp, "schedutil");
    break;
  default:
    fprintf(stderr, "Invalid mode\n");
    break;
  }

  fclose(fp);
  
  return 0;
}
