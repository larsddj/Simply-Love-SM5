-- don't allow MeasureCounter to appear in Casual gamemode via profile settings
if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local song = GAMESTATE:GetCurrentSong()
local song_dir = GAMESTATE:GetCurrentSong():GetSongDir()
local steps = GAMESTATE:GetCurrentSteps(player)
local steps_type = ToEnumShortString( steps:GetStepsType() ):gsub("_", "-"):lower()
local difficulty = ToEnumShortString( steps:GetDifficulty() )
local currentStreamNumberP2 = 1 
local currentStreamNumberP1 = 1
local bdown1, bdown2
local seperateStreams2, seperateStreams1
local PlayerState = GAMESTATE:GetPlayerState(player)
local streams, current_measure, previous_measure, MeasureCounterBMT, sideBdown21, sideBdown22, sideBdown2BMT
local current_count, stream_index, current_stream_length, defaultMText, subtractMText, sideText, text
local actorAmount = 1
local mTextArray1 ,mTextArray2

-- We'll want to reset each of these values for each new song in the case of CourseMode
local function InitializeMeasureCounter()
	streams = SL[pn].Streams
	current_count = 0
	stream_index = 1
	current_stream_length = 0
	previous_measure = nil
	mTextArray2 = {}
	mTextArray1 = {}
	actorAmount = 1

	-- We need to split up the breakdown into individual streams for individual players
	if player == PLAYER_2 then
		bdown2 = GetStreamBreakdown(song_dir, steps_type, difficulty)
		seperateStreams2 = Splitter(bdown2, sep)
	else
		bdown1 = GetStreamBreakdown(song_dir, steps_type, difficulty)
		seperateStreams1 = Splitter(bdown1, sep)
	end

	-- Fills the array that's used to gather the string contents
	-- Check what player is using the breakdown view to avoid using the same array for different charts in 2 player mode
	-- TO-DO rewrite duplicate code with functions	
	if player == PLAYER_2 then
		for i=0,5 do	
			if (seperateStreams2[currentStreamNumberP2+i]) ~= nil then	
					mTextArray2[currentStreamNumberP2+i] = seperateStreams2[currentStreamNumberP2+i]
			else
					mTextArray2[currentStreamNumberP2+i] = " "
			end
		end
	else
		for i=0,5 do	
			if (seperateStreams1[currentStreamNumberP1+i]) ~= nil then	
					mTextArray1[currentStreamNumberP1+i] = seperateStreams1[currentStreamNumberP1+i]
			else
					mTextArray1[currentStreamNumberP1+i] = " "
			end
		end
	end

end

-- Splitter function that is used to split the breakdown into individual streams
function Splitter(inputstr, sep)
	if sep == nil then
			sep = "/"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end



