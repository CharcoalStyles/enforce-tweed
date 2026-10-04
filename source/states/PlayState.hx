package states;

import entities.CreepSpawner;
import entities.PlayerBase;
import entities.TdGui;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import states.subStates.PauseState;
import utils.GlobalState;

class PlayState extends FlxState
{
	/**
	 * Some static constants for the size of the tilemap tiles
	 */
	static inline var TILE_WIDTH:Int = 32;

	static inline var TILE_HEIGHT:Int = 32;

	static inline var MAP_WIDTH:Int = 60;
	static inline var MAP_HEIGHT:Int = 33;

	static inline var MAP_SPAWN_AREA_X_MIN:Int = 2;
	static inline var MAP_SPAWN_AREA_X_MAX:Int = MAP_WIDTH - 3;
	static inline var MAP_SPAWN_AREA_Y_MIN:Int = 2;
	static inline var MAP_SPAWN_AREA_Y_MAX:Int = MAP_HEIGHT - 3;

	var globalState:GlobalState;

	var map:FlxTilemap;
	var collisionMap:FlxTilemap;

	var playerBase:PlayerBase;
	var creepSpawner:CreepSpawner;

	var path:FlxPath;

	var isInPlaceMode:Bool = false;

	var _highlightBox:FlxSprite;

	public function new()
	{
		super();
	}

	override public function create()
	{
		super.create();
		FlxG.mouse.visible = true;
		FlxG.camera.antialiasing = true;

		globalState = FlxG.plugins.get(GlobalState);

		// Create the map
		map = new FlxTilemap();
		add(map);
		collisionMap = new FlxTilemap();
		add(collisionMap);
		loadMap();
		_highlightBox = new FlxSprite(0, 0);
		_highlightBox.makeGraphic(TILE_WIDTH * 2, TILE_HEIGHT * 2, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRect(_highlightBox, 0, 0, TILE_WIDTH * 2 - 1, TILE_HEIGHT * 2 - 1, FlxColor.TRANSPARENT, {thickness: 1, color: FlxColor.RED});
		add(_highlightBox);

		var gui = new TdGui();
		add(gui);
		gui.onNextWave.add(() -> creepSpawner.startNextWave());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.P)
		{
			isInPlaceMode = !isInPlaceMode;
			_highlightBox.visible = isInPlaceMode;
		}
		if (isInPlaceMode)
		{
      // TODO: have this stored to test every frame
			_highlightBox.x = Math.floor(FlxG.mouse.x / (TILE_WIDTH * 2)) * (TILE_WIDTH * 2);
			_highlightBox.y = Math.floor(FlxG.mouse.y / (TILE_HEIGHT * 2)) * (TILE_HEIGHT * 2);
			updatePath();

			if (FlxG.mouse.justPressed)
			{
				var sourceIndex = collisionMap.getMapIndexAt(_highlightBox.x, _highlightBox.y);
				collisionMap.setTileIndex(sourceIndex, 1);
				collisionMap.setTileIndex(sourceIndex + 1, 1);
				collisionMap.setTileIndex(sourceIndex + map.widthInTiles, 1);
				collisionMap.setTileIndex(sourceIndex + map.widthInTiles + 1, 1);
				isInPlaceMode = false;
				// updatePath();
			}
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			creepSpawner.kill();
			remove(creepSpawner);
			loadMap();
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			this.subState = new PauseState(globalState.controllerId);
			this.subState.create();
			this.subState.closeCallback = () ->
			{
				this.subState = null;
			}
		}
	}

	override function draw()
	{
		super.draw();
		if (path != null)
		{
			path.drawDebugOnCamera(FlxG.camera);
		}
	}

