AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BogeyDistance = 650 -- Needed for gm trainspawner
ENT.SyncTable = {
    "SFV1","SFV2","SFV3","SFV4","SFV5","SFV6","SFV7","SFV8","SFV9","SFV10","SFV11",
    "SFV12","SFV13","SFV14","SFV15","SFV16","SFV17","SFV18","SFV19","SFV20","SFV21","SFV22",
    "SFV23","SFV24","SFV25","SFV26","SFV27","SFV28","SFV29","SFV30","SFV31","SFV32","SFV33",
    "RearBrakeLineIsolation","RearTrainLineIsolation",
    "FrontBrakeLineIsolation","FrontTrainLineIsolation","Battery",
    "GV",
}
--------------------------------------------------------------------------------
function ENT:Initialize()
    -- Set model and initialize
    self:SetModel("models/metrostroi_train/81-741/body/81-741_4_defualt_mos_front.mdl")
	--self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self.BaseClass.Initialize(self)
    self:SetPos(self:GetPos() + Vector(0,0,140))
	
    self.NormalMass = 24000	

    -- Prop-protection related
    if CPPI and IsValid(self.Owner) then
        self:CPPISetOwner(self.Owner)
    end


    -- Get default train mass
    if IsValid(self:GetPhysicsObject()) then
        self.NormalMass = self:GetPhysicsObject():GetMass()
    end
    	

    -- Create seat entities
    self.DriverSeat = self:CreateSeat("instructor",Vector(610,11,-35))

    -- Hide seats
    self.DriverSeat:SetRenderMode(RENDERMODE_TRANSALPHA)
    self.DriverSeat:SetColor(Color(0,0,0,0))

    -- Create bogeys
        self.FrontBogey = self:CreateBogey(Vector( 520,0,-75),Angle(0,180,0),true,"740")
--------------------------------------------------------------------------------
        self.RearBogey  = self:CreateBogey(Vector(-520,0,-75),Angle(0,0,0),true,"740NOTR") --110 0 -80  
		self.RearBogey:PhysicsInit(SOLID_VPHYSICS)		
		
		self.FrontBogey:SetNWInt("MotorSoundType",2)
		self.RearBogey:SetNWInt("MotorSoundType",2)		
	    self.RearBogey.DisableContacts = true		
--------------------------------------------------------------------------------
        self.FrontCouple = self:CreateCouple(Vector(610,0,-60),Angle(0,0,0),true,"717")
--------------------------------------------------------------------------------
        self.RearCouple  = self:CreateCouple(Vector(-610,0,-60),Angle(0,-180,0),false,"740")
		self.RearCouple:SetModel("models/metrostroi_train/81-740/bogey/metro_couple_740.mdl") --
		self.RearCouple:PhysicsInit(SOLID_VPHYSICS)
		self.RearCouple:GetPhysicsObject():SetMass(5000)
	
	self:SetNW2Entity("FrontBogey",self.FrontBogey)
	self:SetNW2Entity("RearBogey",self.RearBogey)
	self:SetNW2Entity("FrontCouple",self.FrontCouple)
	self:SetNW2Entity("RearCouple",self.RearCouple)
	
	self.FrontBogey:SetNWBool("Async",true)
    self.RearBogey:SetNWBool("Async",true)

    local rand = math.random()*0.05
    self.FrontBogey:SetNWFloat("SqualPitch",1.45+rand)
    self.RearBogey:SetNWFloat("SqualPitch",1.45+rand)
--------------------------------------------------------------------------------		
	timer.Simple(0.0, function()
		local rand = math.random()*0.05
		self.MiddleBogey = self:CreateBogey(Vector(-1,0,-75),Angle(0,0,0),true,"740G")--??????????????  ---160,0,-75 -410,0,-75
		self.MiddleBogey:SetNWFloat("SqualPitch",1.45+rand)
		self:SetNW2Entity("MiddleBogey",self.MiddleBogey)
		self.MiddleBogey:SetNWInt("MotorSoundType",2)
		self.MiddleBogey:SetNWInt("Async",true)
		self.MiddleBogey:SetNWBool("DisableEngines",true)			
		self.MiddleBogey.DisableSound = 1			
		self.MiddleBogey:PhysicsInit(SOLID_VPHYSICS)		
		constraint.AdvBallsocket( 
		self,
		self.MiddleBogey,
		0, --bone
		0, --bone
		Vector(0,0,0), --Vector(70,0,90)
		Vector(0,0,0), --Vector(80,0,90)
		0, --forcelimit
		0, --torquelimit
		
		0, --xmin
		0, --ymin
		-180, --zmin
		
		0, --xmax
		0, --ymax
		180, --zmax
		
		0, --yfric
		0, --zfric
		0, --xfric
		0, --rotonly
		1 --nocollide
	)
end)	
timer.Simple(0.0, function()	
	self.Rear1 = self:CreateRear1(Vector(-325,0,0),Angle(0,0,0)) --??????????
end) 
--------------------------------------------------------------------------------	
    -- Initialize key mapping
    self.KeyMap = {
        [KEY_F] = "PneumaticBrakeUp",
        [KEY_R] = "PneumaticBrakeDown",
        [KEY_PAD_1] = "PneumaticBrakeSet1",
        [KEY_PAD_2] = "PneumaticBrakeSet2",
        [KEY_PAD_3] = "PneumaticBrakeSet3",
        [KEY_PAD_4] = "PneumaticBrakeSet4",
        [KEY_PAD_5] = "PneumaticBrakeSet5",
        [KEY_PAD_6] = "PneumaticBrakeSet6",
    }
    -- Cross connections in train wires
    self.TrainWireCrossConnections = {
        [4] = 3, -- Orientation F<->B
        [13] = 12, -- Reverser F<->B
        [38] = 37, -- Doors L<->R
    }
