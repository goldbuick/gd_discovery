#pragma once

#include <gdnative_api_struct.gen.h>

#if defined(_MSC_VER)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <basetsd.h>
typedef SSIZE_T ssize_t;

#else

#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>

#endif

void discovery_socket_init();
void discovery_socket_close(int socket);
int discovery_socket_set_non_blocking(int socket);
godot_variant discovery_socket_ifaddrs(const godot_gdnative_core_api_struct *api);

