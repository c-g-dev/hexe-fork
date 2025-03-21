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
