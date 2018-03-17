#include "discovery.h"
#include <ifaddrs.h>

void discovery_socket_init() {
  // no-op
}

void discovery_socket_close(int socket) {
  close(socket);
}

int discovery_socket_set_non_blocking(int socket) {
  int mode = 1;
  return ioctl(socket, FIONBIO, &mode);
}

godot_variant discovery_socket_ifaddrs(const godot_gdnative_core_api_struct *api) {
  godot_variant ret;

  struct sockaddr_in *sa;
  struct ifaddrs *ifap, *ifa;

  godot_array addrs;
  api->godot_array_new(&addrs);

  getifaddrs(&ifap);
  for (ifa = ifap; ifa; ifa = ifa->ifa_next) {
    if (ifa->ifa_addr->sa_family == AF_INET) {
      sa = (struct sockaddr_in *)ifa->ifa_addr;

      // get address
      godot_string addr_string;
      api->godot_string_new(&addr_string);
      api->godot_string_parse_utf8(&addr_string, inet_ntoa(sa->sin_addr));

      // add to array
      godot_variant addr;
      api->godot_variant_new_string(&addr, &addr_string);
      api->godot_array_append(&addrs, &addr);

      // cleanup
      api->godot_string_destroy(&addr_string);
      api->godot_variant_destroy(&addr);
    }
  }
  freeifaddrs(ifap);

  // set return value
  api->godot_variant_new_array(&ret, &addrs);

  // cleanup
  api->godot_array_destroy(&addrs);
  return ret;
}
