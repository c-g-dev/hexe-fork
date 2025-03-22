import haxe.Json;
import prefab.Prefab;

using StringTools;

class File {
    public var directory:String = "";
    public var filepath:String = "";

    public var filename:String = "untitled.cprefab";
    public var defaultName:String = "untitled.cprefab";
    public var project:String = "untitled";

    var empty:String = "";
    var temp:String = "";

	var compositePrefab:CompositePrefab = new CompositePrefab();

    var editor:Editor;

    public function new() {
        editor = Editor.ME;
    }

    public function openfile(title:String, name:String, extensions:Array<String>) {
        var options:hl.UI.FileOptions = { };
        options.title = title;
        options.filters = [{name: name, exts: extensions}];
        
        var allowTimeout = hxd.System.allowTimeout;
        hxd.System.allowTimeout = false;

        var file = hl.UI.loadFile(options);
        hxd.System.allowTimeout = allowTimeout;

        return file;
    }

    public function open() {
        var file = openfile("Open File", "Composite Prefab Files", ["cprefab"]); // Updated extension
        if (file == null) return;


        var bytes = sys.io.File.getBytes(file);
        this.compositePrefab = CompositePrefab.fromZipBytes(bytes);
        if (compositePrefab.prefab == null) return;


        editor.clear();

        directory = getDirectory(file);
        filename = haxe.io.Path.withoutDirectory(file);
        filepath = file;

        var scene:Data = compositePrefab.prefab;

        for (entry in scene.children) {
            var prefab:Prefab = null;


            if (entry.type == "object") {
                var item = new prefab.Object();
                if (entry.smooth != null) item.smooth = Std.int(entry.smooth);
                prefab = item;
            }

            if (entry.type == "bitmap") {
                var tile:h2d.Tile;

                if (entry.atlas != null) {
                    var atlasPath = entry.path;
                    var atlasBytes = compositePrefab.getResource(atlasPath);
                    var imagePath = atlasPath.replace(".atlas", ".png");
                    var imageBytes = compositePrefab.getResource(imagePath);
                    var imageTile = hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
                    var atlasContent = atlasBytes.toString();
                    var atlas = new Texture.Atlas(entry.atlas, atlasContent, imageTile);
                    Assets.atlas.set(entry.atlas, atlas);
                    tile = atlas.get(entry.src);
                } else {
                    var imageBytes = compositePrefab.getResource(entry.src);
                    tile = hxd.res.Any.fromBytes(entry.src, imageBytes).toImage().toTile();
                }

                var item = new prefab.Bitmap();

                if (entry.atlas != null) {
                    item.atlas = entry.atlas;
                    item.path = entry.path;
                }
                
                item.src = entry.src;
                item.tile = tile;

                if (entry.width != null) item.width = Std.int(entry.width);
                if (entry.height != null) item.height = Std.int(entry.height);
                if (entry.smooth != null) item.smooth = Std.int(entry.smooth);
                if (entry.dx != null) item.anchor = entry.dx + "," + entry.dy;

                prefab = item;
            }

            if (entry.type == "scalegrid") {
                var tile:h2d.Tile;

                if (entry.atlas != null) {
                    var atlasPath = entry.path;
                    var atlasBytes = compositePrefab.getResource(atlasPath);
                    var imagePath = atlasPath.replace(".atlas", ".png");
                    var imageBytes = compositePrefab.getResource(imagePath);
                    var imageTile = hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
                    var atlasContent = atlasBytes.toString();
                    var atlas = new Texture.Atlas(entry.atlas, atlasContent, imageTile);
                    Assets.atlas.set(entry.atlas, atlas);
                    tile = atlas.get(entry.src);
                } else {
                    var imageBytes = compositePrefab.getResource(entry.src);
                    tile = hxd.res.Any.fromBytes(entry.src, imageBytes).toImage().toTile();
                }

                var item = new prefab.ScaleGrid();

                if (entry.atlas != null) {
                    item.atlas = entry.atlas;
                    item.path = entry.path;
                }
                
                item.src = entry.src;
                item.tile = tile;

                item.width = Std.int(entry.width);
                item.height = Std.int(entry.height);

                if (entry.range != null) item.border = Std.int(entry.range);
                if (entry.smooth != null) item.smooth = Std.int(entry.smooth);

                prefab = item;
            }

            if (entry.type == "anim") {
                var item = new prefab.Anim();

                if (entry.atlas != null) {
                    var atlasPath = entry.path;
                    var atlasBytes = compositePrefab.getResource(atlasPath);
                    var imagePath = atlasPath.replace(".atlas", ".png");
                    var imageBytes = compositePrefab.getResource(imagePath);
                    var imageTile = hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
                    var atlasContent = atlasBytes.toString();
                    var atlas = new Texture.Atlas(entry.atlas, atlasContent, imageTile);
                    Assets.atlas.set(entry.atlas, atlas);
                    item.atlas = entry.atlas;
                    item.path = entry.path;
                } else {
                    var imageBytes = compositePrefab.getResource(entry.src);
                    var tile = hxd.res.Any.fromBytes(entry.src, imageBytes).toImage().toTile();
                    item.row = Std.int(entry.width);
                    item.col = Std.int(entry.height);
                    item.tile = tile;
                }

                if (entry.smooth != null) item.smooth = Std.int(entry.smooth);

                item.speed = entry.speed;
                item.loop = entry.loop;
                item.src = entry.src;

                prefab = item;
            }

            if (entry.type == "text") {
                var item = new prefab.Text();

                if (entry.font != null) {
                    var fontBytes = compositePrefab.getResource(entry.src);
					loadFont(entry.src, compositePrefab);
                    item.font = entry.font; // Assume this method exists
                    item.src = entry.src;
                }

                if (entry.color != null) item.color = StringTools.hex(entry.color, 6);
                if (entry.width != null) item.letterSpacing = Std.int(entry.width);
                if (entry.height != null) item.lineSpacing = Std.int(entry.height);
                if (entry.range != null) item.maxWidth = Std.int(entry.range);
                if (entry.align != null) item.align = Std.int(entry.align);

                item.text = entry.text ?? "";

                prefab = item;
            }

            if (entry.type == "interactive") {
                var item = new prefab.Interactive();
                if (entry.smooth != null) item.smooth = entry.smooth;
                item.width = Std.int(entry.width);
                item.height = Std.int(entry.height);
                prefab = item;
            }
            if (entry.type == "graphics") {
                var item = new prefab.Graphics();
                if (entry.color != null) item.color = StringTools.hex(entry.color, 6);
                if (entry.width != null) item.width = Std.int(entry.width);
                if (entry.height != null) item.height = Std.int(entry.height);
                prefab = item;
            }
            if (entry.type == "mask") {
                var item = new prefab.Mask();
                item.width = Std.int(entry.width);
                item.height = Std.int(entry.height);
                prefab = item;
            }

            if (entry.type == "prefab") {
                var nestedBytes = compositePrefab.getResource(entry.src);
                var nestedCompositePrefab = CompositePrefab.fromZipBytes(nestedBytes);
                var item = loadPrefab(nestedCompositePrefab);

                if (entry.field != null) {
                    for (field in entry.field) {
                        if (field.type == "bitmap") item.setBitmap(field.name, field.value);
                        if (field.type == "text") item.setText(field.name, field.value);
                    }
                }

                item.src = entry.src;
                prefab = item;
            }

            if (prefab == null) continue;

            editor.setUID(entry.name);

            prefab.name = entry.name;
            prefab.object.name = prefab.name;
            prefab.link = entry.link;

            prefab.object.x = entry.x ?? 0;
            prefab.object.y = entry.y ?? 0;
            prefab.object.scaleX = entry.scaleX ?? 1;
            prefab.object.scaleY = entry.scaleY ?? 1;
            prefab.object.rotation = entry.rotation ?? 0;

            if (entry.blendMode != null) {
                prefab.object.blendMode = haxe.EnumTools.createByName(h2d.BlendMode, entry.blendMode);
            }

            prefab.object.alpha = entry.alpha ?? 1;
            prefab.object.visible = entry.visible ?? true;

            if (entry.parent == null || entry.parent == "root") {
                editor.scene.addChild(prefab.object);
            } else {
                var parent = editor.children.get(entry.parent);
                parent.object.addChild(prefab.object);
            }

            editor.add(prefab.object, prefab, false);
        }

        editor.onScene();
    }

