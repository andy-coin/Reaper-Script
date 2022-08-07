  
  r=reaper
  
  local function main()
      
      local Tn=reaper.CountTracks(0)
      local In=reaper.CountMediaItems(0)
      local Env=reaper.GetSelectedEnvelope(0)
      
      if Tn==0 and In==0 and not Env then return end
      
      reaper.Undo_BeginBlock()
      
      win=reaper.BR_GetMouseCursorContext()
      if win=="tcp" or win=="mcp" then
         reaper.Main_OnCommand(40296,0)
         reaper.Main_OnCommand(40297,0)
         for abi=1,reaper.CountTracks(0) do
             local tr=reaper.GetTrack(0,abi-1)
             local _,state=reaper.GetTrackState(tr)
             if state<512 then
                reaper.SetTrackSelected(tr,true)
             elseif state >=1024 and state<1536 then
                reaper.SetTrackSelected(tr,true)
             end
         end
      elseif Env then
         reaper.Main_OnCommand(40332,0)
      elseif swin=="arrange" then
         if In ~= 0 then
            reaper.Main_OnCommand(40182,0)
         else
            reaper.Main_OnCommand(40297,0)
            for abi=1,reaper.CountTracks(0) do
                local tr=reaper.GetTrack(0,abi-1)
                local _,state=reaper.GetTrackState(tr)
                if state<512 then
                   reaper.SetTrackSelected(tr,true)
                elseif state >=1024 and state<1536 then
                   reaper.SetTrackSelected(tr,true)
                end
            end
         end
      else
         if In ~= 0 then
            reaper.Main_OnCommand(40289,0)
            for abi=1,reaper.CountTracks(0) do
                local tr=reaper.GetTrack(0,abi-1)
                local _,state=reaper.GetTrackState(tr)
                local parent=reaper.GetParentTrack(tr)
                if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")~=2 then
                   see=true
                elseif state<512 then
                   see=true
                elseif state >=1024 and state<1536 then
                   see=true
                end
                if see then
                   it_n=reaper.CountTrackMediaItems(tr)
                   for abii=1,it_n do
                       local item=reaper.GetTrackMediaItem(tr,abii-1)
                       reaper.SetMediaItemSelected(item,true)
                   end
                end
             end
             reaper.UpdateArrange()
         else
            reaper.Main_OnCommand(40297,0)
            for abi=1,reaper.CountTracks(0) do
                local tr=reaper.GetTrack(0,abi-1)
                local _,state=reaper.GetTrackState(tr)
                parent=reaper.GetParentTrack(tr)
                if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")~=2 then
                   reaper.SetTrackSelected(tr,true)
                elseif state<512 then
                   reaper.SetTrackSelected(tr,true)
                elseif state >=1024 and state<1536 then
                   reaper.SetTrackSelected(tr,true)
                end
            end
         end
      end
          
      reaper.Undo_EndBlock("Select all",-1)
  
  end
  
  main()
  
