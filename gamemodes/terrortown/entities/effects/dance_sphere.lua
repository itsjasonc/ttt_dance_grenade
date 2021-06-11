
local model_orb = Model("models/Combine_Helicopter/helicopter_bomb01.mdl")

function EFFECT:Init(data)
   self:SetPos(data:GetOrigin())

   self.Radius = data:GetRadius()

   local rh = self.Radius
   self:SetRenderBounds(Vector(-rh, -rh, -rh), Vector(rh, rh, rh))

   self.EndTime = CurTime() + data:GetScale()
   self.FadeTime = data:GetMagnitude()

   self.FadeIn   = CurTime() + self.FadeTime
   self.FadeOut  = self.EndTime - self.FadeTime

   self.Alpha = 0

   self.Orb = ClientsideModel(model_orb, RENDERGROUP_TRANSLUCENT)
   self.Orb:SetPos(data:GetOrigin())
   self.Orb:AddEffects(EF_NODRAW)
   
   self.Red = 0
   self.Green = 0
   self.Blue = 0

   local r = 28 / 2 -- hardcoded because stuff like :BoundingRadius won't work here

   self.EndScale = self.Radius / r
end

function EFFECT:Think()
   if self.EndTime < CurTime() then
      SafeRemoveEntity(self.Orb)
      return false
   end

   if self.FadeIn > CurTime() then
      self.Alpha = 1 - ((self.FadeIn - CurTime()) / self.FadeTime)
   elseif self.FadeOut < CurTime() then
      self.Alpha = 1 - ((CurTime() - self.FadeOut) / self.FadeTime)
   end

   self.Orb:SetModelScale(self.EndScale * self.Alpha, 0)
   self.Red = math.random()
   self.Green = math.random()
   self.Blue = math.random()
   
   if self.Red > 0.5 then self.Red = 1 else self.Red = 0 end
   if self.Green > 0.5 then self.Green = 1 else self.Green = 0 end
   if self.Blue > 0.5 then self.Blue = 1 else self.Blue = 0 end

   local ang = self.Orb:GetAngles()
   ang.y = ang.y + 500 * FrameTime()
   self.Orb:SetAngles(ang)

   return IsValid(self.Orb)
end

local mat_orb = Material("models/effects/splodearc_sheet")
function EFFECT:Render()
   render.MaterialOverride(mat_orb)
   render.SuppressEngineLighting( true )
   render.SetColorModulation(self.Red, self.Green, self.Blue)
   render.SetBlend(1.0 * self.Alpha)

   self.Orb:DrawModel()

   render.SetBlend(1)
   render.SetColorModulation(1, 1, 1)
   render.SuppressEngineLighting(false)
   render.MaterialOverride()
end

