local key = {}

key.keyList = {
	[Enum.KeyCode.One] = 1;
	[Enum.KeyCode.Two] = 2;
	[Enum.KeyCode.Three] = 3;
	[Enum.KeyCode.Four] = 4;
	[Enum.KeyCode.Five] = 5;
	[Enum.KeyCode.Six] = 6;
	[Enum.KeyCode.Seven] = 7;
	[Enum.KeyCode.Eight] = 8;
	[Enum.KeyCode.Nine] = 9;
	[Enum.KeyCode.E] = 10;
	[Enum.KeyCode.C] = 11;
	[Enum.KeyCode.LeftControl] = 12;
	[Enum.KeyCode.RightBracket] = 13;
	[Enum.KeyCode.LeftBracket] = 14;
	[Enum.KeyCode.Slash] = 15;
	[Enum.KeyCode.W] = 16;
	[Enum.KeyCode.Space] = 17;
	[Enum.KeyCode.Z] = 18;
	[Enum.KeyCode.L] = 19;
	[Enum.KeyCode.M] = 20;
	[Enum.KeyCode.Q] = 21;
}

function key:returnKeyCode(key)
	return key.keyList[key]
end

return key