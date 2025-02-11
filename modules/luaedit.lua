--

hotkey("F12", "sell all to npc", function()
	local const_delay = 5000
	if not NPC.isTrading() then	
		schedule(500, function() NPC.say("hi") end)
		schedule(1000, function() NPC.say("trade") end)
	else
		NPC.sellAll()
	end
end)


setDefaultTab("Main")
local potionUsePanelName = "iPotionPanel"
if not storage[potionUsePanelName] then
    storage[potionUsePanelName] = {
        granPotionType = "Knight",
        vocPId = 1,
        potion = false,
    }
end

local potionUse = setupUI([[
PotionsOpComboBoxPopupMenu < ComboBoxPopupMenu
PotionsOpComboBoxPopupMenuButton < ComboBoxPopupMenuButton
PotionsOpComboBox < ComboBox
  @onSetup: |
    self:addOption("Sorcerer", 3)
    self:addOption("Druid", 4)
    self:addOption("Paladin", 2)
    self:addOption("Knight", 1)

Panel
  height: 80
  padding-top: 5

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: parent.top
    margin-bottom: 6

  Label
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: prev.bottom
    text: Potions
    text-align: center
    margin-top: 6

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: prev.bottom
    margin-top: 3
    margin-bottom: 6

  PotionsOpComboBox
    id: PotionsOpType
    anchors.top: prev.bottom
    anchors.right: parent.right
    anchors.left: parent.left
    margin-top: 6
    margin-left: 5
    margin-right: 5

  BotSwitch
    id: potionSwitch
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    text-align: center
    margin-top: 4
    margin-left: 5
    margin-right: 5
    width: 110
    height: 18
    !text: tr('Use Potion')

  ]])


potionUse.PotionsOpType:setOption(storage[potionUsePanelName].granPotionType)
potionUse.PotionsOpType.onOptionChange = function(widget)
    storage[potionUsePanelName].granPotionType = widget:getCurrentOption().text
    storage[potionUsePanelName].vocPId = widget:getCurrentOption().data
end

potionUse.potionSwitch:setOn(storage[potionUsePanelName].potion)
potionUse.potionSwitch.onClick = function(widget)
    storage[potionUsePanelName].potion = not storage[potionUsePanelName].potion
    widget:setOn(storage[potionUsePanelName].potion)
end


potionCast = macro(5000, function()
 if isInPz() or not storage[potionUsePanelName].potion or not TargetBot.isOn() or not g_game.getAttackingCreature() then
   return
 end
  for _, container in pairs(g_game.getContainers()) do
    for i, item in ipairs(container:getItems()) do
     local vocPot = storage[potionUsePanelName].vocPId
     local selfVoc = player:getVocation()
      if selfVoc == vocPot then
        if item:getId() == 7443 and (selfVoc == 2 or selfVoc == 12) then
          return g_game.use(item)
        end
        if item:getId() == 7439 and (selfVoc == 1 or selfVoc == 11) then
          return g_game.use(item)
        end
        if item:getId() == 7440 and (selfVoc == 4 or selfVoc == 14) then
          return g_game.use(item)
        end
        if item:getId() == 7440 and (selfVoc == 3 or selfVoc == 13) then
          return g_game.use(item)
        end
      end
      delay(590000)
    end
  end
end)




UI.Label("Mana training")
if type(storage.manaTrain) ~= "table" then
	storage.manaTrain = {on=false, title="MP%", text="utevo lux", min=80, max=100}
end

local manatrainmacro = macro(1000, function()
	local mana = math.min(100, math.floor(100 * (player:getMana() / player:getMaxMana())))
	if storage.manaTrain.max >= mana and mana >= storage.manaTrain.min then
		say(storage.manaTrain.text)
	end
end)
manatrainmacro.setOn(storage.manaTrain.on)

UI.DualScrollPanel(storage.manaTrain, function(widget, newParams) 
  storage.manaTrain = newParams
  manatrainmacro.setOn(storage.manaTrain.on)
end)



--UI.Label("Manas DP to BP")
if type(storage.manatodp) ~= "table" then
	storage.manatodp = {on=false, title="MP%", text="utevo lux", min=80, max=100}
end

function moveItem(item, destination)
  return g_game.move(item, destination:getSlotPosition(destination:getItemsCount()), item:getCount())
end

local moveFromBp = "backpack" -- name of the bp where you have the items
local moveToBp = "your inbox"  -- name of depo (lower case)
local itemsIdToMove = { 238 } -- ID of items to be transferred to the bp
 
local moveTo = nil

for i, container in pairs(getContainers()) do
 


 if container:getName() == moveToBp and container:getItemsCount() < container:getCapacity() then
    moveTo = container
  end
end

if moveTo then
  for i, container in pairs(getContainers()) do
    if container:getName() == moveFromBp then
      for j, item in pairs(container:getItems()) do
        if table.contains(itemsIdToMove, item:getId()) then
          moveItem(item, moveTo)
          return "retry"
        end
      end
    end
  end
end


local SCREEN_ICON_ID = 237
function get_max_clients()
	local playerCount = 0
	for _, creature in ipairs(getSpectators(pos(), false)) do
		if creature:isPlayer() then
			playerCount = playerCount + 1
		end
	end
	return playerCount
end

local player = macro(2000, "clients on screen", function()
  say("clients " .. get_max_clients() ..)
end)

addIcon("Player Count", { item = { id = SCREEN_ICON_ID }, movable = true }, function(icon, isOn)
  player.setOn(isOn) 
end)


macro(500, "targetting off if others", function() 
	local players = getPlayers()
	
	if #players > 0 then
		CaveBot.setOff()
	else
		CaveBot.setOn()
	end
end)























local function setTargetAndCave(boolean)
  TargetBot.setOn(boolean)
  CaveBot.setOn(boolean)  
end

macro(200, "Attack Players", function()
	local highestAmount = 100  
	local targetPlayer
	for i, creature in ipairs(getSpectators(posz(), false)) do
		if creature:isPlayer() then
			local cname = creature:getName()
			if cname ~= name() and not isFriend(cname) then
				if creature:getShield() < 3 and creature:getEmblem() ~= 1 then
					local valHp = creature:getHealthPercent()
					if valHp <= highestAmount then
						highestAmount = valHp
						targetPlayer = creature
					end
				end
			end
		end
	end
	if targetPlayer then
		if not g_game.isAttacking() or g_game.getAttackingCreature() ~= targetPlayer then
			g_game.attack(targetPlayer)
			setTargetAndCave(false)
		end
	else
		setTargetAndCave(true)
	end
end)

































