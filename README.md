The intention here is to change the format of the output file to contain its own images and scripts so the prefabs are truly portable and largely don't need to be contextual.

MyObject.prefab
```
/res
/src
prefab.json
```

Then just include this in the heaps res folder, fully self contained.

Scripts can be trivially imported via macros, the main question will be the api by which they will be created. Perhaps something like:

```
var obj = Prefabs.MyObject(...); // some.synthetic.package.internal.MyObject extends h2d.Object;
```

Also not sure if we would want the scripts to be full Object classes or just some coroutines exposures that would get parsed into a class. What we WON'T do is use scripting like hscript because that would kill performance. These prefabs will need to be COMPILED.

Ideally we would add a [Test] button which will create an entire heaps project, inject the prefab, run the build, and then launch the hashlink to see the entire thing in action.

## Current State
Fully functional as far as I can tell. Will need to change the "type" output to match the fully qualified classes, as is the design of the corresponding Heaps Prefab library I have parallel to this. 

