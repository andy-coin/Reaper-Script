  
  r = reaper
  
  trackzzz = {}
  local function SaveSelectedTracks (table)
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
-----
  
  local function RestoreSelectedTracks (table)
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
-----
  
  itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
  end
  
-----
  
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0)
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
   
-----

  local function ChangeColor(key)
    
    local extname="color_tint"
    local midi=18313493
    local audio=18696831  
    local video=28685749
    local gray=25198720
    local peak=16777215
 
    if key=='1' then
       for abi=1,reaper.CountMediaItems(0) do
           local item=reaper.GetMediaItem(0,abi-1)
           local color=reaper.GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
           if color==0 or color==12599296 then 
              local tr=reaper.GetMediaItemTrack(item)
              color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
              if color==0 or color==12599296 then
                 local take=reaper.GetActiveTake(item)
                 local source=reaper.GetMediaItemTake_Source(take)
                 local TYPE=reaper.GetMediaSourceType(source)
                 if TYPE=="MIDI" then color = midi 
                 elseif TYPE=="VIDEO"then color = video 
                 else color= audio
                 end
              end
           end
           local r,g,b=reaper.ColorFromNative(color)
           local color=reaper.ColorToNative(math.floor(r/2),math.floor(g/2),math.floor(b/2))
           reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",color|0x1000000)
           reaper.SetExtState(extname,"color_tint",0,false)
       end
       reaper.SetThemeColor("col_tr1_peaks",gray,0)
       reaper.SetThemeColor("col_tr2_peaks",gray,0)
       reaper.SetThemeColor("col_tr1_ps2",gray,0)
       reaper.SetThemeColor("col_tr2_ps2",gray,0)
    elseif key=='0' then
       for abi=1,reaper.CountMediaItems(0) do
           local item=reaper.GetMediaItem(0,abi-1)
           local color=reaper.GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
           if color==0 or color==12599296 then 
              local tr=reaper.GetMediaItemTrack(item)
              color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
              if color==0 or color==12599296 then
                 local take=reaper.GetActiveTake(item)
                 local source=reaper.GetMediaItemTake_Source(take)
                 local TYPE=reaper.GetMediaSourceType(source)
                 if TYPE=="MIDI" then color = midi 
                 elseif TYPE=="VIDEO"then color = video 
                 else color= audio
                 end
              end
           end
           local r,g,b=reaper.ColorFromNative(color)
           local color=reaper.ColorToNative(math.floor(r*2),math.floor(g*2),math.floor(b*2))
           reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",color|0x1000000)
           reaper.SetExtState(extname,"color_tint",-1,false)
       end
       reaper.SetThemeColor("col_tr1_peaks",peak,0)
       reaper.SetThemeColor("col_tr2_peaks",peak,0)
       reaper.SetThemeColor("col_tr1_ps2",peak,0)
       reaper.SetThemeColor("col_tr2_ps2",peak,0)
    end
    
    reaper.UpdateArrange()
  
  end

-----

  local function CheckEnvVisible()
    
    for sel_tr = 1, reaper.CountTracks(0) do
      local track = reaper.GetTrack(0,sel_tr-1)
      if track then 
        for i = 1,reaper.CountTrackEnvelopes( track ) do
          local env = reaper.GetTrackEnvelope( track, i-1 )
          local br_env = reaper.BR_EnvAlloc( env, false )
          _,visible,_,_,_,_,_,_,_,_,_ = reaper.BR_EnvGetProperties( br_env )
          reaper.BR_EnvFree( br_env, true )
          if visible then return true end
        end
      end
    end 
    return false 
    
  end
  
-----
  
  local function SetEnvStates()
    
    reaper.Main_OnCommand(40296,0)
    reaper.Main_OnCommand(40406,0)
    
    for abi = 1, reaper.CountTracks(0) do
      local track = reaper.GetTrack(0,abi-1)
      if track then 
        for abii = 1,reaper.CountTrackEnvelopes( track ) do
          local env = reaper.GetTrackEnvelope( track, abii-1 )
          local br_env = reaper.BR_EnvAlloc( env, false )
          active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling = reaper.BR_EnvGetProperties( br_env )
          if Type==0 then 
             reaper.BR_EnvSetProperties(br_env,true,true,armed,false,laneHeight,defaultShape,faderScaling)
          elseif Type~=0 and active then
             reaper.BR_EnvSetProperties(br_env,true,true,armed,false,laneHeight,defaultShape,faderScaling)
          end
          reaper.BR_EnvFree( br_env, true )
        end
      end
    end
    
    RestoreSelectedTracks(trackzzz)
    
    for sel_tr = 1, reaper.CountSelectedTracks(0) do
      local track = reaper.GetSelectedTrack(0,sel_tr-1)
      if track then
        for i = 1,reaper.CountTrackEnvelopes( track ) do
          local env = reaper.GetTrackEnvelope( track, i-1 )
          local br_env = reaper.BR_EnvAlloc( env, false )
          active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling = reaper.BR_EnvGetProperties( br_env )
          if Type==0 then
             reaper.BR_EnvSetProperties(br_env,true,true,armed,true,130,defaultShape,faderScaling)
          elseif Type~=0 and visible then
             reaper.BR_EnvSetProperties(br_env,true,true,armed,false,laneHeight,defaultShape,faderScaling)
          end         
          reaper.BR_EnvFree( br_env, true )
        end
      end
    end
    
  end
  
-----

  local function main()
    
    SaveSelectedItems(itemzzz)
    
    extname="color_tint"
    key=reaper.GetExtState(extname,"color_tint",false)
    
    if CheckEnvVisible() then -- visible
       
       reaper.Main_OnCommand(39013,0)--change mouse modifier to default (move item)
       reaper.Main_OnCommand(41150,0)--hide all envelopes for all tracks
       ChangeColor(key)
    else
       
       SaveSelectedTracks(trackzzz)
       
       reaper.Main_OnCommand(39000,0)--make item can't drag by mouse
       ChangeColor('1')
       SetEnvStates()
       reaper.Main_OnCommand(41149,0)
       RestoreSelectedTracks(trackzzz)
       tr=reaper.GetSelectedTrack(0,0)
       if 1<reaper.CountTrackEnvelopes(tr) then
          reaper.Main_OnCommand(40891,0)
       end
       --cmd=reaper.NamedCommandLookup("_RSdf35656e5f8aef3502ce26124efa1a441db718f5") 
       
    end
    
    RestoreSelectedItems(itemzzz)
    
  end
  
------excute main-------
  
  reaper.defer(main)


