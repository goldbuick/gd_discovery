clang -std=c11 -fPIC -c -I./godot_headers ./src/discovery.c -o ./build/discovery.obj -arch i386 -arch x86_64
clang -std=c11 -fPIC -c -I./godot_headers ./src/discovery_posix.c -o ./build/discovery_posix.obj -arch i386 -arch x86_64
clang -dynamiclib ./build/*.obj -o ./project/network/libdiscovery.dylib -arch i386 -arch x86_64