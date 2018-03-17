#include "discovery.h"
#include <iphlpapi.h>

#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "iphlpapi.lib")

void discovery_socket_init() {
  WSADATA wsa_data;
  int result = WSAStartup(MAKEWORD(2,2), &wsa_data);
}

void discovery_socket_close(int socket) {
  closesocket(socket);
}

int discovery_socket_set_non_blocking(int socket) {
  int mode = 1;
  int result = ioctlsocket(socket, FIONBIO, &mode);
  if (result != NO_ERROR) {
    return -1;
  }
  return 0;
}