	public function getPrefab(src:String) {
		var data = this.compositePrefab.findPrefab(src);
		return loadPrefab(data);
	}
	

    public function save(?newFile:Bool = false) {

        var children = [];
        for (object in editor.hierarchy) {
            var prefab = editor.children.get(object.name);
            children.push(prefab.serialize());
        }

        var data:Dynamic = {};
        data.name = "prefab";
        data.type = "prefab";
        data.children = children;


        var compositePrefab = new CompositePrefab(data);
        var resources = new Map<String, Bool>();
        collectResources(data, resources);

        for (resourceName in resources.keys()) {
            var fullPath = directory + resourceName;
            if (sys.FileSystem.exists(fullPath)) {
                var bytes = sys.io.File.getBytes(fullPath);
                compositePrefab.addResource(resourceName, bytes);
            } else {
                trace("Warning: Resource not found: " + fullPath);
            }
        }

        var zipBytes = compositePrefab.toZipBytes();


        if (filepath != "" && !newFile) {
            sys.io.File.saveBytes(filepath, zipBytes);
            return true;
        } else {
            var options:hl.UI.FileOptions = { };
            options.title = "Save File";
            options.fileName = filename;
            options.filters = [{name: "cprefab", exts: ["cprefab"]}]; // Updated extension
            
            var allowTimeout = hxd.System.allowTimeout;
            hxd.System.allowTimeout = false;

            var file = hl.UI.saveFile(options);
            hxd.System.allowTimeout = allowTimeout;

            if (file != null) {
                directory = getDirectory(file);
                filepath = haxe.io.Path.withoutExtension(file) + ".cprefab";
                filename = haxe.io.Path.withoutDirectory(filepath);
                
                sys.io.File.saveBytes(filepath, zipBytes);
                editor.onScene();
                return true;
            }
        }
        return false;
    }


