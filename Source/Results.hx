package ;

/**
 * Helper struct to hold parsing result information.
 * @author Jan Drabner
 */
class Results
{
	public var nameUpper : String = "";
	public var nameLower : String = "";
	public var nameCap : String = "";
	public var numbers : Array<Float>;
	public var hfLimit :Bool = true;
	
	public function new() 
	{
		numbers = new Array<Float>();
	}
	
}