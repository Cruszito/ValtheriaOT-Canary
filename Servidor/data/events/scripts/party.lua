function Party:onJoin(player)
	local playerUid = player:getGuid()
	addEvent(function(playerFuncUid)
		local playerEvent = Player(playerFuncUid)
		if not playerEvent then
			return
		end
		local party = playerEvent:getParty()
		if not party then
			return
		end
		party:refreshHazard()
	end, 100, playerUid)
	return true
end

function Party:onLeave(player)
	local playerUid = player:getGuid()
	local members = self:getMembers()
	table.insert(members, self:getLeader())
	local memberUids = {}

	for _, member in ipairs(members) do
		if member and member:getGuid() ~= playerUid then
			table.insert(memberUids, member:getGuid())
		end
	end

	addEvent(function(playerFuncUid, memberUidsTableEvent)
		local playerEvent = Player(playerFuncUid)
		if playerEvent then
			playerEvent:updateHazard()
		end

		for _, memberUid in ipairs(memberUidsTableEvent) do
			local member = Player(memberUid)
			if member then
				local party = member:getParty()
				if party then
					party:refreshHazard()
					return -- Only one player needs to refresh the hazard for the party
				end
			end
		end
	end, 100, playerUid, memberUids)

	return true
end

function Party:onDisband()
	local members = self:getMembers()
	local leader = self:getLeader()

	if leader then
		table.insert(members, leader)
	end

	local memberIds = {}

	for _, member in ipairs(members) do
		if member and member:getId() then
			table.insert(memberIds, member:getId())
		end
	end

	addEvent(function()
		for _, memberId in ipairs(memberIds) do
			local member = Player(memberId)
			if member then
				member:updateHazard()
			end
		end
	end, 100)

	return true
end

local partyVocationBonus = {
	[1] = 1.10, -- 1 vocación presente: +10%
	[2] = 1.30, -- 2 vocaciones presentes: +30%
	[3] = 1.60, -- 3 vocaciones presentes: +60%
	[4] = 1.80, -- 4 vocaciones presentes: +80%
	[5] = 2.00, -- 5 vocaciones presentes: +100%
}

local maxPartyBonusMembers = 10

local function getPartyMembersWithLeader(party)
	local members = party:getMembers()
	local leader = party:getLeader()

	if leader then
		table.insert(members, leader)
	end

	return members
end

local function getPartyUniqueBaseVocationsCount(party)
	local members = getPartyMembersWithLeader(party)
	local vocations = {}

	for _, member in ipairs(members) do
		if member and member:isPlayer() then
			local vocation = member:getVocation()
			if vocation then
				local baseVocationId = vocation:getBaseId()

				if baseVocationId and baseVocationId > 0 then
					vocations[baseVocationId] = true
				end
			end
		end
	end

	local count = 0
	for _, _ in pairs(vocations) do
		count = count + 1
	end

	return count
end

function Party:onShareExperience(exp)
	local members = getPartyMembersWithLeader(self)
	local memberCount = #members

	if memberCount <= 0 then
		return math.ceil(exp)
	end

	-- Si hay 11 o más jugadores, se rompe el bonus.
	if memberCount > maxPartyBonusMembers then
		return math.ceil(exp / memberCount)
	end

	local uniqueVocationsCount = getPartyUniqueBaseVocationsCount(self)

	if uniqueVocationsCount > 5 then
		uniqueVocationsCount = 5
	end

	local sharedExperienceMultiplier = partyVocationBonus[uniqueVocationsCount] or 1
	local sharedExp = exp * sharedExperienceMultiplier

	return math.ceil(sharedExp / memberCount)
end