#ifndef __utils_h__
#define __utils_h__

#include <sys/types.h>
#include <sys/sysinfo.h>

long long getVmUsed() {
  struct sysinfo memInfo;
  sysinfo (&memInfo);
  long long virtualMemUsed = memInfo.totalram - memInfo.freeram;
  //Add other values in next statement to avoid int overflow on right hand side...
  virtualMemUsed += memInfo.totalswap - memInfo.freeswap;
  virtualMemUsed *= memInfo.mem_unit;

  return virtualMemUsed;
}

#endif
