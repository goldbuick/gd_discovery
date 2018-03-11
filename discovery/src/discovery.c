#include <gdnative_api_struct.gen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>

#define LIB_NAME "DISCOVERY"

#define MAX_BUFF_SIZE 102400

typedef struct user_data_struct {
  int dsocket;
} user_data_struct;

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;
const godot_gdnative_ext_nativescript_1_1_api_struct *nativescript_1_1_api = NULL;

GDCALLINGCONV void *discovery_constructor(godot_object *p_instance, void *p_method_data);
GDCALLINGCONV void discovery_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
godot_variant discovery_ping(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant discovery_pongs(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);

void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
  api = p_options->api_struct;

  // now find our extensions
  for (int i = 0; i < api->num_extensions; i++) {
    switch (api->extensions[i]->type) {
      case GDNATIVE_EXT_NATIVESCRIPT: {
        nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
        
        if (!nativescript_api->next)
          break;

        if (nativescript_api->next->version.major == 1 && nativescript_api->next->version.minor == 1) {
          nativescript_1_1_api = (const godot_gdnative_ext_nativescript_1_1_api_struct *) nativescript_api->next;
        }        
      }; break;
      default: break;
    };
  };
}

void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
  api = NULL;
  nativescript_api = NULL;
  nativescript_1_1_api = NULL;
}

void GDN_EXPORT godot_nativescript_init(void *p_handle) {
  godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

  godot_instance_create_func create = { NULL, NULL, NULL };
  create.create_func = &discovery_constructor;

  godot_instance_destroy_func destroy = { NULL, NULL, NULL };
  destroy.destroy_func = &discovery_destructor;

  nativescript_api->godot_nativescript_register_class(p_handle, LIB_NAME, "Reference", create, destroy);

  godot_instance_method ping = { NULL, NULL, NULL };
  ping.method = &discovery_ping;
  nativescript_api->godot_nativescript_register_method(p_handle, LIB_NAME, "ping", attributes, ping);
  if (nativescript_1_1_api) {
    godot_method_arg ping_args[3];

    api->godot_string_new(&ping_args[0].name);
    api->godot_string_new(&ping_args[0].hint_string);
    api->godot_string_parse_utf8(&ping_args[0].name, "host");
    ping_args[0].hint = GODOT_PROPERTY_HINT_NONE;
    ping_args[0].type = GODOT_VARIANT_TYPE_STRING;

    api->godot_string_new(&ping_args[1].name);
    api->godot_string_new(&ping_args[1].hint_string);
    api->godot_string_parse_utf8(&ping_args[1].name, "port");
    ping_args[1].hint = GODOT_PROPERTY_HINT_NONE;
    ping_args[1].type = GODOT_VARIANT_TYPE_INT;

    api->godot_string_new(&ping_args[2].name);
    api->godot_string_new(&ping_args[2].hint_string);
    api->godot_string_parse_utf8(&ping_args[2].name, "message");
    ping_args[2].hint = GODOT_PROPERTY_HINT_NONE;
    ping_args[2].type = GODOT_VARIANT_TYPE_STRING;

    nativescript_1_1_api->godot_nativescript_set_method_argument_information(p_handle, LIB_NAME, "ping", 3, ping_args);
  }

  godot_instance_method pongs = { NULL, NULL, NULL };
  pongs.method = &discovery_pongs;
  nativescript_api->godot_nativescript_register_method(p_handle, LIB_NAME, "pongs", attributes, pongs);
  if (nativescript_1_1_api) {
    nativescript_1_1_api->godot_nativescript_set_method_argument_information(p_handle, LIB_NAME, "pongs", 0, NULL);    
  }
}