local function Update(self, delta)

	if not streams.Measures then return end

	current_measure = (math.floor(PlayerState:GetSongPosition():GetSongBeatVisible()))/4

	-- previous_measure will initially be nil; set it to be the same as current_measure
	if not previous_measure then previous_measure = current_measure end

	local new_measure_has_occurred = current_measure > previous_measure

	if new_measure_has_occurred then

		previous_measure = current_measure

		-- if the current measure is within the scope of the current stream
		if streams.Measures[stream_index]
		and current_measure >= streams.Measures[stream_index].streamStart
		and current_measure <= streams.Measures[stream_index].streamEnd then
			current_stream_length = streams.Measures[stream_index].streamEnd - streams.Measures[stream_index].streamStart
			current_count = math.floor(current_measure - streams.Measures[stream_index].streamStart) + 1

			-- Checks MeasureCounterStyle and set next measuretext
			if mods.MeasureCounterStyle == "Traditional" then
				stream_left = tostring(current_count .. "/" .. current_stream_length)
			elseif mods.MeasureCounterStyle == "Subtraction" then
				stream_left = current_stream_length - current_count + 1
			elseif mods.MeasureCounterStyle == "Both" then
				subtractMText = tostring(current_stream_length - current_count + 1)
				defaultMText = tostring("/" .. current_stream_length)
				stream_left = subtractMText .. defaultMText
			else
				stream_left = ""
			end

			if mods.BreakDownDisplay and mods.BreakDownDisplay ~= "Off" then

				if player == PLAYER_2 then
					for i=0,5 do	
						if (seperateStreams2[currentStreamNumberP2+i]) ~= nil then	
								mTextArray2[currentStreamNumberP2+i] = seperateStreams2[currentStreamNumberP2+i]
						else
								mTextArray2[currentStreamNumberP2+i] = " "
						end
					end
				else
					for i=0,5 do
						if (seperateStreams1[currentStreamNumberP1+i]) ~= nil then	
								mTextArray1[currentStreamNumberP1+i] = seperateStreams1[currentStreamNumberP1+i]
						else
								mTextArray1[currentStreamNumberP1+i] = " "
						end
					end
				end
					
				if player == PLAYER_2 then
					sideBdown22 = tostring(">"..mTextArray2[currentStreamNumberP2].."  ".. '\n' ..mTextArray2[currentStreamNumberP2+1]..'\n'..mTextArray2[currentStreamNumberP2+2].. '\n'..mTextArray2[currentStreamNumberP2+3].. '\n'..mTextArray2[currentStreamNumberP2+4])
				else
					sideBdown21 = tostring(">"..mTextArray1[currentStreamNumberP1].."  ".. '\n' ..mTextArray1[currentStreamNumberP1+1]..'\n'..mTextArray1[currentStreamNumberP1+2].. '\n'..mTextArray1[currentStreamNumberP1+3].. '\n'..mTextArray1[currentStreamNumberP1+4])
				end
				if player == PLAYER_2 then
					sideBdown2BMT:settext(sideBdown22)
				else
					SCREENMAN:SystemMessage(mTextArray1[1])
					sideBdown2BMT:settext(sideBdown21)
				end
			end
			text = tostring(stream_left)
			if mods.MeasureCounter and mods.MeasureCounter ~= "None" then
				MeasureCounterBMT:settext( text )
			end

			if current_count > current_stream_length then
				if mods.BreakDownDisplay and mods.BreakDownDisplay ~= "Off" then
					if player == PLAYER_2 then
						sideBdown2BMT:settext(mTextArray2[currentStreamNumberP2+1].. '\n' ..mTextArray2[currentStreamNumberP2+2]..'\n'..mTextArray2[currentStreamNumberP2+3].. '\n'..mTextArray2[currentStreamNumberP2+4].. '\n'..mTextArray2[currentStreamNumberP2+5])
					else
						sideBdown2BMT:settext(mTextArray1[currentStreamNumberP1+1].. '\n' ..mTextArray1[currentStreamNumberP1+2]..'\n'..mTextArray1[currentStreamNumberP1+3].. '\n'..mTextArray1[currentStreamNumberP1+4].. '\n'..mTextArray1[currentStreamNumberP1+5])
					end
				end
				stream_index = stream_index + 1
				if player == PLAYER_2 then
					currentStreamNumberP2 = currentStreamNumberP2 + 1
				else
					currentStreamNumberP1 = currentStreamNumberP1 + 1
				end
				if mods.MeasureCounter and mods.MeasureCounter ~= "None" then
					MeasureCounterBMT:settext( "" )
				end
			end

		else
			if mods.BreakDownDisplay and mods.BreakDownDisplay ~= "Off" then
				if player == PLAYER_2 then
					sideBdown2BMT:settext(mTextArray2[currentStreamNumberP2].. '\n' ..mTextArray2[currentStreamNumberP2+1]..'\n'..mTextArray2[currentStreamNumberP2+2].. '\n'..mTextArray2[currentStreamNumberP2+3].. '\n'..mTextArray2[currentStreamNumberP2+4])
				else
					sideBdown2BMT:settext(mTextArray1[currentStreamNumberP1].. '\n' ..mTextArray1[currentStreamNumberP1+1]..'\n'..mTextArray1[currentStreamNumberP1+2].. '\n'..mTextArray1[currentStreamNumberP1+3].. '\n'..mTextArray1[currentStreamNumberP1+4])
				end

			end
			if mods.MeasureCounter and mods.MeasureCounter ~= "None" then
				MeasureCounterBMT:settext( "" )
			end
		end
	end

	return
end

	local af = Def.ActorFrame{
		InitCommand=function(self)
			self:queuecommand("SetUpdate")
		end,
		CurrentSongChangedMessageCommand=function(self)
			InitializeMeasureCounter()
		end,
		SetUpdateCommand=function(self)
			self:SetUpdateFunction( Update )
		end
	}

	if mods.MeasureCounter and mods.MeasureCounter ~= "None" then

	actorAmount = actorAmount + 1
	af[#af+actorAmount] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			MeasureCounterBMT = self
			local width = GAMESTATE:GetCurrentStyle(player):GetWidth(player)
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			
			-- Set the size of the measure counter according to the size mod
			if mods.MeasureCounterSize == "Big" then
				self:zoom(0.5):shadowlength(1):horizalign(center)
			elseif mods.MeasureCounterSize == "Humongous" then
				self:zoom(0.75):shadowlength(1):horizalign(center)
			else
				self:zoom(0.35):shadowlength(1):horizalign(center)
			end

			-- Set the position for the measurecounter according to the selected X and Y axis mods
			if mods.MeasureCounterPositionX == "Center" and mods.MeasureCounterPositionY == "Below" then
				self:xy( GetNotefieldX(player), _screen.cy )
			elseif mods.MeasureCounterPositionX == "Center" and mods.MeasureCounterPositionY == "Above" then
				self:xy( GetNotefieldX(player), _screen.cy - _screen.cy/4 )
			elseif mods.MeasureCounterPositionX == "Left" and mods.MeasureCounterPositionY == "Below" then
				self:xy( GetNotefieldX(player) - (width/NumColumns), _screen.cy)
			else
				self:xy( GetNotefieldX(player) - (width/NumColumns), _screen.cy - _screen.cy/4 )
			end
		end
	}
	if mods.BreakDownDisplay == "Off" then
		return af
	end
end

if mods.BreakDownDisplay and mods.BreakDownDisplay ~= "Off" then
	actorAmount = actorAmount + 1
	af[#af+actorAmount] = Def.BitmapText{
		Font="_wendy small",
		InitCommand=function(self)
			sideBdown2BMT = self
			local width = GAMESTATE:GetCurrentStyle(player):GetWidth(player)
			local NumColumns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
			
			-- TO-DO create custom size settings
				self:zoom(0.75):shadowlength(1):horizalign(center)

			-- TO-DO create custom position settings 
				self:xy( GetNotefieldX(player) - (width/1.7), _screen.cy + _screen.cy/4)

		end
	}
	return af

else
	return Def.Actor{}
end
