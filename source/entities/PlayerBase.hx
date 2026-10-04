package entities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;

class PlayerBase extends FlxGroup
{
	var _x:Float = 0;
	var _y:Float = 0;

	// position:FlxPoint with getter
	public var position(get, never):FlxPoint;

	inline function get_position():FlxPoint
	{
		return new FlxPoint(_x, _y);
	}

	var _health:Int = 100;
	var _maxHealth:Int = 100;

	var sprite:FlxSprite;
	var healthBar:FlxBar;

	public function new(pos:FlxPoint)
	{
		super();
		_x = pos.x;
		_y = pos.y;
		create();
	}

	public function damage(amount:Int):Bool
	{
		_health -= amount;
		if (_health <= 0)
		{
			return true;
		}
		return false;
	}

	public function create():Void
	{
		sprite = new FlxSprite(_x, _y);
		sprite.makeGraphic(64, 64, 0xff000000);
		add(sprite);
		healthBar = new FlxBar(_x + 6, _y + 4, LEFT_TO_RIGHT, 52, 8, this, "_health", 0, _maxHealth);
		healthBar.createFilledBar(0xff000000, 0xff00ff00, true);
		add(healthBar);
	}
}
