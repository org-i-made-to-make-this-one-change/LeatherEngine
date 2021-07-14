package modding;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.ui.FlxButton;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.addons.ui.FlxUICheckBox;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;
import flixel.group.FlxGroup;
import game.Character;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import game.Character.CharacterConfig;
import game.Character.CharacterAnimation;
import flixel.FlxState;

using StringTools;

class CharacterCreationState extends FlxState
{
    // OTHER STUFF IDK LMAO //
    public static var instance:CharacterCreationState;

    // SETTINGS //
    public var Character_Name:String = "bf";
    public var Image_Path:String = "BOYFRIEND";

    public var Default_FlipX:Bool = true;
    public var LeftAndRight_Idle:Bool = false;

    public var Spritesheet_Type:SpritesheetType = SPARROW;

    public var Animations:Array<CharacterAnimation> = [];

    // VARIABLES //
    private var Raw_JSON_Data:String;
    private var CC_Data:CharacterConfig;
    private var Character:Character;

    private var UI_Group:FlxGroup = new FlxGroup();

    private var Image_Path_Box:FlxUIInputText;
    private var Char_Name_Box:FlxUIInputText;

    private var Animation_List_Menu:FlxUIDropDownMenu;
    private var Animation_List:Array<String>;

    public function new(?New_Character:String = "bf")
    {
        super();

        instance = this;
        Character_Name = New_Character;

        if(Assets.getLibrary("shared") == null)
			Assets.loadLibrary("shared").onComplete(function (_) {});
    }

    override function create()
    {
        Raw_JSON_Data = "";

		#if sys
		Raw_JSON_Data = File.getContent(Sys.getCwd() + Paths.jsonSYS("character data/" + Character_Name + "/config")).trim();
		#else
		Raw_JSON_Data = Assets.getText(Paths.json("character data/" + Character_Name + "/config")).trim();
		#end

        Read_JSON_Data();

        Create_UI();
        add(UI_Group);
        add(Character);
    }

    public function Read_JSON_Data(?JSON_Data:Null<String>)
    {
        if(JSON_Data == null)
            CC_Data = cast Json.parse(Raw_JSON_Data);
        else
            CC_Data = cast Json.parse(JSON_Data);

        Image_Path = CC_Data.imagePath;
        Default_FlipX = CC_Data.defaultFlipX;
        LeftAndRight_Idle = CC_Data.dancesLeftAndRight;
        Spritesheet_Type = CC_Data.spritesheetType;
        Animations = CC_Data.animations;
    }

    private function Create_UI()
    {
        // BASE //
        var UI_Base = new FlxUI(null, null);

        // CHARTING STATE THING //
        var UI_box = new FlxUITabMenu(null, [], false);

        UI_box.resize(300, 400);
        UI_box.x = 10;
        UI_box.y = 70;

        var Grid_Background:FlxSprite = FlxGridOverlay.create(25, 25);
		Grid_Background.scrollFactor.set(0,0);

        // TEXT LABELS //
        var Name_Label:FlxText = new FlxText(20, 70, 0, "Character Name");
        var Path_Label:FlxText = new FlxText(20, 100, 0, "Image Path (after shared/characters/)");

        var Actions_Label:FlxText = new FlxText(20, 300, 0, "Actions");

        // TEXT BOXES //
        var Name_Box:FlxUIInputText = new FlxUIInputText(20, 85, 150, Character_Name, 8);
        Char_Name_Box = Name_Box;

        var Path_Box:FlxUIInputText = new FlxUIInputText(20, 115, 150, Image_Path, 8);
        Image_Path_Box = Path_Box;

        // CHECK BOXES //
        var Flip_Box:FlxUICheckBox = new FlxUICheckBox(20, 135, null, null, "Flipped by Default?", 250);
        Flip_Box.checked = Default_FlipX;

        Flip_Box.callback = function()
        {
            Default_FlipX = Flip_Box.checked;
        };

        var L_And_R_Box:FlxUICheckBox = new FlxUICheckBox(20, 160, null, null, "Dances to the left and right?", 250);
        L_And_R_Box.checked = LeftAndRight_Idle;

        L_And_R_Box.callback = function()
        {
            LeftAndRight_Idle = L_And_R_Box.checked;
        };

        var Packer_Box:FlxUICheckBox = new FlxUICheckBox(20, 185, null, null, "Packer Atlas used?", 250);
        Packer_Box.checked = Spritesheet_Type == PACKER;

        Packer_Box.callback = function()
        {
            if(Packer_Box.checked)
                Spritesheet_Type = PACKER;
            else
                Spritesheet_Type = SPARROW;
        };

        // BUTTONS //
        var Reload_Char:FlxButton = new FlxButton(20, 325, "Load Character", function(){
            if(Character != null)
            {
                remove(Character);
                Character.kill();
                Character.destroy();
            }

            Create_Character();

            add(Character);

            Load_Animations();
        });

        // DROP DOWNS //
        Animation_List_Menu = new FlxUIDropDownMenu(20, 200, FlxUIDropDownMenu.makeStrIdLabelArray(Animation_List, true), function(id:String){

        });

        // ADDING OBJECTS //
        UI_Base.add(Grid_Background);

        UI_Base.add(UI_box);

        UI_Base.add(Name_Label);
        UI_Base.add(Name_Box);

        UI_Base.add(Path_Label);
        UI_Base.add(Path_Box);

        UI_Base.add(Flip_Box);
        UI_Base.add(L_And_R_Box);
        UI_Base.add(Packer_Box);

        UI_Base.add(Actions_Label);
        UI_Base.add(Reload_Char);

        UI_Group.add(UI_Base);

        Create_Character();
    }

    function Load_New_JSON_Data()
    {
        CC_Data.imagePath = Image_Path;
        CC_Data.defaultFlipX = Default_FlipX;
        CC_Data.dancesLeftAndRight = LeftAndRight_Idle;
        CC_Data.spritesheetType = Spritesheet_Type;
        CC_Data.animations = Animations;
    }

    function Create_Character(?New_Char:String)
    {
        if(New_Char != null)
            Character_Name = New_Char;

        Load_New_JSON_Data();

        Character = new Character(0, 0, "bf", true);
        Character.loadCharacterConfiguration(CC_Data);
        Character.debugMode = true;
        Character.screenCenter();
    }

    function Load_Animations()
    {
        Animation_List = [];

        for(animation in CC_Data.animations)
        {
            var name = animation.name;

            Animation_List.push(name);
        }
    }

    function Load_Animation_Info()
    {

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Char_Name_Box != null)
            Character_Name = Char_Name_Box.text;
        if(Image_Path_Box != null)
            Image_Path = Image_Path_Box.text;

        if(Character != null)
            Character.screenCenter();
    }
}

enum SpritesheetType
{
    SPARROW;
    PACKER;
}