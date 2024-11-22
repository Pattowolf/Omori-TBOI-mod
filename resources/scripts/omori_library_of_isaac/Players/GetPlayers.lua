function TSIL.Players.GetPlayers(ignoreCoopBabies)
	if ignoreCoopBabies == nil then
		ignoreCoopBabies = true
	end

	local players = {}

	for i = 0, Game():GetNumPlayers() - 1, 1 do
		local player = Game():GetPlayer(i)

		if not ignoreCoopBabies or player.Variant ~= 1 then
			table.insert(players, player)
		end
	end

	return players
end






function TSIL.Players.GetSubPlayerParent(subPlayer)
	local subPlayerPtrHash = GetPtrHash(subPlayer);
	local players = TSIL.Players.GetPlayers();

	return TSIL.Utils.Tables.FindFirst(players, function(_, player)
		local thisPlayerSubPlayer = player:GetSubPlayer()
		if thisPlayerSubPlayer == nil then
			return false
		end

		local thisPlayerSubPlayerPtrHash = GetPtrHash(thisPlayerSubPlayer);
		return thisPlayerSubPlayerPtrHash == subPlayerPtrHash;
	end)
end