    function collectResources(data:Data, resources:Map<String, Bool>) {
        for (child in data.children) {
            if (child.type == "bitmap" || child.type == "scalegrid" || child.type == "anim") {
                if (child.atlas != null) {
                    resources.set(child.path, true);
                    resources.set(child.path.replace(".atlas", ".png"), true);
                } else {
                    resources.set(child.src, true);
                }
            } else if (child.type == "text" && child.font != null) {
                resources.set(child.src, true);

            } else if (child.type == "prefab") {
                resources.set(child.src, true);
            }
            if (child.children != null) {
                collectResources(child, resources);
            }
        }
    }

	public function openTexture(type:String = "bitmap") {
		if (editor.texture.atlas == null) {
			openAtlas(type); // Initial atlas load from filesystem
			return;
		}
	
		function onSelect(name:String) {
			var atlas = editor.texture.atlas;
	
			var prefab:prefab.Drawable = null;
			switch (type) {
				case "bitmap":
					prefab = new prefab.Bitmap();
				case "scalegrid":
					prefab = new prefab.ScaleGrid();
				case "anim":
					prefab = new prefab.Anim();
					prefab.atlas = atlas.name;
					prefab.image = name;
				default:
			}
	
			prefab.name = editor.getUID(prefab.type);
			prefab.object.name = prefab.name;
	
			prefab.tile = atlas.get(name);
			prefab.atlas = atlas.name;
			prefab.path = Assets.atlasPath.get(atlas.name); // Path to atlas file (e.g., "res/atlas.atlas")
			prefab.src = name; // Name of the texture within the atlas
	
			editor.scene.addChild(prefab.object);
			editor.add(prefab.object, prefab);
	

			editor.texture.onSelect = null;
		}
	
		editor.texture.onSelect = onSelect;
		editor.texture.open();
	}


    public function openBitmap(type:String = "bitmap") {
        var file = openfile("Open Image", "Image Files", ["png", "jpeg", "jpg"]);
        if (file == null) return;

        var data = sys.io.File.getBytes(file);
        var tile = hxd.res.Any.fromBytes(file, data).toImage().toTile();
        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

        var prefab:prefab.Drawable = null;
        switch (type) {
            case "bitmap":
                prefab = new prefab.Bitmap();
            case "scalegrid":
                prefab = new prefab.ScaleGrid();
            case "anim":
                prefab = new prefab.Anim();
            default:
        }

        prefab.tile = tile;
        prefab.src = getPath(file); // Relative path, embedded during save()

        prefab.name = editor.getUID(prefab.type);
        prefab.object.name = prefab.name;

        editor.scene.addChild(prefab.object);
        editor.add(prefab.object, prefab);
    }


    public function openPrefab() {
        var file = openfile("Open File", "Composite Prefab Files", ["cprefab"]);
        if (file == null) return;

        var bytes = sys.io.File.getBytes(file);
        var compositePrefab = CompositePrefab.fromZipBytes(bytes);

        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();
        var path = directory != empty ? directory : getDirectory(file);

        var prefab = loadPrefab(compositePrefab);

        prefab.name = editor.getUID(prefab.type);
        prefab.object.name = prefab.name;
        prefab.link = name;
        prefab.src = getPath(file); // Relative path to .cprefab

        editor.scene.addChild(prefab.object);
        editor.add(prefab.object, prefab);
    }


