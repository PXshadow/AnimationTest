package data;
import openfl.geom.Matrix;
import lime.media.AudioBuffer;
import openfl.geom.Rectangle;
#if openfl
import motion.easing.Linear;
import motion.easing.Sine;
import data.AnimationData.AnimationType;
import motion.Actuate;
import haxe.Timer;
import openfl.display.Tile;
import openfl.display.TileContainer;
import data.AnimationData.AnimationParameter;
import haxe.ds.Vector;
import openfl.geom.Point;
class AnimationPlayer
{
    var children:Vector<Array<Int>>;
    var parent:TileContainer;
    var time:Float = 0;
    private static var current:Array<Int> = [];
    var param:Vector<AnimationParameter>;
    var sprites:Array<Tile> = [];
    var type:AnimationType = null;
    var objectData:ObjectData;
    //tile position
    var tx:Float = 0;
    var ty:Float = 0;
    public function new(id:Int,int:Int,parent:TileContainer,sprites:Array<Tile>,x:Int=0,y:Int=0)
    {
        //if (current.indexOf(id) > -1) return;
        //current.push(id);
        objectData = Main.data.objectMap.get(id);
        if (objectData == null || objectData.animation == null) return;
        param = objectData.animation.record[int].params;
        this.sprites = sprites;
        this.parent = parent;
        type = objectData.animation.record[int].type;
        tx = x * Static.GRID;
        ty = (Static.tileHeight - y) * Static.GRID;
        trace("tx " + tx + " ty " + ty);
        trace("numTiles " + parent.numTiles);
        children = Vector.fromArrayCopy([for (i in 0...sprites.length) []]);
        setup();
        trace("numTilesAfter " + parent.numTiles);
    }
    public function setup()
    {
        var sprite:Tile = null;
        var p:Int = 0;
        //temporary
        var tc:TileContainer;
        //sprite parent
        var sp:TileContainer;
        var point:Point = null;
        var index:Int = 0;
        //offset
        for (i in 0...sprites.length)
        {
            sprite = sprites[i];
            //set pos
            Main.objects.setSprite(sprite,objectData.spriteArray[i],tx,ty);
            sprite.x += param[i].offset.x;
            sprite.y += -param[i].offset.y;
            sprite.originX += param[i].rotationCenterOffset.x;
            sprite.originY += -param[i].rotationCenterOffset.y;
            //parent
            p = objectData.spriteArray[i].parent;
            if (p != -1) children[p].push(i);
        }
        //debug
        //for (p in [71,40]) Actuate.tween(sprites[p],1,{rotation:180}).repeat().reflect();
        //return;
        //animation
        for (i in 0...param.length)
        {
            sprite = sprites[i];
            //stop
            Actuate.stop(sprite);
            //animate
            if (param[i].xAmp > 0) tween(sprite,{x:param[i].xAmp/2},1/param[i].xOscPerSec,param[i].xPhase);
            if (param[i].yAmp > 0) tween(sprite,{y:param[i].yAmp/2},1/param[i].yOscPerSec,param[i].yPhase);
            if (param[i].rockAmp > 0) tween(sprite,{rotation:(param[i].rockAmp * 365)/2},1/param[i].rockOscPerSec,param[i].rockPhase);
            //parents
            for (j in children.get(i))
            {
                //Actuate.update(update,1,[sprites[j],sprite],[sprites[j],sprite]).repeat();
            }
        }
    }
    public function localToGlobal(tile:Tile,point:Point):Point
    {
        @:privateAccess return tile.__getWorldTransform().transformPoint(point);
    }
    private function globalToLocal(tile:Tile,point:Point)
    {
        @:privateAccess var mat = tile.__getWorldTransform();
        @:privateAccess mat.__transformInversePoint(point);
        tile.matrix = mat;
    }
    private inline function phase(x:Float):Float
    {
        if (x > 0.75) return x - 1;
        return (x * 2 - 1) * -2;
    }
    private function tween(sprite:Tile,a:Dynamic,time:Float,phaseNum:Float=0)
	{
        var prop = Reflect.fields(a)[0];
        var value:Float = Reflect.getProperty(a,prop);
        //phase
        if (phaseNum > 0) Reflect.setProperty(sprite,prop,Reflect.getProperty(sprite,prop) + phase(phaseNum) * value);
        //shorten
        if (phaseNum >= 0.25 && phaseNum <= 0.5)
        {
            Reflect.setProperty(a,prop,-value);
            Actuate.tween(sprite,time/2,a,false).ease(Sine.easeInOut).onComplete(function()
            {
                Reflect.setProperty(a,prop,-value);
                tween(sprite,a,time);
            });
        }else{
		    Actuate.tween(sprite,time/2,a,false).ease(Sine.easeInOut).onComplete(function()
		    {
                Reflect.setProperty(a,prop,-value);
			    Actuate.tween(sprite,time/2,a,false).ease(Sine.easeInOut).onComplete(function()
                {
                    Reflect.setProperty(a,prop,-value);
                    tween(sprite,a,time);
                });
		    });
        }
	}
    private function clean()
    {
        for (i in 0...sprites.length)
        {
            Actuate.stop(sprites[i]);
            if (!Std.is(sprites[i],TileContainer))
            {
                if (!parent.contains(sprites[i]))
                {
                    sprites[i].parent.removeTile(sprites[i]);
                    parent.addTile(sprites[i]);
                }
            }
        }
    }
}
#end