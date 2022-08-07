  
  trackzzz={}
  
  --------------
  local function SaveSelectedTracks (table)--trackzzz
      for i = 0, reaper.CountSelectedTracks(0)-1 do
          table[i+1] = reaper.GetSelectedTrack(0, i)
      end
  end
  
  --------------
  local function RestoreSelectedTracks (table)--trackzzz
      reaper.Main_OnCommand(40297,0)
      for _, track in ipairs(table) do
          reaper.SetTrackSelected(track, true)
      end
  end
  
  --------------
  local function SaveCT(closetime)
  
      local name = "holding"
      reaper.SetExtState(name,"holding",closetime,false)
      
  end
  
  --------------
  local function SaveLT(last_time)
  
      local name = "last time"
      reaper.SetExtState(name,"last_time",last_time,false)
  
  end
  
  --------------
  local function LoadLT()
      
      local name = "last time"
      last_time = reaper.GetExtState(name,"last_time",false)
      return last_time
      
  end  
  
  --------------
  local function FindBoss(track,table)
  
      parent=reaper.GetParentTrack(track)
      Msend=reaper.GetMediaTrackInfo_Value(track,"B_MAINSEND")
      --reaper.ShowConsoleMsg(tostring(Msend))
      if parent then
         table[#table+1]=parent
         FindBoss(parent,table)
      elseif Msend==0 then
         send_n=reaper.GetTrackNumSends(track,0)
         for abi=1,send_n do
             sends=reaper.BR_GetMediaTrackSendInfo_Track(track,0,abi-1,1)
             table[#table+1]=sends
             FindBoss(sends,table)
         end
      end

  end
    
  --------------
  local function GetRazorTracks()
      local trackCount = reaper.CountTracks(0)
      local trackz = {}
      for i = 0, trackCount - 1 do
          local track = reaper.GetTrack(0, i)
          local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
          if area ~= '' then
              --reaper.ShowConsoleMsg(i.."|"..area.."\n")
              --PARSE STRING
              local zone=""
              local str = {}
              for j in string.gmatch(area, "%S+") do
                  table.insert(str, j)
              end
              --FILL AREA DATA
              local j = 1
              while j <= #str do
              
                  trackz[#trackz+1] = track
                  j = j + 3
              end
              reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS',"", true)
          end
      end
      return trackz
  end
  
  --------------
  local function Play()
      
      P=reaper.GetCursorPosition()
      reaper.BR_GetMouseCursorContext()
      M=reaper.BR_GetMouseCursorContext_Position()
      if reaper.GetPlayState()==0 or reaper.GetPlayState()==2 then
         reaper.SetEditCurPos(M,false,false)
         reaper.Main_OnCommand(40044,0)
      else
         reaper.SetEditCurPos(M,false,true)
      end
      reaper.SetEditCurPos(P,false,false)
  end
  
  --------------
  local function Main(tr,last_char,count)
      char = gfx.getchar()
       
      hold=reaper.GetExtState("holdbug","holdbug",false)
      if hold=="" then hold=0 end
      
      gap=timeQQ-LT
      --reaper.ShowConsoleMsg(char.."|"..last_char.."|"..gap.."|"..hold.."\n")
      
      if gap>0.7 and count==0 or hold==0 then
         --reaper.ShowConsoleMsg("\n!!!SAVE!!!\n")
         cmd=reaper.NamedCommandLookup("_BR_SAVE_SOLO_MUTE_ALL_TRACKS_SLOT_3")
         reaper.Main_OnCommand(cmd,0)
         reaper.Main_OnCommand(40340,0)--unsolo all tracks
      end   
      
      count=1
      
      if char == 0 and last_char==-1 then --and gap>0.55 then --first
         --reaper.ShowConsoleMsg("|1|\n")
         reaper.Main_OnCommand(40297,0)
         if type(tr)=="table" then
            for abi=1,#tr do
                reaper.SetTrackSelected(tr[abi],true)
            end
         end
         reaper.Main_OnCommand(40728,0)
         RestoreSelectedTracks(trackzzz)
         Play()

      elseif char==-1 and last_char==-1 then  
         --reaper.ShowConsoleMsg("|2|\n")
         reaper.SetExtState("holdbug","holdbug",0,true) 
         gfx.quit() 
         if type(tr)=="table" then
            for abi=1,#tr do
                reaper.SetTrackSelected(tr[abi],true)
            end
         end
         reaper.Main_OnCommand(40729,0)
         RestoreSelectedTracks(trackzzz)
         cmd=reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_TRACKS_SLOT_3")
         reaper.Main_OnCommand(cmd,0)
         play=reaper.GetPlayState()
         if play~=1 and play~=5 then
            reaper.Main_OnCommand(40044,0)--play/stop
         end    
         return
      elseif char~=0 or last_char~=0 then 
        -- reaper.ShowConsoleMsg("|3|\n")
         reaper.SetExtState("holdbug","holdbug",0,true)   
      elseif char==0 and last_char==0 then
         if tonumber(hold)>=16 then 
            --reaper.ShowConsoleMsg("|4|\n")
            reaper.SetExtState("holdbug","holdbug",0,true) 
            gfx.quit() 
            if type(tr)=="table" then
               for abi=1,#tr do
                   reaper.SetTrackSelected(tr[abi],true)
               end
            end
            reaper.Main_OnCommand(40729,0)
            RestoreSelectedTracks(trackzzz)
            cmd=reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_TRACKS_SLOT_3")
            reaper.Main_OnCommand(cmd,0)
            play=reaper.GetPlayState()
            if play~=1 and play~=5 then
               reaper.Main_OnCommand(40044,0)--play/stop
            end
            return
         else
            --reaper.ShowConsoleMsg("|5|\n")
            reaper.SetExtState("holdbug","holdbug",hold+1,true)
         end
      end
      
      gfx.update()
      reaper.defer(function()Main(tr,char,count)end)
      
  end
  
  --------------------------------------------------------------------------------------------------------------
  SaveSelectedTracks(trackzzz)
  c = gfx.getchar()
  LT = LoadLT()
  timeQQ = reaper.time_precise()
  SaveLT(timeQQ)  
  gfx.init("", 0,0,0,0,0,0)
  tr_n=reaper.CountSelectedTracks(0)
  tr,_ = reaper.BR_TrackAtMouseCursor()
  trackz=GetRazorTracks()
  if #trackz>0 then
     for andy=1,#trackz do
         --FindBoss(trackz[andy],trackz)
     end
     Main(trackz,c,0)    
  elseif tr_n>1 then
     trs={}
     for abi=1,tr_n do
         trs[#trs+1]=reaper.GetSelectedTrack(0,abi-1)
         --FindBoss(trs[#trs],trs)
     end
     Main(trs,c,0)
  elseif tr then
     --reaper.Main_OnCommand(40297,0)
     trs={}
     trs[1]=tr 
     --FindBoss(tr,trs)
     Main(trs,c,0)  
  elseif not tr then 
     tr=reaper.GetSelectedTrack(0,0)
     if not tr then return end
     trs={}
     trs[1]=tr
     --FindBoss(tr,trs)
     Main(trs,c,0)          
  end
  
  --reaper.SetMediaTrackInfo_Value(tr,"I_SOLO",0)
  