    public function loadPrefab(compositePrefab:CompositePrefab):prefab.Linked {
        var res:Data = compositePrefab.prefab;
        var hierarchy:Map<String, h2d.Object> = new Map();
        var prefab = new prefab.Linked();

        for (entry in res.children) {
            var object:h2d.Object = null;

            if (entry.type == "object") {
                var item = new h2d.Object();
                hierarchy.set(entry.name, item);
                object = item;
            }
            if (entry.type == "bitmap") {
                var tile:h2d.Tile;

                if (entry.atlas != null) {
                    var atlasBytes = compositePrefab.getResource(entry.path);
                    var imagePath = entry.path.replace(".atlas", ".png");
                    var imageBytes = compositePrefab.getResource(imagePath);
                    var imageTile = hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
                    var atlasContent = atlasBytes.toString();
                    var atlas = new Texture.Atlas(entry.atlas, atlasContent, imageTile);
                    Assets.atlas.set(entry.atlas, atlas);
                    tile = atlas.get(entry.src);
                } else {
                    var bytes = compositePrefab.getResource(entry.src);
                    tile = hxd.res.Any.fromBytes(entry.src, bytes).toImage().toTile();
                }

                var item = new h2d.Bitmap(tile);

                if (entry.width != null) item.width = entry.width;
                if (entry.height != null) item.height = entry.height;
                if (entry.smooth != null) item.smooth = entry.smooth == 1;
                if (entry.dx != null) item.tile.setCenterRatio(entry.dx, entry.dy);

                if (entry.atlas != null) {
                    prefab.bitmap.set(entry.link, item);
                    prefab.field.set(entry.link, { name: entry.link, type: "bitmap", data: entry.atlas, original: entry.src, value: entry.src });
                }

                hierarchy.set(entry.name, item);
                object = item;
            }
            if (entry.type == "prefab") {
                var nestedBytes = compositePrefab.getResource(entry.src);
                var nestedCompositePrefab = CompositePrefab.fromZipBytes(nestedBytes);
                var item = loadPrefab(nestedCompositePrefab);
                object = item.object;
            }


            if (object == null) continue;

            object.name = entry.link;
            object.x = entry.x ?? 0;
            object.y = entry.y ?? 0;
            object.scaleX = entry.scaleX ?? 1;
            object.scaleY = entry.scaleY ?? 1;
            object.rotation = entry.rotation ?? 0;

            if (entry.blendMode != null) object.blendMode = haxe.EnumTools.createByName(h2d.BlendMode, entry.blendMode);
            object.visible = entry.visible ?? true;
            object.alpha = entry.alpha ?? 1;

            var p:h2d.Object = entry.parent != null ? hierarchy.get(entry.parent) : prefab.object;
            p.addChild(object);
        }

        var bound = prefab.object.getBounds();
        prefab.width = bound.width;
        prefab.height = bound.height;
        prefab.x = bound.getCenter().x - bound.width * 0.5;
        prefab.y = bound.getCenter().y - bound.height * 0.5;

        return prefab;
    }

	public function openAtlas(type:String = "bitmap") {
        var file = openfile("Open Texture Atlas", "Texture Atlas Files", ["atlas"]);
        if (file == null) return;

        var folder = haxe.io.Path.directory(file).split("\\").join("/") + "/";
        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

        if (Assets.atlas.exists(name)) return;


        var atlasData = sys.io.File.getBytes(file);
        var imagePath = folder + name + ".png";
        var imageData = sys.io.File.getBytes(imagePath);
        var tile = hxd.res.Any.fromBytes(imagePath, imageData).toImage().toTile();
        var entry = atlasData.toString();
        var path = getPath(file); // Relative path for atlas

        var atlas = new Texture.Atlas(name, entry, tile);

        editor.addAtlas(atlas, name, path);
        openTexture(type);
    }


    public function loadAtlas(file:String, compositePrefab:CompositePrefab) {
        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();

        if (Assets.atlas.exists(name)) return;


        var atlasBytes = compositePrefab.getResource(file);
        var imagePath = file.replace(".atlas", ".png");
        var imageBytes = compositePrefab.getResource(imagePath);
        var tile = hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
        var entry = atlasBytes.toString();
        var path = file; // Use the resource name directly

        var atlas = new Texture.Atlas(name, entry, tile);

        editor.addAtlas(atlas, name, path);
    }


