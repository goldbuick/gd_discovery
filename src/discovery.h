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

#endif

void discovery_socket_init();
void discovery_socket_close(int socket);
int discovery_socket_set_non_blocking(int socket);
godot_variant discovery_ifaddrs(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
