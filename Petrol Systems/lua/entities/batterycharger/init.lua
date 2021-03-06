AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
local RD = CAF.GetAddon("Resource Distribution")
include('shared.lua')



-- Init func ;o
function ENT:Initialize()
	-- Model we will be using
	-- Physics settings
	self.BaseClass.Initialize(self)
	
	-- use stuff
	self.toggle = false -- On or off
	self.togglebouncekil = 3 -- You can only toggle when this is zero!
	
	-- Create a wire input to turn it on!
	if not (WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "On" }) end
	
	-- Resource distribution stuff, Here we define what we are using, creating and destroying
	RD.AddResource(self, "12V Energy", 0)
	RD.AddResource(self, "energy", 0)
	-- **************************************
end


-- Wiremod function!
function ENT:TriggerInput(iname, value)
	if(iname == "On") then
		if(value == 1) then
			self.toggle = true
			self:SetOOO(1)
		else
			self.toggle = false
			self:SetOOO(0)
		end	
	end
end

function ENT:Use()
    -- This stops "Bouncing" Where it toggles off and on really fast
	-- Every think togglebouncekil is decremented till it is 0
	-- at wich point you can toggle
	-- Each time you toggle it's set back to 3, Therefore disallowing control
	-- For a period of time!
	if(self.togglebouncekil == 0) then
		if(self.toggle == false) then
			self.toggle = true
			self.togglebouncekil = 3
			self:SetOOO(1)
			return
		end
		if(self.toggle == true) then
			self.toggle = false
			self.togglebouncekil = 3
			self:SetOOO(0)
			return
		end
	end
end


function ENT:Think()
	self.BaseClass.Think(self)
	
	-- Use key bounce removal variable
	-- It is set to 3 when entity is used, then counts down to zero, 
	-- you can only use entity WHEN it is zero
	if(self.togglebouncekil > 0) then
		self.togglebouncekil = self.togglebouncekil -1
	end
	
	-- We can only charge if we are switched on -_-
	if (self.toggle == true) then
		self.energy = RD.GetResourceAmount(self, "energy")
		if(self.energy > 40)then
			RD.ConsumeResource(self, "energy", 40)
			RD.SupplyResource(self, "12V Energy", 6)
		else
			-- We dont have enough energy, so we turn off... 
			self.toggle = false
			self:SetOOO(0)
		end
	end
	
	self:NextThink( CurTime() + 1 )
	return true
end
