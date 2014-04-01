local Reverb%name_cap%= createClassModule("rogueassembly.sounds.effects.reverb%name_lower%")

-- Constructor
-- As this is the definition for a sound effect module, it expects the engine's sound effect as a parameter
-- This effect MUST be filled. In the correct order.
Reverb%name_cap%.Create = function(effectToFill)
  local reverb = {
  }
  setupClassModuleInstance(reverb, Reverb%name_cap%)
  
  -- First of all, set the type
  -- MUST be done before setting the actual values
  effectToFill:setEffectType("reverb")
  
  -- Assign the values specific to this effect
  effectToFill:setDensity(%0%)
  effectToFill:setDiffusion(%1%)
  effectToFill:setGain(%2%)
  effectToFill:setGainHF(%3%)
  effectToFill:setGainLF(%4%)
  effectToFill:setDecayTime(%5%)
  effectToFill:setDecayHFRatio(%6%)
  effectToFill:setDecayLFRatio(%7%)
  effectToFill:setReflectionsGain(%8%)
  effectToFill:setReflectionsDelay(%9%)
  effectToFill:setReflectionsPan(%10%, %11%, %12%)
  effectToFill:setLateReverbGain(%13%)
  effectToFill:setLateReverbDelay(%14%)
  effectToFill:setLateReverbPan(%15%, %16%, %17%)
  effectToFill:setEchoTime(%18%)
  effectToFill:setEchoDepth(%19%)
  effectToFill:setModulationTime(%20%)
  effectToFill:setModulationDepth(%21%)
  effectToFill:setAirAbsorptionGainHF(%22%)
  effectToFill:setHFReference(%23%)
  effectToFill:setLFReference(%24%)
  effectToFill:setRoomRolloffFactor(%25%)
  effectToFill:setDecayHFLimit(%hflimit%)
  
  return reverb
end

return Reverb%name_cap%
