
  r=reaper
  
  local function main()
      
      triplet=reaper.NamedCommandLookup("_SWS_AWTOGGLETRIPLET")
      swing=reaper.NamedCommandLookup("_SWS_AWTOGGLESWING")
      Swing=reaper.NamedCommandLookup("_RS1da5aa836af30a1c8f6fba1f4b7c6a38f7084e9e")
      
      if reaper.GetToggleCommandState(triplet)==0 and  reaper.GetToggleCommandState(swing)==0 then
         Act="Set grid mode to triplet"
         reaper.Main_OnCommand(triplet,0)
         
      elseif reaper.GetToggleCommandState(triplet)==1 and  reaper.GetToggleCommandState(swing)==0 then
         Act="Set grid mode to swing"
         
         reaper.Main_OnCommand(Swing,0)
         
      elseif reaper.GetToggleCommandState(triplet)==0 and  reaper.GetToggleCommandState(swing)==1 then
         Act="Set grid mode to normal"
         reaper.Main_OnCommand(Swing,0)
         
      end
  
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock(Act,-1)
