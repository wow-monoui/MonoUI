local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
local _G = _G

local m_AlertMover = CreateFrame("Frame", "m_AlertMover", UIParent, "BackdropTemplate")
m_AlertMover:SetSize(180,20)
m_AlertMover:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 220)

local POSITION, ANCHOR_POINT, YOFFSET = "BOTTOM", "BOTTOM", -10

local function updateAlertFrameAnchors()
  local AlertFrame = _G.AlertFrame
  local GroupLootContainer = _G.GroupLootContainer

	POSITION = pos or POSITION

	if POSITION == 'TOP' then
		ANCHOR_POINT = 'BOTTOM'
		YOFFSET = -10
	else
		ANCHOR_POINT = 'TOP'
		YOFFSET = 10
  end

	AlertFrame:ClearAllPoints()
  AlertFrame:SetAllPoints(m_AlertMover)
  GroupLootContainer:ClearAllPoints()
	GroupLootContainer:SetPoint(POSITION, m_AlertMover, ANCHOR_POINT, 0, YOFFSET)

end
hooksecurefunc(_G.AlertFrame, 'UpdateAnchors', updateAlertFrameAnchors)