    public function openFont():Null<String> {
        var file = openfile("Open Font", "Font Files", ["fnt"]);
        if (file == null) return null;

        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();
        var font = getFont(file); // Load from filesystem initially
        var path = getPath(file); // Relative path

        editor.addFont(font, name, path);
        return name;
    }


    public function loadFont(file:String, compositePrefab:CompositePrefab) {
        var name = haxe.io.Path.withoutDirectory(file).split(".").shift();


        var fontBytes = compositePrefab.getResource(file);
        var font = getFontFromBytes(file, fontBytes,compositePrefab); // Updated to use bytes
        var path = file; // Use resource name directly

        editor.addFont(font, name, path);
    }


    public function getFont(file:String) {
        function resolveFontImage(path:String):h2d.Tile {
            var data = sys.io.File.getBytes(path);
            return hxd.res.Any.fromBytes(path, data).toImage().toTile();
        }

        var font:h2d.Font = hxd.fmt.bfnt.FontParser.parse(sys.io.File.getBytes(file), file, resolveFontImage);
        return font;
    }


    public function getFontFromBytes(file:String, fontBytes:haxe.io.Bytes, compositePrefab:CompositePrefab) {
        function resolveFontImage(path:String):h2d.Tile {

            var imagePath = haxe.io.Path.withoutExtension(file) + ".png";
            var imageBytes = compositePrefab.getResource(imagePath); // Requires compositePrefab in scope
            if (imageBytes == null) throw "Font image not found: " + imagePath;
            return hxd.res.Any.fromBytes(imagePath, imageBytes).toImage().toTile();
        }


        var font:h2d.Font = hxd.fmt.bfnt.FontParser.parse(fontBytes, file, resolveFontImage);
        return font;
    }


    public function getPath(file:String) {
        var folder = haxe.io.Path.directory(file).split("\\").join("/") + "/";
        var name = haxe.io.Path.withoutDirectory(file);


        if (directory == empty) setDirectory(file);


        if (directory == empty) return name;


        if (!StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return name;


        if (StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return folder.substr(directory.length) + name;

        return name;
    }


    public function getDirectory(file:String) {
        var folder = haxe.io.Path.directory(file).split("\\").join("/") + "/";
        
        if (!Config.detectProject) {
            project = folder.substr(0, folder.length - Config.resourceDir.length - 2);
            return folder;
        }

        var path = haxe.io.Path.directory(file).split("\\");
        var res = Config.resourceDir;

        if (path.contains(res)) {
            folder = empty;
            for (dir in path) {
                folder += dir + "/";
                if (dir != res) project = dir;
                if (dir == res) break;
            }
        }
        editor.onProject();

        return folder;
    }


    public function setDirectory(file:String) {
        if (!Config.detectProject) return;

        var path = haxe.io.Path.directory(file).split("\\");
        var res = Config.resourceDir;
        
        if (path.contains(res)) {
            for (dir in path) {
                directory += dir + "/";
                if (dir != res) project = dir;
                if (dir == res) break;
            }
        }

        editor.onProject();
    }


    public function isExternal(file:String) {
        var folder = haxe.io.Path.directory(file).split("\\").join("/") + "/";

        if (directory == empty) return true;
        if (!StringTools.startsWith(folder.toLowerCase(), directory.toLowerCase())) return true;

        return false;
    }


    public function clear() {
        filename = defaultName;
        project = "untitled";
        directory = "";
        filepath = "";
    }
}

typedef Field = { name : String, type : String, data : String, original : String, value : String };

typedef Data = {
	var name : String;
	var type : String;
	var link : String;

	@:optional var children : Array<Data>;
	@:optional var parent : String;

	@:optional var field : Array<Field>;

	@:optional var x : Float;
	@:optional var y : Float;
	@:optional var scaleX : Float;
	@:optional var scaleY : Float;
	@:optional var rotation : Float;

	@:optional var blendMode : String;
	@:optional var visible : Bool;
	@:optional var alpha : Float;

	@:optional var src : String;

	@:optional var width : Float;
	@:optional var height : Float;

	@:optional var smooth : Int;
	
	@:optional var dx : Float;
	@:optional var dy : Float;

	@:optional var color : Int;
	@:optional var align : Int;
	@:optional var range : Int;

	@:optional var speed : Int;
	@:optional var loop : Int;

	@:optional var text : String;
	@:optional var atlas : String;
	@:optional var font : String;
	@:optional var path : String;
}