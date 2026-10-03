package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
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
	static inline var MAP_HEIGHT:Int = 28;

	var globalState:GlobalState;

	var map:FlxTilemap;

	/**
	 * Box to show the user where they're placing stuff
	 */
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
		loadMap();
		add(map);
		_highlightBox = new FlxSprite(0, 0);
		_highlightBox.makeGraphic(TILE_WIDTH * 2, TILE_HEIGHT * 2, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRect(_highlightBox, 0, 0, TILE_WIDTH * 2 - 1, TILE_HEIGHT * 2 - 1, FlxColor.TRANSPARENT, {thickness: 1, color: FlxColor.RED});
		add(_highlightBox);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
		_highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;

		if (FlxG.keys.justPressed.SPACE)
		{
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

	function loadMap()
	{
		var data:String = "";
		for (y in 0...MAP_HEIGHT)
		{
			for (x in 0...MAP_WIDTH)
			{
				if (Math.random() > 0.2)
				{
					data += Std.string(getRandomTileInQuadrant(0, 0)) + ",";
				}
				else
				{
					if (Math.random() > 0.2)
					{
						data += Std.string(getRandomTileInQuadrant(1, 0)) + ",";
					}
					else
					{
						data += Std.string(getRandomTileInQuadrant(0, 1)) + ",";
					}
				}
			}
			data += "\n";
		}

		map.loadMapFromCSV(data, "assets/images/TX Tileset Grassx2.png", TILE_WIDTH, TILE_HEIGHT, OFF, 0, 0);
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
			FlxG.log.add("Tile " + tile + " is in the bottom right corner, picking a new tile.");
			tile = Math.floor(Math.random() * 62);
		}

		return tile;
	}
}
