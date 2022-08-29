using haxe.Int64;

class Int64s {
	static var zero = Int64.make(0, 0);
	static var one = Int64.make(0, 1);
	static var min = Int64.make(0x80000000, 0);

	/**
	Converts an `Int64` to `Float`;
	Implementation by Elliott Stoneham.
	*/
	public static function toFloat(i : Int64) : Float {
		var isNegative = false;
		if(i < 0) {
			if(i < min)
			return -9223372036854775808.0; // most -ve value can't be made +ve
			isNegative = true;
			i = -i;
		}
		var multiplier = 1.0,
			ret = 0.0;
		for(_ in 0...64) {
			if(i.and(one) != zero)
			ret += multiplier;
			multiplier *= 2.0;
			i = i.shr(1);
		}
		return (isNegative ? -1 : 1) * ret;
	}
}