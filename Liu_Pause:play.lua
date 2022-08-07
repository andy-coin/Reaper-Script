  
  r=reaper
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local trackz={}
  local function SaveSelectedTracks(table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
        table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
    
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks(table)--trackzzz
      reaper.Main_OnCommand(40297,0)
      for _, track in ipairs(table) do
          reaper.SetTrackSelected(track, true)
      end
  end
    
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local itemzzz={}
  local function SaveSelectedItems(table)--trackzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
        table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
  end
    
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedItems(table)--trackzzz
      reaper.Main_OnCommand(40289,0)
      for _, item in ipairs(table) do
          reaper.SetMediaItemSelected(item,true)
      end
  end
  
  --------------
  local function Jump(P)
  
      play=reaper.GetPlayState()
      local Start,End=reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
      if P>Start then return end
      if play~=1 then 
         return 
      else
         local purple=16449756
         local ts=reaper.GetThemeColor("col_tl_bgsel2")
         local p=reaper.GetPlayPosition()
         if ts==purple then 
            if p<Start and Start~=End then
               reaper.defer(function() Jump(P) end)
            else
               now=reaper.GetCursorPosition()
               reaper.SetEditCurPos(End,false,true)
               reaper.SetEditCurPos(now,false,false)
            end
         else
            reaper.defer(function() Jump(P) end)
         end
      end
      
  end
  
  --------------
  local function TrackState(tr)
  
      --normal
      if nil == reaper.GetParentTrack(tr) 
         and 0 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then return "normal"
      --children
      elseif nil ~= reaper.GetParentTrack(tr) 
             and 1 ~= reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then return "children"
      --parent
      elseif nil == reaper.GetParentTrack(tr) 
             and 1 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then return "parent"
      end
  end 
  
  --------------
  local function CheckCompTrack()
      
      local tr_n=reaper.CountSelectedTracks(0)
      for i=1,tr_n do
          local tr=reaper.GetSelectedTrack(0,i-1)
          local _,layout=reaper.GetSetMediaTrackInfo_String(tr,"P_TCP_LAYOUT","",false)
          if layout =="d1 -- Fader" then
             mom=tr
          end
          if layout =="d5 -- Tmp" then
             Tmp=tr
          end
          if mom and Tmp then break end
      end
      
      return mom,Tmp,tr_n
      
  end
  
  --------------
  local function RenameTrack(sta,tr,ch)
      
      if not ch then return end
      
      LABEL={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
      
      local idx=reaper.GetMediaTrackInfo_Value(tr,"IP_TRACKNUMBER")
      local _,NAME=reaper.GetTrackName(tr)
      if NAME:find("Track "..tostring(math.floor(idx))) then
         NAME=""
      end
      
      if sta=="normal" then
         reaper.GetSetMediaTrackInfo_String(ch,"P_NAME",NAME.."  |  A",true)
      else
         idx=reaper.GetMediaTrackInfo_Value(ch,"IP_TRACKNUMBER")
         last=reaper.GetTrack(0,idx-2)
         _,name=reaper.GetTrackName(last)
         found=false
         for abigel=1,25 do
             if name:find("  |  "..LABEL[abigel]) then
                key=abigel+1
                found=true
                break
             end
         end
         
         if mom then
            ch_idx=reaper.GetMediaTrackInfo_Value(ch,"IP_TRACKNUMBER")
            
            found=false
            
            abigel=1
            repeat
                if NAME:find("-"..tostring(abigel)) then
                   NAME=string.gsub(NAME,"-"..tostring(abigel),"")
                   reaper.GetSetMediaTrackInfo_String(tr,"P_NAME",NAME.."-"..tostring(abigel+1),true)
                   reaper.GetSetMediaTrackInfo_String(ch,"P_NAME",NAME.."-"..tostring(abigel),true)
                   found=true
                   abiii=0 
                   repeat
                       local next_tr=reaper.GetTrack(0,ch_idx+abiii)
                       _,next_name=reaper.GetTrackName(next_tr)
                       if next_name:find("-"..tostring(abigel+abiii+1)) then
                          reaper.GetSetMediaTrackInfo_String(next_tr,"P_NAME",NAME.."-"..tostring(abigel+abiii+2),true)
                       else
                          break
                       end
                       abiii=abiii+1
                   until not next_tr
                   break
                end
                abigel=abigel+1
            until abigel==500
            
            if found then
            end
            
            if not found then
               reaper.GetSetMediaTrackInfo_String(tr,"P_NAME",NAME.."-2",true)
               reaper.GetSetMediaTrackInfo_String(ch,"P_NAME",NAME.."-1",true)
            end
            if not exp then
               reaper.GetSetMediaTrackInfo_String(last,"P_TCP_LAYOUT","",true)
            end
            reaper.GetSetMediaTrackInfo_String(ch,"P_TCP_LAYOUT","d5 -- Tmp",true)
            
         else
            if found then
               reaper.GetSetMediaTrackInfo_String(ch,"P_NAME",NAME.."  |  "..LABEL[key],true)
            end
         end
         
      end
  end
  
  --------------
  local function CreateTrackandRoute(T,t,bool)
      
      if bool then
         bool=1
      else 
         bool=0
      end
      
      if T==7 or T==8 or T==4 then -- midi track
         cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE1")
         reaper.Main_OnCommand(cmd,0)
      else -- audio track
         cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE3")
         reaper.Main_OnCommand(cmd,0)
      end
      c=reaper.GetSelectedTrack(0,0)
      send = reaper.CreateTrackSend(c,t)
      reaper.SetMediaTrackInfo_Value(c,"B_MAINSEND",0)
      reaper.SetTrackSendInfo_Value(c,0,send,"D_VOL",1)
      reaper.SetTrackSendInfo_Value(c,0,send,"I_SENDMODE",0)
      reaper.SetMediaTrackInfo_Value(c,"B_MUTE",1)
      reaper.SetMediaTrackInfo_Value(c,"B_SHOWINMIXER",bool)
      reaper.SetMediaTrackInfo_Value(c,"B_SHOWINTCP",bool)
      return c
  end
  
  --------------
  local function CreateTrackVersion()
      
      local Item=reaper.GetToggleCommandState(40253)
      local Time=reaper.GetToggleCommandState(40076)
      
      if Item~=0 or Time~=0 then return end
      
      cmd = reaper.NamedCommandLookup("_SWS_SELTRKWITEM")
      reaper.Main_OnCommand(cmd,0)--Select only track(s) with selected item(s)
      
      tr={}
      item={}
      tr_n=reaper.CountSelectedTracks(0)
      for abi=1,tr_n do
          tr[abi]=reaper.GetSelectedTrack(0,abi-1)
          item[abi]=reaper.GetSelectedMediaItem(0,abi-1)
      end
      
      curstart,curend = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
       
      for abi=1,tr_n do
          reaper.Main_OnCommand(40289,0)--unselect all items
          reaper.SetMediaItemSelected(item[abi],true)
          reaper.Main_OnCommand(41039,0)--set loop point to item
          reaper.SetOnlyTrackSelected(tr[abi])
          state=TrackState(tr[abi])
          TYPE=reaper.GetMediaTrackInfo_Value(tr[abi],"I_RECMODE")
          reaper.Main_OnCommand(40718,0)--Select all items on selected tracks in current time selection
          reaper.SetMediaItemSelected(item[abi],false)
          reaper.Main_OnCommand(41039,0)--set loop point to item
          tmpstart,tmpend = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
          if reaper.CountSelectedMediaItems(0)==0 then goto NEXT end
          
          tmp_item={}
          SaveSelectedItems(tmp_item)
          
          if state=="normal" then
             reaper.GetSetMediaTrackInfo_String(tr[abi],"P_TCP_LAYOUT","d3 ------ Red Fader",true)
             child=CreateTrackandRoute(TYPE,tr[abi])
             reaper.SetMediaTrackInfo_Value(tr[abi],"I_FOLDERDEPTH",1)
             reaper.SetMediaTrackInfo_Value(child,"I_FOLDERDEPTH",-1)
             
             for abii=1,#tmp_item do
                 reaper.MoveMediaItemToTrack(tmp_item[abii],child)
             end
             
          else
             
             idx=reaper.GetMediaTrackInfo_Value(tr[abi],"IP_TRACKNUMBER")
             
             abii=0
             repeat --find empty slot
                 ver=reaper.GetTrack(0,idx+abii)
                 ver_in=reaper.CountTrackMediaItems(ver)
                 if ver_in>0 then
                    cross=false
                    for abiii=1,ver_in do
                        ver_it=reaper.GetTrackMediaItem(ver,abiii-1)
                        P=reaper.GetMediaItemInfo_Value(ver_it,"D_POSITION")
                        L=reaper.GetMediaItemInfo_Value(ver_it,"D_LENGTH")
                        E=P+L
                        if P>=tmpstart and P<=tmpend then
                           cross=true
                        elseif E>=tmpstart and E<=tmpend then
                           cross=true
                        elseif P<=tmpstart and E>=tmpend then
                           cross=true
                        end
                        if cross then
                           break
                        end
                    end
                 end
                 if not cross then
                    theone=ver
                    break
                 end
                 abii = abii+1
             until reaper.GetMediaTrackInfo_Value(ver,"I_FOLDERDEPTH")==-1
                    
             if theone then --move items to theone
                for abii=1,#tmp_item do
                    reaper.MoveMediaItemToTrack(tmp_item[abii],theone)
                end
             else -- create new version
                --reaper.ShowConsoleMsg("THERE")
                reaper.SetOnlyTrackSelected(ver)
                _,state=reaper.GetTrackState(ver)
                if state<512 then -- not hide from TCP
                   SHOW=true
                elseif state>=1024 and state<1536 then -- not hide from TCP 
                   SHOW=true
                end
                
                child=CreateTrackandRoute(TYPE,tr[abi],SHOW)
                reaper.SetMediaTrackInfo_Value(ver,"I_FOLDERDEPTH",0)
                reaper.SetMediaTrackInfo_Value(child,"I_FOLDERDEPTH",-1)
                for abii=1,#tmp_item do
                    reaper.MoveMediaItemToTrack(tmp_item[abii],child)
                end
             end
            
          end
          RenameTrack(state,tr[abi],child)
          ::NEXT::
      end
      
      if 1 == reaper.GetToggleCommandState(1068)then
         reaper.GetSet_LoopTimeRange2(0,true,true,curstart,curend,false)
      else
         reaper.GetSet_LoopTimeRange2(0,true,false,curstart,curend,false)
      end
      
  end
    
  --------------
  local function Stop()
    
    reaper.Main_OnCommand(1016,0)--play/stop
    item_number=reaper.CountSelectedMediaItems(0)
    if item_number==0 then return false end
    SaveSelectedItems(itemzzz)
    CreateTrackVersion()
    RestoreSelectedItems(itemzzz)
    reaper.Main_OnCommand(41330,0)--New recording splits existing items and creates new takes (default)
    return true
  end
  
  --------------
  local function main(Play)
    
    local name = "Play_Position"
    local B = reaper.GetCursorPosition()
    
    
    if 1 == Play then -- playing
    
      local A_1 = reaper.GetPlayPosition()
      reaper.SetExtState(name,"Play_Position",A_1,false)
      reaper.SetEditCurPos(A_1,false,false)
      reaper.Main_OnCommand(1016,0)
      
    elseif 5 == Play then
      
      ITEM=reaper.GetToggleCommandState(40253)
      TIME=reaper.GetToggleCommandState(40076)
      
      SaveSelectedTracks(trackz)
      goon=Stop()
      RestoreSelectedTracks(trackz)
      
      if not goon then 
         goto laststep
      end
      
      item=reaper.GetSelectedMediaItem(0,0)
      if ITEM==0 and TIME==0 then
         p=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
         reaper.SetEditCurPos(p,false,false)
      else
         reaper.SetEditCurPos(B,false,false)
      end
      reaper.Main_OnCommand(40006,0)
      ::laststep::
      reaper.Main_OnCommand(1013,0) 
      reaper.SetEditCurPos(B,false,false)
      
    elseif 2 == Play then
      
      reaper.Main_OnCommand(1007,0)
      Jump(B)
      
    else
    
      --A_2 = reaper.GetExtState(name,"Play_Position",false)
      
      --if A_2 ~= nil then
        --reaper.SetEditCurPos(A_2,false,false)
      --end
      reaper.Main_OnCommand(1007,0)
      --reaper.SetEditCurPos(B,false,false)
      Jump(B)
    end
  
  end
  
  -----
  
  local Play = reaper.GetPlayState()
  if Play==5 then
     reaper.Undo_BeginBlock()
     main(Play)
     reaper.Undo_EndBlock("Re-record",-1)
  else
     reaper.defer(function()main(Play)end)
  end
