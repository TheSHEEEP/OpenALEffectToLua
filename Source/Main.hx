package;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import openfl.Assets;
#if windows
	import systools.Clipboard;
	import sys.io.File;
	import sys.io.FileOutput;
#end
#if flash
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
#end

class Main extends Sprite 
{
	private var _label 	:TextField;
	private var _input 	:TextField;
	private var _result :TextField;
	
	public function new () 
	{
		super ();
		
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	/**
	 * Initialize everything.
	 */
	private function init(e:Event) :Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		// Format to use
		var format :TextFormat = new TextFormat();
		format.size = 0.03 * stage.stageHeight;
		format.bold = true;
		format.color = 0xDDDDDD;
	
		// Label
		_label = new TextField();
		_label.defaultTextFormat = format;
		_label.mouseEnabled = false;
		_label.selectable = false;
		_label.y = 0.1 * stage.stageHeight;
		_label.x = 0.05 * stage.stageWidth;
		_label.text = "Enter OpenAL effect preset and press ENTER to parse.";
		_label.height = 1.05 * _label.textHeight;
		_label.width = 1.05 * _label.textWidth;
		addChild(_label);
		
		// Input
		var inputFormat :TextFormat = new TextFormat();
		inputFormat.size = 0.03 * stage.stageHeight;
		inputFormat.bold = true;
		inputFormat.color = 0xCCCCCC;
		_input = new TextField();
		_input.type = TextFieldType.INPUT;
		_input.defaultTextFormat = inputFormat;
		_input.mouseEnabled = true;
		_input.selectable = true;
		_input.wordWrap = true;
		_input.y = 0.2 * stage.stageHeight;
		_input.x = 0.05 * stage.stageWidth;
		_input.height = 0.5 * stage.stageHeight;
		_input.width = 0.9 * stage.stageWidth;
		_input.background = true;
		_input.backgroundColor = 0x5555AA;
		addChild(_input);
		_input.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		
		// Result
		_result = new TextField();
		_result.defaultTextFormat = format;
		_result.mouseEnabled = false;
		_result.selectable = false;
		_result.wordWrap = true;
		_result.y = 0.7 * stage.stageHeight;
		_result.x = 0.05 * stage.stageWidth;
		_result.text = "Result:";
		_result.height = 0.3 * stage.stageHeight;
		_result.width = 0.9 * stage.stageWidth;
		addChild(_result);
	}
	
	/**
	 * Will try to parse the text in the input field if ENTER was pressed.
	 */
	private function handleKeyDown(p_event:KeyboardEvent) :Void 
	{
		#if windows
			// Manual clipboard paste on Windows
			if (p_event.keyCode == Keyboard.V && p_event.ctrlKey)
			{
				_input.text = Clipboard.getText();
			}
		#end
		if (p_event.keyCode == Keyboard.ENTER && !p_event.ctrlKey)
		{
			// Make sure this is a valid effect preset
			var checkEffect :EReg = ~/^#define EFX_REVERB_PRESET_.*\{.*\}$/;
			if (checkEffect.match(_input.text))
			{
				// Get the name
				var nameReg :EReg = ~/ EFX_REVERB_PRESET_[_A-Z]* /;
				nameReg.match(_input.text);
				
				var results :Results = new Results();
				results.nameUpper = StringTools.replace(nameReg.matched(0), "EFX_REVERB_PRESET_", "");
				results.nameUpper = StringTools.replace(results.nameUpper, " ", "");
				results.nameLower = StringTools.replace(results.nameUpper.toLowerCase(), "_", "");
				var tokens :Array<String> = StringTools.replace(results.nameUpper.toLowerCase(), "_", " ").split(" ");
				for (token in tokens)
				{
					results.nameCap += token.substr(0, 1).toUpperCase() + token.substr(1, token.length).toLowerCase(); 
				}
				
				_result.text = results.nameUpper + " " + results.nameLower + " " + results.nameCap + "\n";
				
				// Get the numbers
				var numbersReg :EReg = ~/([0-9]+\.[0-9]+)/;
				var text :String = _input.text;
				while (text != null) 
				{
					if (!numbersReg.match(text))
						break;
					text = numbersReg.matchedRight();
					results.numbers.push(Std.parseFloat(numbersReg.matched(1)));
					_result.text += " " + numbersReg.matched(1);
				}
				
				// Get the limit
				var limitReg :EReg = ~/0x1/;
				if (!limitReg.match(_input.text))
				{
					results.hfLimit = false;
				}
				_result.text += "\n " + results.hfLimit;
				
				// Create the effect file/clipboard
				createEffectFile(results);
			}
		}
	}
	
	/**
	 * Creates the lua effect file from the passed results (in the working folder).
	 */
	function createEffectFile(p_results :Results) :Void
	{
		// Get the template file
		var finalText :String = Assets.getText("template/Template.lua");
		
		// Replace names
		finalText = StringTools.replace(finalText, "%name_cap%", p_results.nameCap);
		finalText = StringTools.replace(finalText, "%name_lower%", p_results.nameLower);
		
		// Replace numbers
		var toPaste :String = "";
		for (i in 0 ... 26)
		{
			// Make sure the string always ends with ".0" or similar to avoid type conversion in Lua/C++
			toPaste = "" + p_results.numbers[i];
			if (toPaste.indexOf(".") == -1)
			{
				toPaste += ".0";
			}
			finalText = StringTools.replace(finalText, "%" + i + "%", toPaste);
		}
		
		// Replace hflimit
		finalText = StringTools.replace(finalText, "%hflimit%", "" + p_results.hfLimit);
		
		#if flash
			// On flash, paste to clipboard
			_result.text += "\n Can only create Lua file on CPP targets. File content has been pasted to your clipboard.";
			flash.desktop.Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, finalText);
		#else
			// On others, create the file and write to it
			// TODO: support other effects, not just reverb ones
			var fileOut :FileOutput = File.write("reverb" + p_results.nameLower + ".lua", false);
			
			// Write line by line top prevent completely empty lines
			// When just writing finalText directly, every second row is completely empty somehow (line ending quirks?)
			var lines :Array<String> = finalText.split("\n");
			for (line in lines)
			{
				fileOut.writeString(line);
			}
			
			fileOut.close();
			_result.text += "\n DONE! Written to file: " + "reverb" + p_results.nameLower + ".lua";
		#end
	}
	
	
}