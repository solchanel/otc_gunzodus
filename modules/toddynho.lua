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


potionCast = macro(1000, function()
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