	function loadMap()
	{
		var visualTileMap:String = "";
		var collisionTileMap:String = "";
		for (y in 0...MAP_HEIGHT)
		{
			for (x in 0...MAP_WIDTH)
			{
				collisionTileMap += Std.string(0) + ",";
				if (Math.random() > 0.2)
				{
					visualTileMap += Std.string(getRandomTileInQuadrant(0, 0)) + ",";
				}
				else
				{
					if (Math.random() > 0.05)
					{
						visualTileMap += Std.string(getRandomTileInQuadrant(1, 0)) + ",";
					}
					else
					{
						visualTileMap += Std.string(getRandomTileInQuadrant(0, 1)) + ",";
					}
				}
			}
			visualTileMap += "\n";
			collisionTileMap += "\n";
		}

		map.loadMapFromCSV(visualTileMap, "assets/images/TX Tileset Grassx2.png", TILE_WIDTH, TILE_HEIGHT, OFF, 0, 0);
		collisionMap.loadMapFromCSV(collisionTileMap, "assets/images/collision.png", TILE_WIDTH, TILE_HEIGHT, OFF, 0, 0);

		if (playerBase != null)
		{
			remove(playerBase);
		}

		// pick a tile around the edge of the map to place the player base.
		// it can't be in in the first row or column or the last 2 rows or columns

		// edge position (0 = top, 1 = right, 2 = bottom, 3 = left)
		var edgePosition = Std.random(4);

		var edgeTileX = 0;
		var edgeTileY = 0;

		// top and left edges inset by 1, bottom and right edges inset by 2
		switch (edgePosition)
		{
			case 0:
				// top edge, random x position
				edgeTileX = FlxG.random.int(MAP_SPAWN_AREA_X_MIN, MAP_SPAWN_AREA_X_MAX);
				edgeTileY = MAP_SPAWN_AREA_Y_MIN;
			case 1:
				// right edge
				edgeTileX = MAP_SPAWN_AREA_X_MAX;
				// random y position
				edgeTileY = FlxG.random.int(MAP_SPAWN_AREA_Y_MIN, MAP_SPAWN_AREA_Y_MAX);
			case 2:
				// bottom edge
				edgeTileX = FlxG.random.int(MAP_SPAWN_AREA_X_MIN, MAP_SPAWN_AREA_X_MAX);
				edgeTileY = MAP_SPAWN_AREA_Y_MAX;
			case 3:
				// left edge
				edgeTileX = MAP_SPAWN_AREA_X_MIN;
				edgeTileY = FlxG.random.int(MAP_SPAWN_AREA_Y_MIN, MAP_SPAWN_AREA_Y_MAX);
		}
		var basePosition = map.getTilePos(edgeTileX, edgeTileY);

		playerBase = new PlayerBase(basePosition);
		add(playerBase);

		// spawn the creep spawner in the opposite half on the x axis
		var spawnRight = edgeTileX < MAP_WIDTH / 2;
		var spawnerTileX = spawnRight ? FlxG.random.int(Math.floor(MAP_WIDTH / 2),
			MAP_SPAWN_AREA_X_MAX) : FlxG.random.int(MAP_SPAWN_AREA_X_MIN, Math.floor(MAP_WIDTH / 2));
		var spawnerTileY = FlxG.random.int(MAP_SPAWN_AREA_Y_MIN, MAP_SPAWN_AREA_Y_MAX);

		var spawnerPosition = map.getTilePos(spawnerTileX, spawnerTileY);

		creepSpawner = new CreepSpawner(spawnerPosition);
		add(creepSpawner);

		creepSpawner.onCreepAttack.add(() ->
		{
			var isDead = playerBase.damage(5);
			if (isDead)
			{
				playerBase.kill();
				FlxG.switchState(() -> new MainMenuState());
			}
		});
	}

	function getRandomTileInQuadrant(quadX:Int, quadY:Int):Int
	{
		// 1. Pick a random local row and col inside a 4x4 quadrant (0 to 3)
		var localCol = Std.random(8);
		var localRow = Std.random(8);

		// 2. Shift them to the correct quadrant position on the 8x8 map
		var globalCol = (quadX * 8) + localCol;
		var globalRow = (quadY * 8) + localRow;

		// 3. Convert 2D coordinates to your 1D tilemap index
		var tile = (globalRow * 16) + globalCol;

		if (tile == 126 || tile == 127)
		{
			tile = Math.floor(Math.random() * 62);
		}

		return tile;
	}

	function updatePath()
	{
		var offset = FlxPoint.get(32, 32);
		var nodes = collisionMap.findPath(creepSpawner.position + offset, playerBase.position + offset, RAY, NONE);
		path = new FlxPath(nodes);
		creepSpawner.path = path;
	}
}
