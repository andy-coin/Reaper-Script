  
  r=reaper
  
  local function main(tr,last_mouse)
      
      char = gfx.getchar()
      mouse=gfx.mouse_cap
      reaper.ShowConsoleMsg(char)
      if mouse%64==64 and last_mouse%64==64 or char==6697264 then
         reaper.SetMediaTrackInfo_Value(tr,"I_SOLO",1)
         reaper.defer(function()main(tr,mouse)end)
      else
         reaper.SetMediaTrackInfo_Value(tr,"I_SOLO",0)
         reaper.defer(function()main(tr,mouse)end)
         --
      end     
      
  end
  
  --[[trackz={}
  tr_n=reaper.CountSelectedTracks(0)
  for abi=1,tr_n do
      trackz[abi]=reaper.GetSelectedTrack(0,abi-1)
  end
  cmd=reaper.NamedCommandLookup("_BR_SAVE_SOLO_MUTE_ALL_TRACKS_SLOT_3")
  reaper.Main_OnCommand(cmd,0)
  reaper.Main_OnCommand(41110,0)
  cur_tr=reaper.GetSelectedTrack(0,0)
  
  main(cur_tr,64)
  cmd=reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_TRACKS_SLOT_3")
  reaper.Main_OnCommand(cmd,0)
  for abi=1,tr_n do
      reaper.SetTrackSelected(trackz[abi],true)
  end--]]
  cur_tr=reaper.GetSelectedTrack(0,0)
  gfx.init("",0,0,0,0,0)
  --main(cur_tr,64)
  --gfx.quit()
