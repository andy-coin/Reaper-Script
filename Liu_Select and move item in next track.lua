  
  r=reaper
  
  local function main()
    
      ::Start::
      
      tr=reaper.GetSelectedTrack(0,0)
      idx=reaper.GetMediaTrackInfo_Value(tr,"IP_TRACKNUMBER")
      if idx==reaper.CountTracks(0) then return end
      cur=reaper.GetTrack(0,idx)
      reaper.SetOnlyTrackSelected(cur)
      
      _,state=reaper.GetTrackState(cur)
      parent=reaper.GetParentTrack(cur)
      if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
         hide=true
      elseif state>=512 and state<1024 then
         hide=true
      elseif state>=1536 then
         hide=true
      end
      
      
      if hide then
         hide=nil
         goto Start
      else
         now=reaper.GetSelectedMediaItem(0,0)
         reaper.Main_OnCommand(40289,0)
         if not now then 
            item=reaper.GetTrackMediaItem(cur,0)
            if item then
               reaper.SetMediaItemSelected(item,true)
            end
            goto END 
         end
         P=reaper.GetMediaItemInfo_Value(now,"D_POSITION")
         L=reaper.GetMediaItemInfo_Value(now,"D_LENGTH")
         E=P+L
         C=(E+P)/2
         it_n=reaper.CountTrackMediaItems(cur)
         close=reaper.GetProjectLength(0)
         for abi=1,it_n do
             local item=reaper.GetTrackMediaItem(cur,abi-1)
             p=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
             l=reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
             e=p+l
             c=(e+p)/2
             if math.abs(C-c)<close then
                reaper.Main_OnCommand(40289,0)
                reaper.SetMediaItemSelected(item,true)
                close=math.abs(C-c)
             end
         end
         ::END::
         reaper.SetMixerScroll(cur)
      end
    
  end
  
  reaper.defer(main)
