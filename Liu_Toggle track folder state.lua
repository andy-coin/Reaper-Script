  r=reaper
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local trackzzz={}
  local trackzz={}
  local trackz={}
  local function SaveSelectedTracks (table)--trackzzz
      for i = 0, reaper.CountSelectedTracks(0)-1 do
        table[i+1] = reaper.GetSelectedTrack(0, i)
      end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
      reaper.Main_OnCommand(40297,0)
      if #table==0 then return end
      reaper.SetOnlyTrackSelected(table[#table])
      for _, track in ipairs(table) do
        reaper.SetTrackSelected(track, true)
      end
  end
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  itemzzz = {}
  item_L = {}
  local function SaveSelectedItems (table)--itemzzz
      for i = 0, reaper.CountSelectedMediaItems(0)-1 do
        table[i+1] = reaper.GetSelectedMediaItem(0, i)
      end
  end
  
  ----------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  
  local function RestoreSelectedItems (table)--itemzzz
      reaper.Main_OnCommand(40289, 0) 
      for _, item in ipairs(table) do
        reaper.SetMediaItemSelected(item, true)
      end
  end
  
  ----------------------------------CHANGE FOLDER STATE------------------------------------
  
  local function FollowParentTCPH(track)
    
    cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
    reaper.Main_OnCommand(cmd,0)--minimize
    TCPH=reaper.GetMediaTrackInfo_Value(track,"I_TCPH")
    for abi=1,(TCPH-22)/2 do
        reaper.Main_OnCommand(41327,0)
    end
    
  end
  
  local function TrackState(tr)
  
      --normal
      if nil == reaper.GetParentTrack(tr) 
         and 0 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then
         return -1
         
      elseif nil ~= reaper.GetParentTrack(tr) then
         --children
         if 1 ~= reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then 
            return 0
            
         --parent[Abi]
         elseif 1 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then 
            return 1
         end
        
      --parent[Abi]
      elseif nil == reaper.GetParentTrack(tr) 
         and 1 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then 
         return 1
      end
      
  end 
  
--reaper.ShowConsoleMsg(TrackState().."|")

  ----------------------------------------------------------------------------------
  local function SetChildRecUnArm()
  
      tr_n=reaper.CountSelectedTracks(0)
      local tr={}
      for abi=1,tr_n do
          tr[abi]=reaper.GetSelectedTrack(0,abi-1)  
      end
      
      for abi=1,#tr do
          if reaper.GetMediaTrackInfo_Value(tr[abi],"I_FOLDERDEPTH")==1 then
             abii=0
             idx=reaper.GetMediaTrackInfo_Value(tr[abi],"IP_TRACKNUMBER")
             repeat
                 child=reaper.GetTrack(0,idx+abii)
                 reaper.SetMediaTrackInfo_Value(child,"I_RECARM",0)
                 reaper.SetMediaTrackInfo_Value(child,"B_AUTO_RECARM",0)
                 if reaper.GetMediaTrackInfo_Value(child,"I_FOLDERDEPTH")<=-1 then
                    break
                 end
                 abii=abii+1
             until abii==500
          end
      end
  
  end
  
  ----------------------------------------------------------------------------------
  local function main()
  
  reaper.PreventUIRefresh(-1)
  SaveSelectedTracks (trackzzz)
  SaveSelectedItems (itemzzz)
    
    parent={}
    
    for Abi=1,reaper.CountSelectedTracks(0) do
    
        tr=reaper.GetSelectedTrack(0,Abi-1)
        
        if 1 == TrackState(tr) then 
            parent[#parent+1]=tr
        elseif 0 == TrackState(tr) then
            tr=reaper.GetParentTrack(tr)
            if parent[#parent]~=tr then
               parent[#parent+1]=tr
            end
        end
    end
    
    if #parent==0 then
       last_item = reaper.GetSelectedMediaItem(0,0)
       if last_item then 
          tr=reaper.GetMediaItemTrack(last_item)
       else
          return 
       end
           
       if -1 == TrackState(tr) then return end
           
       if 0 == TrackState(tr) then 
          local tr=reaper.GetParentTrack(tr)
          parent[1]=tr
       end
    end
    
    for Abi=1,#parent do
        reaper.SetOnlyTrackSelected(parent[Abi])
        _,layout=reaper.GetSetMediaTrackInfo_String(parent[Abi],"P_TCP_LAYOUT","",false)
        B_AUTO=reaper.GetMediaTrackInfo_Value(parent[Abi],"B_AUTO_RECARM")
        if layout=="d3 ------ Red Fader" then
           SetChildRecUnArm()
           cmd=reaper.NamedCommandLookup("_SWS_SELCHILDREN")
           reaper.Main_OnCommand(cmd,0)--select only children track
           for abi=1,reaper.CountSelectedTracks(0) do
               child=reaper.GetSelectedTrack(0,abi-1)
               reaper.SetMediaTrackInfo_Value(child,"B_AUTO_RECARM",B_AUTO)
           end
           local last=reaper.GetSelectedTrack(0,reaper.CountSelectedTracks(0)-1)
           local _,state=reaper.GetTrackState(last)
           reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",0)
           if state>=512 and state <1024 then
              cmd=reaper.NamedCommandLookup("_SWSTL_SHOWTCP")
              reaper.Main_OnCommand(cmd,0)
              FollowParentTCPH(parent[Abi])
           elseif state>=1024 and state<1536 then
              cmd=reaper.NamedCommandLookup("_SWSTL_SHOWMCP")
              reaper.Main_OnCommand(cmd,0)
              FollowParentTCPH(parent[Abi])
           elseif state>=1536 then
              cmd=reaper.NamedCommandLookup("_SWSTL_BOTH")
              reaper.Main_OnCommand(cmd,0)
              FollowParentTCPH(parent[Abi])
           else
              reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",2)
              reaper.Main_OnCommand(41593,0)--hide track in TCP and MCP
           end
           reaper.Main_OnCommand(40730,0)--mute tracks
           
        else
        
          reaper.Main_OnCommand(40289,0)--unselect all items
          
          if 0 == reaper.GetMediaTrackInfo_Value(parent[Abi], "I_FOLDERCOMPACT") then
                
                cmd=reaper.NamedCommandLookup("_SWS_SELCHILDREN")
                reaper.Main_OnCommand(cmd,0)--select only children track
                cmd = reaper.NamedCommandLookup("_SWS_SELLOCKITEMS2")
                reaper.Main_OnCommand(cmd,0)--select lock items
                
                if reaper.GetSelectedMediaItem(0,0) then
                  cmd = reaper.NamedCommandLookup("_SWS_SAVESELITEMS1")
                  reaper.Main_OnCommand(cmd,0)--save items
                else
                  reaper.Main_OnCommand(40289,0)--unselect all items
                  cmd = reaper.NamedCommandLookup("_SWS_SAVESELITEMS1")
                  reaper.Main_OnCommand(cmd,0)--save items
                end
                
                --[[if 4 < reaper.CountSelectedTracks(0) then
                  
                  cmd = reaper.NamedCommandLookup("_SWS_SELparent[Abi]S")
                  reaper.Main_OnCommand(cmd,0)--select only parent[Abi] 
                  reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",2)
                else--]]
                  cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
                  reaper.Main_OnCommand(cmd,0)--minimize
                  reaper.Main_OnCommand(cmd,0)--select only parent[Abi] 
                  --reaper.SetMediaTrackInfo_Value(tr,"I_FOLDERCOMPACT",2)
                  reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",1)
                --end
                
              cmd = reaper.NamedCommandLookup("_SWS_SELCHILDREN")
              reaper.Main_OnCommand(cmd,0)--select only children track
              reaper.Main_OnCommand(40421,0)--select all items in track
              reaper.Main_OnCommand(40688,0)--lock item
              
          elseif 1 == reaper.GetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT") then
          
              reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",2)
              SetChildRecUnArm()
              cmd = reaper.NamedCommandLookup("_SWS_SELCHILDREN")
              reaper.Main_OnCommand(cmd,0)--select only children track
              cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
              reaper.Main_OnCommand(cmd,0)--minimize
              reaper.Main_OnCommand(40421,0)--select all items in track
              reaper.Main_OnCommand(40688,0)--lock item 
              
          elseif 2 == reaper.GetMediaTrackInfo_Value(parent[Abi], "I_FOLDERCOMPACT") then
              
              reaper.SetMediaTrackInfo_Value(parent[Abi],"I_FOLDERCOMPACT",0)
              
              cmd = reaper.NamedCommandLookup("_SWS_SELCHILDREN")
              reaper.Main_OnCommand(cmd,0)--select only children track
              for abi=1,reaper.CountSelectedTracks(0) do
                  child=reaper.GetSelectedTrack(0,abi-1)
                  reaper.SetMediaTrackInfo_Value(child,"B_AUTO_RECARM",B_AUTO)
              end
              TCPH=reaper.GetMediaTrackInfo_Value(parent[Abi],"I_TCPH")
              FollowParentTCPH(parent[Abi])
              reaper.Main_OnCommand(40421,0)--select all items in track
              reaper.Main_OnCommand(40689,0)--unlock item
              reaper.Main_OnCommand(40289,0)--unselect all items
              
              cmd = reaper.NamedCommandLookup("_SWS_RESTSELITEMS1")
              reaper.Main_OnCommand(cmd,0)--restore items
              reaper.Main_OnCommand(40688,0)--lock item
          end
        end
    
    end
    
    RestoreSelectedTracks (trackzzz)
    RestoreSelectedItems (itemzzz)      
    reaper.PreventUIRefresh(1)
  end
  
  reaper.defer(main)
