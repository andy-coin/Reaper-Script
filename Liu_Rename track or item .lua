  
  r=reaper
  
  local function main()
  
      win,seg,detial=reaper.BR_GetMouseCursorContext()
      it=reaper.CountSelectedMediaItems(0)
      tr=reaper.CountSelectedTracks(0)
      
      if it==0 and tr==0 then return end

      if tr~=0 and detial~="item" and detial~="item_stretch_marker" then
         track=reaper.GetSelectedTrack(0,0)
         _,ori_name=reaper.GetSetMediaTrackInfo_String(track,"P_NAME","",false)
         if tr==1 then
            ok, csv = reaper.GetUserInputs("Rename "..tr.." track",1,
            ",extrawidth=100",ori_name)
         else
            ok, csv = reaper.GetUserInputs("Rename "..tr.." tracks",1,
            ",extrawidth=100",ori_name)
         end
         if not ok then return end
         new_name=csv:match("^(.*)$")
         reaper.GetSetMediaTrackInfo_String(track,"P_NAME",new_name,true)
         for abi=1,tr-1 do
             track=reaper.GetSelectedTrack(0,abi)
             reaper.GetSetMediaTrackInfo_String(track,"P_NAME",new_name,true)
         end
      elseif it~=0 or detial=="item" or detial=="item_stretch_marker" then
         item=reaper.GetSelectedMediaItem(0,0)
         take=reaper.GetActiveTake(item)
         _,ori_name=reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME","",false)
         if it==1 then
            ok, csv = reaper.GetUserInputs("Rename "..it.." item",1,
            ",extrawidth=100",ori_name)
         else
            ok, csv = reaper.GetUserInputs("Rename "..it.." items",1,
            ",extrawidth=100",ori_name)
         end
         if not ok then return end
         new_name=csv:match("^(.*)$")
         reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",new_name,true)
         for abi=1,it-1 do
             item=reaper.GetSelectedMediaItem(0,abi)
             take=reaper.GetActiveTake(item)
             reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",new_name,true)
         end
      end
      
  end 
  
  main()
