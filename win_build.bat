mkdir build
cl /Fobuild\discovery.obj /c src\discovery.c /nologo -EHsc -DNDEBUG /MD /I. /Igodot_headers
cl /Fobuild\discovery_win32.obj /c src\discovery_win32.c /nologo -EHsc -DNDEBUG /MD /I. /Igodot_headers
link /nologo /dll /out:project\network\libdiscovery.dll /implib:project\network\libdiscovery.lib build\*.obj
