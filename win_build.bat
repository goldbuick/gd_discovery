cl /Fo.\build\discovery.obj /c .\src\discovery.c /nologo -EHsc -DNDEBUG /MD /I. /I.\godot_headers
link /nologo /dll /out:.\project\network\libdiscovery.dll /implib:.\project\network\libdiscovery.lib .\build\discovery.obj
