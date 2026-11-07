local trainers = {
	[16198] = SKILL_SWORD,
	[16199] = SKILL_AXE,
	[16200] = SKILL_CLUB,
	[16201] = SKILL_DISTANCE,
	[16202] = SKILL_MAGLEVEL,
	[50296] = SKILL_FIST,
}

local selectableTrainerId = 52963

local trainingOptions = {
	{ name = "Sword Fighting", skill = SKILL_SWORD },
	{ name = "Axe Fighting", skill = SKILL_AXE },
	{ name = "Club Fighting", skill = SKILL_CLUB },
	{ name = "Distance Fighting", skill = SKILL_DISTANCE },
	{ name = "Magic Level", skill = SKILL_MAGLEVEL },
	{ name = "Fist Fighting", skill = SKILL_FIST },
}

local function canTrain(player)
	if not player:isPremium() then
		player:sendCancelMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT)
		return false
	end

	if player:isPzLocked() then
		player:sendCancelMessage(RETURNVALUE_YOUMAYNOTLOGOUTDURINGAFIGHT)
		return false
	end

	return true
end

local function beginTraining(player, skill)
	if not canTrain(player) then
		return
	end

	player:setOfflineTrainingSkill(skill)
	player:remove(false)
end

local function createTrainingCallback(skill)
	return function(player, button, choice)
		if button.name ~= "Train" then
			return true
		end

		beginTraining(player, skill)
		return true
	end
end

local function showTrainingWindow(player)
	local window = ModalWindow({
		title = "Offline Training",
		message = "Choose the skill you want to train.\nShielding is always included.",
	})

	for _, option in ipairs(trainingOptions) do
		window:addChoice(
			option.name,
			createTrainingCallback(option.skill)
		)
	end

	window:addButton("Train")
	window:addButton("Cancel")
	window:setDefaultEnterButton(0)
	window:setDefaultEscapeButton(1)
	window:sendToPlayer(player)
end

local skillTrainer = Action()

function skillTrainer.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not canTrain(player) then
		return true
	end

	if item:getId() == selectableTrainerId then
		showTrainingWindow(player)
		return true
	end

	local skill = trainers[item:getId()]
	if skill then
		beginTraining(player, skill)
	end

	return true
end

for itemId in pairs(trainers) do
	skillTrainer:id(itemId)
end

skillTrainer:id(selectableTrainerId)
skillTrainer:register()