-- ???????? ????????????????????????????
    self.InteractionZones = {
        {
            ID = "FrontBrakeLineIsolationToggle",
            Pos = Vector(463.4, -22, -60), Radius = 16,
        },
        {
            ID = "FrontTrainLineIsolationToggle",
            Pos = Vector(463.4, 22, -60), Radius = 16,
        },
        {
            ID = "RearBrakeLineIsolationToggle",
            Pos = Vector(-470, 30, -60), Radius = 16,
        },
        {
            ID = "RearTrainLineIsolationToggle",
            Pos = Vector(-470, -30, -60), Radius = 16,
        },
        {
            ID = "RearDoor",
            Pos = Vector(-654,-15,54.2), Radius = 20,
        },
        {
            ID = "FrontDoor",
            Pos = Vector(458,30,0), Radius = 20,
        },
        {
            ID = "GVToggle",
            Pos = Vector(128,60,-75), Radius = 20,
        },
        {
            ID = "AirDistributorDisconnectToggle",
            Pos = Vector(-177, -66, -50), Radius = 20,
        },
    }
    self.Lights = {
        -- Interior
        --[11] = { "dynamiclight",  Vector( 200, 0, 10), Angle(0,0,0), Color(255,175,50), brightness = 3, distance = 400 , fov=180,farz = 128
        [15] = { "dynamiclight",    Vector(220, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
        [16] = { "dynamiclight",    Vector(55, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
        [17] = { "dynamiclight",    Vector(640, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
        --[13] = { "dynamiclight",  Vector(-200, 0, 10), Angle(0,0,0), Color(255,175,50), brightness = 3, distance = 400 , fov=180,farz = 128 },
        --[11] = { "dynamiclight",  Vector( 100, 0, 10), Angle(0,0,0), Color(255,175,50), brightness = 3, distance = 400 , fov=180,farz = 128 },
        --[12] = { "dynamiclight",  Vector( 100, 0, 10), Angle(0,0,0), Color(255,175,50), brightness = 3, distance = 400, fov=180,farz = 128 },
		
		[18] = { "dynamiclight",    Vector(-65, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
        [19] = { "dynamiclight",    Vector(-265, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
        [20] = { "dynamiclight",    Vector(-635, 0, 40), Angle(0,0,0), Color(255,220,180), brightness = 3, distance = 500, fov=180,farz = 128 },
    }
    self.FrontDoor = false
    self.RearDoor = false
	
end

function ENT:TrainSpawnerUpdate()
	local MotorType = self:GetNW2Int("MotorType")	
       if MotorType == 1 then
            MotorType = math.ceil(math.random()*1+0.5)
          else MotorType = MotorType-1 end	
	self:SetNW2Int("MotorType",MotorType)	
	self:SetNW2Int("MotorType",math.random(1, 2))		
    --???????????????????????? ?????????? ??????????
	--local ALS = math.random(1, 3)
	--self:SetNW2Int("tablo_color", ALS)
	--print(self:GetNW2String("Texture"))
end	
--------------------------------------------------------------------------------
--????????????????
function ENT:Think()
    local retVal = self.BaseClass.Think(self)
    local power = self.Electric.Battery80V > 62 --??????????????

    if self.BPTI.State < 0 then
        self:SetPackedRatio("RNState", ((self.BPTI.RNState)-0.25)*math.Clamp((math.abs(self.Electric.Itotal/2)-30-self.Speed*2)/20,0,1))
        --self:SetNW2Int("RNFreq", 13)
    else--if self.BPTI.State > 0 then
        self:SetPackedRatio("RNState", (0.75-self.BPTI.RNState)*math.Clamp((math.abs(self.Electric.Itotal/2)-30-self.Speed*2)/20,0,1))
        --self:SetNW2Int("RNFreq", ((self.BPTI.FreqState or 0)-1/3)/(2/3)*12)
    --[[ else
        self:SetPackedRatio("RNState", 0)--]]
    end -- ?????? ?????????????????? ???? ??????????????????


	
		--???????????????? ????????????
		for k,v in pairs(self.Pneumatic.LeftDoorSpeed) do
			self.Pneumatic.LeftDoorSpeed[k] = -2, 12
		end
		
		for k,v in pairs(self.Pneumatic.RightDoorSpeed) do
			self.Pneumatic.RightDoorSpeed[k] = -2, 12
		end
		
    -- ?????????????????? ???????????? ????????????????
    self:SetPackedRatio("Speed", self.Speed)
    self:SetPackedBool("CompressorWork",power and self.Pneumatic.Compressor)
    self:SetPackedBool("Vent2Work",self.Electric.Vent2>0)
    self:SetPackedBool("BBEWork",power and self.BUV.BBE > 0)
	
    self:SetNW2Int("PassSchemesLED",self.PassSchemes.PassSchemeCurr)
    self:SetNW2Int("PassSchemesLEDN",self.PassSchemes.PassSchemeNext)
    self:SetPackedBool("PassSchemesLEDO",self.PassSchemes.PassSchemePath)

    self:SetPackedBool("AnnPlay",self.Panel.AnnouncerPlaying > 0)
	
    self:SetPackedBool("FrontDoor",self.FrontDoor)
    self:SetPackedBool("RearDoor",self.RearDoor)
    --???????? ?? ????????????
    local passlight = power and (self.BUV.MainLights and 1 or self.SFV20.Value > 0.5 and 0.4) or 0
	if self.SFV20.Value == 1 and self.Battery.Value == 1 then end
	
    self:SetLightPower(15,passlight > 0, passlight)
    self:SetLightPower(16,passlight > 0, passlight)
    self:SetLightPower(17,passlight > 0, passlight)
	
	self:SetLightPower(18,passlight > 0, passlight, VAGON)
    self:SetLightPower(19,passlight > 0, passlight, VAGON)
    self:SetLightPower(20,passlight > 0, passlight, VAGON)
    self:SetPackedRatio("SalonLighting",passlight)
    --local mul = self.SF45.Value > 0.5 and self.BUV.MainLights and 1 or self.SF46.Value > 0.5 and 0.5 or 0
    --self:SetLightPower(11,self.BUV.Power and mul > 0, mul)
    --self:SetLightPower(12,self.BUV.Power and mul > 0, mul)
    self.Engines:TriggerInput("Speed",self.Speed)
    --???????????????? ???????????????????? ?? ????????????????    
   if IsValid(self.FrontBogey) and IsValid(self.RearBogey) and IsValid(self.MiddleBogey) and not self.IgnoreEngine then

        local A = 2*self.Engines.BogeyMoment
        self.FrontBogey.MotorForce = (24000+6500*(A < 0 and 1 or 0))--*add--35300+10000*(A < 0 and 1 or 0)
        self.FrontBogey.Reversed = self.KMR2.Value > 0.5
        self.MiddleBogey.MotorForce  = (24000+6500*(A < 0 and 1 or 0))--*add--+5000--35300
        self.MiddleBogey.Reversed = self.KMR1.Value > 0.5
		self.RearBogey.MotorForce  = (24000+6500*(A < 0 and 1 or 0))--*add--+5000--35300
        self.RearBogey.Reversed = self.KMR1.Value > 0.5		

        -- These corrections are required to beat source engine friction at very low values of motor power
        local P = math.max(0,0.04449 + 1.09879*math.abs(A) - 0.565729*A^2)
        if math.abs(A) > 0.4 then P = math.abs(A) end
        if math.abs(A) < 0.05 then P = 0 end
        if self.Speed < 10 then P = P*(1.0 + 0.5*(10.0-self.Speed)/10.0) end
        self.RearBogey.MotorPower  = P*0.5*((A > 0) and 1 or -1)
        self.FrontBogey.MotorPower = P*0.5*((A > 0) and 1 or -1)

        -- Apply brakes
        self.FrontBogey.PneumaticBrakeForce = (50000.0--[[ +5000+10000--]] ) --20000
        self.FrontBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
        self.FrontBogey.ParkingBrakePressure = math.max(0,(3-self.Pneumatic.ParkingBrakePressure)/3)
        self.FrontBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
        self.FrontBogey.DisableContacts = self.BUV.Pant
        self.MiddleBogey.PneumaticBrakeForce = (50000.0--[[ +5000+10000--]] ) --20000
        self.MiddleBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
        self.MiddleBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT
		self.RearBogey.PneumaticBrakeForce = (50000.0--[[ +5000+10000--]] ) --20000
        self.RearBogey.BrakeCylinderPressure = self.Pneumatic.BrakeCylinderPressure
        self.RearBogey.BrakeCylinderPressure_dPdT = -self.Pneumatic.BrakeCylinderPressure_dPdT

    end
    return retVal
end

local function CanConstrain( ent, self )

	if ( !ent )	then return false end
	if ( !ent:IsWorld() && !ent:IsValid() )	then return false end
	if ( !ent:GetPhysicsObjectNum( self ) || !ent:GetPhysicsObjectNum( self ):IsValid() )	then return false end

	return true

end

function ENT:CreateRear1(pos,ang,a)
	local ent = ents.Create("prop_physics")--ents.Create("prop_physics")
	ent:SetModel("models/metrostroi_train/81-741/body/81-741_4_rear_reference.mdl")--ent:SetModel("models/sligwolf/blue-x12/bluex12_train_socket.mdl")	
	ent:SetPos(self:LocalToWorld(pos))
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:SetOwner(self:GetOwner())	
	ent:GetPhysicsObject():SetMass(13000)	
    ent:SetUseType(SIMPLE_USE)		
    -- Assign ownership
    if CPPI and IsValid(self:CPPIGetOwner()) then ent:CPPISetOwner(self:CPPIGetOwner()) end	
	
	self:SetNW2Entity("ent",ent)
	--????????????, ?????????????????? ?? ????????????.
	constraint.AdvBallsocket(
		ent,
		self.RearCouple,
		0, --bone
		0, --bone
		Vector(-320.2+20.8,0,-60),
		Vector(0,0,0),
		1, --forcelimit
		1, --torquelimit
		
		-2, --xmin
		-2, --ymin
		-15, --zmin
		
		2, --xmax
		2, --ymax
		15, --zmax
		
		0.1, --xfric
		0.1, --yfric
		1, --zfric
		
		0, --rotonly
		1 --nocollide
	)
	--?????????????????? ?????????????????? ???????????? ???????????? ?? ????????????.
	constraint.AdvBallsocket(
	ent,
	self.RearBogey,
		0, --bone
		0, --bone
		Vector(-200,0,75),
		Vector(200,0,75),
		0, --forcelimit
		0, --torquelimit
		
		0, --xmin
		0, --ymin
		-180, --zmin
		0, --xmax
		0, --ymax
		180, --zmax
		
		0, --xfric
		0, --yfric
		0, --zfric
		0, --rotonly
		1 --nocollide
	)
--?????????????????? ???????????? ?? ?????????????? ??????????????.
	constraint.AdvBallsocket( 
		self.MiddleBogey,
		ent,
		0, --bone
		0, --bone
		Vector(0,5,70), --Vector(70,0,90)
		Vector(100,5,70), --Vector(80,0,90)
		0, --forcelimit
		0, --torquelimit
		
		-100, --xmin --????????????
		0, --ymin  --?????????????? ??????????/????????????
		-100, --zmin
		
		100, --xmax --????????????
		0, --ymax --20  --?????????????? ??????????/????????????
		100, --zmax
		
		0, --yfric
		0, --zfric
		0, --xfric
		0, --rotonly
		1 --nocollide
	)
	constraint.AdvBallsocket( 
		self.MiddleBogey,
		ent,
		0, --bone
		0, --bone
		Vector(0,-5,70), --Vector(70,0,90)
		Vector(100,-5,70), --Vector(80,0,90)
		0, --forcelimit
		0, --torquelimit
		
		-100, --xmin --????????????
		0, --ymin  --?????????????? ??????????/????????????
		-100, --zmin
		
		100, --xmax --????????????
		0, --ymax --20  --?????????????? ??????????/????????????
		100, --zmax
		
		0, --yfric
		0, --zfric
		0, --xfric
		0, --rotonly
		1 --nocollide
	)
	-- Add to cleanup list
	table.insert(self.TrainEntities,ent)
	return ent
end 

--?????? ???????????? ?????????????????? ??????????
function ENT:OnCouple(train,isfront)
    if isfront and self.FrontAutoCouple then
        self.FrontBrakeLineIsolation:TriggerInput("Open",1.0)
        self.FrontTrainLineIsolation:TriggerInput("Open",1.0)
        self.FrontAutoCouple = false
    elseif not isfront and self.RearAutoCouple then
        self.RearBrakeLineIsolation:TriggerInput("Open",1.0)
        self.RearTrainLineIsolation:TriggerInput("Open",1.0)
        self.RearAutoCouple = false
    end
    self.BaseClass.OnCouple(self,train,isfront)
end
-- WTF
function ENT:OnButtonPress(button,ply)
    if button == "FrontDoor" and (self.FrontDoor or not self.BUV.BlockTorec) then self.FrontDoor = not self.FrontDoor end
    if button == "RearDoor" and (self.RearDoor or not self.BUV.BlockTorec) then self.RearDoor = not self.RearDoor end
end