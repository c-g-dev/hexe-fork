package property.component;


class Input extends h2d.Object {
	public var minimum:Float = Math.NEGATIVE_INFINITY;
	public var maximum:Float = Math.POSITIVE_INFINITY;
	
	public var width:Float = 32;
	public var height:Float = 32;

	public var enabled(default, set):Bool = true;

	public var value(default, set):String = "";
	public var label(default, set):String = "";
	public var icon(default, set):String = "";

	public var field:String = "";


	public dynamic function onFocus(prop:h2d.Object) {}

	public dynamic function onSelect(prop:Dynamic) {}

	public dynamic function onUpdate(prop:Dynamic) {}

	public dynamic function onChange(prop:Dynamic) {}

	public dynamic function onResize() {}

	public function blur() {}


	function set_enabled(v) {
		return enabled = v;
	}

	function set_value(v) {
		return value = v;
	}

	function set_label(v) {
		return label = v;
	}

	function set_icon(v) {
		return icon = v;
	}

	public function setSize(w:Float, h:Float) {
		width = w;
		height = h;
	}
}