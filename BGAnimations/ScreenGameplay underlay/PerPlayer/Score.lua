local player = ...

if SL[ ToEnumShortString(player) ].ActiveModifiers.HideScore then return end

local dance_points, percent
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

return Def.BitmapText{
	Font="_wendy monospace numbers",
	Text="0.00",

	Name=ToEnumShortString(player).."Score",
	InitCommand=function(self)
		self:valign(1):halign(1)
		-- TO-DO rewrite code to seperate each player to avoid funky 2 player score move interactions with density graph hide
		if SL.Global.GameMode == "StomperZ" then
			self:zoom(0.4):x( WideScale(160, 214) ):y(20)
			if player == PLAYER_2 then
				self:x( _screen.w - WideScale(50, 104) )
			end
		else
			self:zoom(0.5):x( _screen.cx - _screen.w/4.3 ):y(56)
			if player == PLAYER_2 then
				self:x( _screen.cx + _screen.w/2.75 )
			end
		end

		if SL[ToEnumShortString(player)].ActiveModifiers.DensityGraph ~= "Disabled" then
			self:xy(_screen.cx + _screen.w/2.625, _screen.cy/10)
			self:zoom(0.4)
		end
	end,
	JudgmentMessageCommand=function(self) self:queuecommand("RedrawScore") end,
	RedrawScoreCommand=function(self)
		dance_points = pss:GetPercentDancePoints()
		percent = FormatPercentScore( dance_points ):sub(1,-2)
		self:settext(percent)
	end
}