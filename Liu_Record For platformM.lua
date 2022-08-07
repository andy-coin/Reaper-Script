  
  r=reaper
    
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackzzz={}
  trackz={}
  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  
  local function RestoreSelectedTracks (table)--trackzzz
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
  local function serialize (tabl, indent)
      local nl = string.char(10) -- newline
      indent = indent and (indent.."  ") or ""
      local str = ''
      complex=false
      for key, value in pairs (tabl) do
          local pr = (type(key)=="string") and ('["'..key..'"]=') or ""
          if type (value) == "table" then
              str = str..'<<'..serialize(value, indent)
              str = str .. indent..">>"..nl
              complex=true
          elseif type (value) == "string" then
              str = str..indent..pr..'"'..tostring(value)..'",'..nl
          else
              str = str..indent..pr..'"'..tonumber(value)..'",'..nl
          end
      end
      
      if complex then
        str= "<<true>>\n"..str
      end
      
      return str
  end
  
  --------------
  local function unserialize(str)
    
    local tbl = {}
    local time=reaper.time_precise()
    
    comx=string.gmatch(str,'<<(.-)>>')
    complex=comx()
    
    if complex =="true" then
      tb=string.gmatch(str,'<<(.-)>>')
      abi=1
      repeat
        --reaper.ShowConsoleMsg("falg"..abi.."|")
        tab=tb()
        if not tab then break end
        tbl[abi]={}
        v=string.gmatch(tab,'"(.-)"')
        repeat 
          value=v()
          if not value then break end
          table.insert(tbl[abi],value)
        until time==reaper.time_precise()-5
        abi=abi+1
      until time==reaper.time_precise()-5
      table.remove(tbl,1)
    else
        v=string.gmatch(str,'"(.-)"')
      repeat 
        value=v()
        if not value then break end
        table.insert(tbl,value)
      until time==reaper.time_precise()-5
    end
      
    return tbl
  end
  
  --------------
  local function LoadRecTrack()
      
      local Rec_tr={}
      code=reaper.GetExtState("Record track","tr_code",false)
      code=unserialize(code)
      
      for abi=1,#code do
          Rec_tr[#Rec_tr+1]=reaper.BR_GetMediaTrackByGUID(0,code[abi])
      end
      
      return Rec_tr
  
  end
  
  --------------
  local function RestorTrackColor()
  
      cmd=reaper.NamedCommandLookup("_SWSAUTOCOLOR_APPLY")
      reaper.Main_OnCommand(cmd,0)
      reaper.SetThemeColor("col_mi_bg",19682182,0)
      reaper.SetThemeColor("col_mi_bg2",19682182,0)
      Color=reaper.GetExtState("Record track","tr_color",false)
      rec_tr=LoadRecTrack()
      color=string.gmatch(Color,"[^\n]+")
      for abi=1,#rec_tr do
          c=color()
          reaper.SetMediaTrackInfo_Value(rec_tr[abi],"I_CUSTOMCOLOR",c)
      end
  
  end  
  
  --------------
  local function SaveRecTrack()
   
      if 0 == reaper.CountTracks(0) then return end
      
      local TR_code={}
      for abi = 0,reaper.CountSelectedTracks(0)-1 do
          local track= reaper.GetSelectedTrack(0,abi)
          _,TR_code[abi+1] = reaper.GetSetMediaTrackInfo_String(track,"GUID","",false)
      end
      
      local TR_code=serialize(TR_code)
      reaper.SetExtState("Record track","tr_code",TR_code,false)
  
  end
  
  --------------
  local function ChangeRecColor(arm_tr)
  
      Rec=26607616--27262976
      for abi=1,reaper.CountMediaItems(0) do
          local item=reaper.GetMediaItem(0,abi-1)
          local color=reaper.GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
          if color==0 then 
             local tr=reaper.GetMediaItemTrack(item)
             local tr_color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
             if tr_color~=0 and tr_color~=12599296 then
                reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",tr_color)
             else
                take=reaper.GetActiveTake(item)
                if reaper.TakeIsMIDI(take) then
                   reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",18639925)
                else
                   reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",19682182)
                end
             end
          end
      end
      
      color=""
      reaper.Main_OnCommand(40297,0)--unselect all tracks
      for abi=1,#arm_tr do
          local new_color=reaper.GetMediaTrackInfo_Value(arm_tr[abi],"I_CUSTOMCOLOR")
          color=color..new_color.."\n"
          reaper.SetMediaTrackInfo_Value(arm_tr[abi],"I_CUSTOMCOLOR",0)
          reaper.SetTrackSelected(arm_tr[abi],true)
      end
      SaveRecTrack()
      reaper.SetExtState("Record track","tr_color",color,false)
      reaper.SetThemeColor("col_mi_bg",Rec,0)
      reaper.SetThemeColor("col_mi_bg2",Rec,0)
      reaper.UpdateArrange()
  
  end
  
  --------------
  local function runloop()
    local newtime=os.time()
     
    if (loopcount < 1) then
      if newtime-lasttime >= wait_time_in_seconds then
     lasttime=newtime
     loopcount = loopcount+1
      end
    else 
      ----------------------------------------------------
      -- PUT ACTION(S) YOU WANT TO RUN AFTER WAITING HERE
      
      reaper.TrackCtl_SetToolTip("", x, y, true )
      
      ----------------------------------------------------
      loopcount = loopcount+1
    end
    if 
      (loopcount < 2) then reaper.defer(runloop) 
    end
  end
  
  --------------
  local function DisplayTooltip(message)
    wait_time_in_seconds = 3
    lasttime=os.time()
    loopcount=0
    
    x, y = reaper.GetMousePosition()
    reaper.TrackCtl_SetToolTip( message, x, y, false )
    
    runloop()
  end
  
  --------------
  local function serialize(tbl)
    local str = ''
  
    for _, value in ipairs(tbl) do
      str = str .. type(value) .. '\31' .. tostring(value) .. '\30'
    end
  
    return str
  end
  
  --------------
  local function unserialize(str)
    local type_map = {
      string  = tostring,
      number  = tonumber,
      boolean = function(v) return v == 'true' and true or false end,
    }
  
    local tbl = {}
  
    for type, value in str:gmatch('(.-)\31(.-)\30') do
      --[[if not type_map[type] then
        error(string.format("unsupported value type: %s", type))
      end--]]
  
      table.insert(tbl,value)-- type_map[type](value))
    end
  
    return tbl
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
  
  -----
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
  
  -----
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
  
  -----
  local function CreateTrackVersion()
      
      Item=reaper.GetToggleCommandState(40253)
      Time=reaper.GetToggleCommandState(40076)
      
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
  
  --------------------------------------MAIN---------------------------------------
  
  local function main()
    
    
    SaveSelectedTracks (trackzzz)

    if 5 == reaper.GetPlayStateEx(0) then
      
       local B = reaper.GetCursorPosition()
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
       
    else 
           recording_tr={}
           non_recording_tr={}
           arm={}
           for abi=1,reaper.CountTracks(0) do
               tr=reaper.GetTrack(0,abi-1)
               auto_r=reaper.GetMediaTrackInfo_Value(tr,"B_AUTO_RECARM")
               r=reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")
               if r == 1 then arm[#arm+1]=tr end
               if auto_r==1 then
                  reaper.SetMediaTrackInfo_Value(tr,"B_AUTO_RECARM",0)
                  _,tr= reaper.GetSetMediaTrackInfo_String(tr,"GUID","",false)
                  if r==1 then
                     recording_tr[#recording_tr+1]=tr
                  else
                     non_recording_tr[#non_recording_tr+1]=tr
                  end
               end 
           end  
           
           Item=reaper.GetToggleCommandState(40253)
           Time=reaper.GetToggleCommandState(40076)
           
           if #recording_tr>0 then
              
              re_tr=serialize(recording_tr)
              n_re_tr=serialize(non_recording_tr)
              
              reaper.SetExtState("recording_track","recording_track",re_tr,false)
              reaper.SetExtState("non_recording_track","non_recording_track",n_re_tr,false)
              if Item~=0 or Time~=0 then
                 reaper.Main_OnCommand(41186,0)--tape
              else
                 reaper.Main_OnCommand(41329,0)--layer 
              end
              reaper.Main_OnCommand(1013,0)--record
           elseif #arm>0 then
              if Item~=0 or Time~=0 then
                 reaper.Main_OnCommand(41186,0)--tape
              else
                 reaper.Main_OnCommand(41329,0)--layer 
              end
              reaper.Main_OnCommand(1013,0)--record
          
           else
              reaper.ShowMessageBox("There is no record-arm track >_< ","Oops!!!",0)
              
           end
           
           if #arm>1 then 
              DisplayTooltip("Recording multi tracks ! >_<")
           end
           ChangeRecColor(arm)
          
    end
    RestoreSelectedTracks(trackzzz)
    
  end
  
  -------------------------------------RUN---------------------------------------
  
  reaper.Undo_BeginBlock() 
  main() 
  reaper.Undo_EndBlock("Auto take folder recording",-1)
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