GDCALLINGCONV void *discovery_constructor(godot_object *p_instance, void *p_method_data) {
  user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));

  // create socket
  user_data->dsocket = socket(AF_INET, SOCK_DGRAM, 0);
  if (user_data->dsocket < 0) {
    return user_data;
  }

  // set broadcast
  int broadcast = 1;
  if (setsockopt(user_data->dsocket, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof(broadcast)) == -1) {
    user_data->dsocket = -1;
    return user_data;
  }

  // bind to address
  struct sockaddr_in dsocket_addr;
  dsocket_addr.sin_family = AF_INET;
  dsocket_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  dsocket_addr.sin_port = htons(0);
  if (bind(user_data->dsocket, (struct sockaddr *)&dsocket_addr, sizeof(dsocket_addr)) == -1) {
    user_data->dsocket = -1;
    return user_data;
  }

  // set non-blocking
  int opts = fcntl(user_data->dsocket, F_GETFL);
  if (fcntl(user_data->dsocket, F_SETFL, opts | O_NONBLOCK) == -1) {
    close(user_data->dsocket);
    user_data->dsocket = -1;
    return user_data;
  }

  return user_data;
}

GDCALLINGCONV void discovery_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
  user_data_struct *user_data = (user_data_struct *)p_user_data;
  
  if (user_data && user_data->dsocket >= 0) {
    close(user_data->dsocket);
  }

  api->godot_free(p_user_data);
}

godot_variant discovery_ping(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args) {
  godot_variant ret;
  user_data_struct *user_data = (user_data_struct *)p_user_data;

  // failed to setup socket
  if (!user_data || user_data->dsocket < 0) {
    api->godot_variant_new_nil(&ret);
    return ret;
  }

  // failed to pass correct args
  if (p_num_args != 3 ||
    api->godot_variant_get_type(p_args[0]) != GODOT_VARIANT_TYPE_STRING ||
    api->godot_variant_get_type(p_args[1]) != GODOT_VARIANT_TYPE_INT ||
    api->godot_variant_get_type(p_args[2]) != GODOT_VARIANT_TYPE_STRING
  ) {
    api->godot_variant_new_nil(&ret);
    return ret;
  }

  // convert host into ascii string
  godot_string host_string = api->godot_variant_as_string(p_args[0]);
  godot_char_string host_ascii = api->godot_string_ascii(&host_string);
  struct hostent *host = gethostbyname(api->godot_char_string_get_data(&host_ascii));
  api->godot_char_string_destroy(&host_ascii);

  // build target address
  struct sockaddr_in ping_addr;
  ping_addr.sin_family = AF_INET;
  ping_addr.sin_port = htons(api->godot_variant_as_int(p_args[1]));
  memcpy((char *)&ping_addr.sin_addr.s_addr, host->h_addr_list[0], host->h_length);  

  // convert message into ascii string
  godot_string message_string = api->godot_variant_as_string(p_args[2]);
  godot_char_string message_ascii = api->godot_string_ascii(&message_string);
  int result = sendto(
    user_data->dsocket,
    api->godot_char_string_get_data(&message_ascii),
    api->godot_char_string_length(&message_ascii),
    0,
    (struct sockaddr*)&ping_addr,
    sizeof(struct sockaddr_in));
  api->godot_char_string_destroy(&message_ascii);

  api->godot_variant_new_bool(&ret, result < 0 ? false : true);
  return ret;
}

godot_variant discovery_pongs(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args) {
  godot_variant ret;
  user_data_struct *user_data = (user_data_struct *)p_user_data;

  // failed to setup socket
  if (!user_data || user_data->dsocket < 0) {
    api->godot_variant_new_nil(&ret);
    return ret;
  }

  char buff[MAX_BUFF_SIZE+1];
  memset(buff, 0, sizeof(buff));
  ssize_t bytes = recvfrom(
    user_data->dsocket,
    buff,
    MAX_BUFF_SIZE,
    0,
    NULL,
    NULL);

  if (bytes < 0) {
    api->godot_variant_new_nil(&ret);
    return ret;
  }

  godot_string message;
  api->godot_string_new(&message);
  api->godot_string_parse_utf8_with_len(&message, buff, bytes);
  api->godot_variant_new_string(&ret, &message);
  api->godot_string_destroy(&message);

  return ret;
}
