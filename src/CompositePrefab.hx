import haxe.io.Bytes;
import File.Data;
import haxe.io.Bytes;
import haxe.zip.Entry;
import haxe.zip.Writer;
import haxe.zip.Reader;
import haxe.Json;

class CompositePrefab {
    public var resources: Map<String, Bytes> = [];
    public var prefab: Data;
    
    public function new(?prefab: Data) {
        this.prefab = prefab;
    }

    public function getName(): String {
        return prefab.name;
    }
    
    public function findPrefab(name: String): CompositePrefab {
        if(prefab.name == name) {
            return this;
        }
        else {
            for(eachName => val in resources) {
                if(eachName == name) {
                    return CompositePrefab.fromZipBytes(val);
                }
            }
        }
        return null;
    }

    public function toZipBytes(): Bytes {
        var entries: List<Entry> = new List();
        
        var prefabJson = Json.stringify(prefab);
        var prefabBytes = Bytes.ofString(prefabJson);
        entries.add({
            fileName: "prefab.json",
            fileTime: Date.now(),
            data: prefabBytes,
            compressed: false,
            dataSize: prefabBytes.length,
            fileSize: prefabBytes.length,
            crc32: haxe.crypto.Crc32.make(prefabBytes)
        });
        
        for (name in resources.keys()) {
            trace("saving resource: " + name);
            var data = resources.get(name);
            entries.add({
                fileName: "res/" + name,
                fileTime: Date.now(),
                data: data,
                compressed: false,
                dataSize: data.length,
                fileSize: data.length,
                crc32: haxe.crypto.Crc32.make(data)
            });
        }
        
        var output = new haxe.io.BytesOutput();
        var writer = new Writer(output);
        writer.write(entries);
        return output.getBytes();
    }
    
    public function getResource(name: String): Bytes {
        return resources.get(name);
    }
    
    public static function fromZipBytes(bytes: Bytes): CompositePrefab {
        var result = new CompositePrefab();
        var input = new haxe.io.BytesInput(bytes);
        var reader = new Reader(input);
        var entries = reader.read();
        
        for (entry in entries) {
            var data = entry.data;
            if (entry.fileName == "prefab.json") {
                var jsonStr = data.toString();
                result.prefab = Json.parse(jsonStr);
            } else if (entry.fileName.indexOf("res/") == 0) {
                var name = entry.fileName.substr(4); 
                result.resources.set(name, data);
            }
        }
        
        return result;
    }
    
    public function addResource(name: String, data: Bytes): Void {
        trace("adding resource: " + name);
        resources.set(name, data);
    }
}