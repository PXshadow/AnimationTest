package;
import sys.io.FileInput;
import format.tools.BitsInput;
import sys.io.File;
import openfl.display.Tile;
import openfl.display.Bitmap;
import data.PlayerData.PlayerInstance;
import openfl.display.Sprite;
import openfl.display.Shape;
import data.*;
import game.*;
class Main extends Sprite
{
	public static var objects:Objects;
	public static var data:GameData;
	public static var draw:Shape = new Shape();
	public function new()
	{
		super();
		draw.graphics.beginFill(0,0.5);
		
		data = new GameData();
		data.objectMap.set(19,new ObjectData(19));
		data.objectMap.set(30,new ObjectData(30));
		objects = new Objects();
		var instance = new PlayerInstance([]);
		instance.po_id = 19;
		objects.addPlayer(instance);
		objects.player.x = 400;
		objects.player.y = 400;
		new AnimationPlayer(objects.player.instance.po_id,2,objects.player,objects.player.sprites(),0,Static.tileHeight);
		objects.width = 800;
		objects.height = 600;
		addChild(objects);

		addChild(draw);
		//var input = File.read("hunger.aiff");
		//input.bigEndian = true; 
		//new AiffData(input.readAll());
		//display testing
		stage.window.minimized = false;
		stage.window.x = -1500;
	}
}
