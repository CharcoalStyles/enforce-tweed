package entities;

import flixel.FlxBasic.FlxType;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.util.FlxSignal.FlxTypedSignal;

class CreepSpawner extends FlxTypedGroup<FlxBasic>
{
	var _x:Float = 0;
	var _y:Float = 0;

	// position:FlxPoint with getter
	public var position(get, never):FlxPoint;

	inline function get_position():FlxPoint
	{
		return new FlxPoint(_x, _y);
	}

	var spawnTimer:Float = 0;
	var spawnDelay:Float = 0.65;

	var canSpawnWave:Bool = false;
	var waveSpawnCount:Int = 15;
	var waveSpawnCounter:Int = 0;

	var creeps:FlxTypedGroup<CreepBase>;

	public var path:FlxPath;

	public var onCreepAttack(default, null) = new FlxTypedSignal<() -> Void>();

	public function new(position:FlxPoint)
	{
		super();

		_x = position.x;
		_y = position.y;

		var sprite = new FlxSprite(position.x, position.y);
		sprite.makeGraphic(64, 64, 0xffa040a0);
		add(sprite);

		creeps = new FlxTypedGroup<CreepBase>();
		add(creeps);
		for (i in 0...50)
		{
			var creep = new CreepBase(0, 0);
			creep.kill();
			creeps.add(creep);
		}
	}

	public function setNextWave(rate:Float, count:Int)
	{
		spawnDelay = rate;
		waveSpawnCount = count;
	}

	public function startNextWave()
	{
		canSpawnWave = true;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (canSpawnWave)
		{
			spawnTimer -= elapsed;

			if (spawnTimer <= 0 && waveSpawnCount > 0)
			{
				spawnTimer = spawnDelay;
				var creep = creeps.getFirstAvailable(CreepBase, true);
				if (creep == null)
				{
					creep = new CreepBase(0, 0);
					creep.kill();
					add(creep);
				}

				creep.setPath(path);
				creep.reset(path.head().x - 32, path.head().y - 32);
				creep.animation.play("run");
				creep.path.start(null, 32);

				creep.onEndReached.add(() ->
				{
					onCreepAttack.dispatch();
					creep.kill();
				});

				waveSpawnCount -= 1;
				if (waveSpawnCount <= 0)
				{
					canSpawnWave = false;
				}
			}
		}
	}
}
