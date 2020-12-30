local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

-- Disable talking head
if cfg.automation.talking_head then
  local f = CreateFrame("Frame")
  f:RegisterEvent("TALKINGHEAD_REQUESTED")
  f:SetScript("OnEvent", function()
    if TalkingHeadFrame then
      TalkingHeadFrame:Hide()
    end
  end)
end