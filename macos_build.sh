clang -std=c11 -fPIC -c -I./godot_headers ./discovery/src/discovery.c -o ./build/discovery.os -arch i386 -arch x86_64
clang -dynamiclib ./build/discovery.os -o ./discovery/bin/libdiscovery.dylib -arch i386 -arch x86_64