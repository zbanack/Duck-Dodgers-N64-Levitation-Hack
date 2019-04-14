-- Duck Dodgers Starring Daffy Duck (N64, 2000)
-- Levitation LUA script

-- Define levitation buttons
levitateButtonRaise = 'Z';
levitateButtonLower = 'X';
levitateButtonToggle = 'C';

precision = 3;
levitateManipFactor = 0.1;
isLevitating = 0;
levitateLockY = 0;
levitateDeltaY = 0;

-- Lock y coord to simulate levitation
function levitateLockYCoord() 
	levitateLockY = getYPosition();
	levitateDeltaY = levitateLockY;
end

function round(num, idp)
	return tonumber(string.format("%." .. (idp or 0) .. "f", num));
end

-- (x, y, z) coord and velocity getters
function getXPosition()
	return mainmemory.readfloat(0x1CFF64, true);
end

function getZPosition()
	return  mainmemory.readfloat(0x1CFF68, true);
end

function getYPosition()
	return  mainmemory.readfloat(0x1CFF6C, true);
end

function getXVelocity()
	return mainmemory.readfloat(0x1D0008, true) ;
end

function getYVelocity()	
	return mainmemory.readfloat(0x1CFEDC, true) ;
end

function getVelocityCalc() -- Calculated VXZ
	local vX = mainmemory.readfloat(0x1CFED4, true);
	local vZ = mainmemory.readfloat(0x1CFED8, true);
	return math.sqrt(vX*vX + vZ*vZ);
end

levitateLockYCoord();

-- Main levitate
function levitate()
	-- Lock velocity, override gravity
	mainmemory.writefloat(0x1CFEDC, 0, true) ;
	
	-- Prevent death animation
	mainmemory.writefloat(0x1CFC24, 0, true) ;
	return mainmemory.writefloat(0x1CFF6C, levitateDeltaY, true);
end

-- Change in y coord
function hoverChangeY(dir)
	levitateDeltaY = levitateDeltaY + (1.00 * levitateManipFactor) * dir;
end

-- Levitation toggle
function toggle_lev() 
	if isLevitating == 1 then
		isLevitating = 0;
	else
		isLevitating = 1;
	end
	return;
end

function getInput()
	list = input.get();
	
	-- Raise while levitating
	if list[levitateButtonRaise] then
		hoverChangeY(1);
	end
	
	-- Lower while levitating
	if list[levitateButtonLower] then
		hoverChangeY(-1);
	end
	
	-- Toggle levitation
	wasPressingLev = pressingLev;
	pressingLev = 0;
	if list[levitateButtonToggle] then
		pressingLev = 1;
		if (wasPressingLev == 0) then
			levitateLockYCoord();
			toggle_lev();
		end
	end
	
	if (isLevitating == 1) then
		levitate();
	end
	
end

-- Returns levitation status
function getisLevitating() 
	return isLevitating;
end

-- Output to draw to screen
debugOutput = {
	{"X", getXPosition},
	{"Z", getZPosition},
	{"Y", getYPosition},
	{"-", 1},
	{"Y Velocity", getYVelocity},
	{"Separator", 1},
	{"Levitating", getisLevitating},
};

-- Draw debug text
function drawDebug()
	local row = 0;
	local outputX = 2;
	local outputY = 70;

	for i = 1, #debugOutput do
		local label = debugOutput[i][1];
		local value = debugOutput[i][2];

		if label ~= "-" then
			-- Get the value
			if type(value) == "function" then
				value = value();
			end

			-- Round the value
			if type(value) == "number" then
				value = round(value, precision);
			end

			gui.text(outputX, outputY + 16 * row, label..": "..value);
		else
			if type(value) == "number" and value > 1 then
				row = row + value - 1;
			end
		end
		row = row + 1;
	end
end

-- Main
while true do
	drawDebug();
	emu.yield();
	getInput();
end