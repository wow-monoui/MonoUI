local _G = getfenv(0);
local LibStub = _G.LibStub;


local name = ... or "m_Communities";

--- @class m_Communities
local m_Communities = LibStub("AceAddon-3.0"):NewAddon(name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");

if not m_Communities then return; end

-- define tables to hold skin functions
m_Communities.blizzFrames = {p = {}, n = {}, u = {}, opt = {}}
m_Communities.blizzLoDFrames = {p = {}, n = {}, u = {}}

function m_Communities:EnhanceCommunities()
  if not _G.CommunitiesFrame then
    _G.C_Timer.After(0.1, function()
      self:EnhanceCommunities()
    end)
    return
  end

  self:SecureHookScript(_G.CommunitiesFrame, "OnShow", function(this)
    self:SecureHookScript(this.MemberList, "OnShow", function(fObj)
      if (fObj.showOfflinePlayers) then

        -- local testMember = fObj.sortedMemberList[20]
        -- for k, v in pairs(testMember) do
        --   local info = C_Club.GetMemberInfo(this:GetSelectedClubId(), testMember.memberId)
        --   local account_info = C_BattleNet.GetAccountInfoByGUID(info.guid)
        --   print(account_info)
        --   for k, v in pairs(info) do
        --     print("\t",k, v)
        --   end
        -- end
        CommunityDB = fObj.sortedMemberList
      end

      self:Unhook(fObj, "OnShow")
    end)
  end)
end

function m_Communities:OnInitialize()
  self.initialized = true;
end

function m_Communities:OnEnable()
  self.enabled = true;
  self:EnhanceCommunities()
end

function m_Communities:OnDisable()
	self:UnregisterAllEvents()
	self.UnregisterAllCallbacks(self)
	self.db.UnregisterAllCallbacks(self)
end
