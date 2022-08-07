
  r=reaper
  
  -------------------------------------------
  local function FindKeyTrack(parent_tr,parent_idx)
      
      local tmp_idx=parent_idx
      repeat
          tmp_tr=reaper.GetTrack(0,tmp_idx)
          if not tmp_tr then break end
          
          local _,layout=reaper.GetSetMediaTrackInfo_String(tmp_tr,"P_TCP_LAYOUT","",false)
          if layout =="d1 -- Fader" then
             mom=tmp_tr
          end
          if layout =="d5 -- Tmp" then
             if cur then
                reaper.GetSetMediaTrackInfo_String(tmp_tr,"P_TCP_LAYOUT","",true)
             else
                cur=tmp_tr
             end
          end
          
          if reaper.GetMediaTrackInfo_Value(tmp_tr,"I_FOLDERDEPTH")== 0 then
             tmp_idx=tmp_idx+1
          elseif reaper.GetMediaTrackInfo_Value(tmp_tr,"I_FOLDERDEPTH")== -1 then
             bottom_tr=tmp_tr
             break
          end
          
      until tmp_idx==500
      
      return mom,cur,bottom_tr
      
  end
  
  --------------------------------------
  local function ExchangeEnvelope(tr,ch)
      Envname={"Volume","Pan","Mute","Volume (Pre-FX)"}
      cmd={40406,40407,40867,40408}
      En=reaper.CountTrackEnvelopes(tr)
      en=reaper.CountTrackEnvelopes(ch)
      complete=0
      for abiii=0,En-1 do
          Env=reaper.GetTrackEnvelope(tr,abiii)
          _,envname=reaper.GetEnvelopeName(Env)
          br_Env=reaper.BR_EnvAlloc(Env,false)
          Active,Visible,Armed,InLane,LaneHeight,DefaultShape,_,_,_,_,FaderScaling = reaper.BR_EnvGetProperties( br_Env )
          local Ep=reaper.CountEnvelopePoints(Env)
          if Ep>1 then
             if envname=="Volume" then
                key=1
                volume=true
             elseif envname=="Pan" then
                key=2
                pan=true
             elseif envname=="Mute" then
                key=3
                mute=true
             elseif envname=="Volume (Pre-FX)" then
                key=4
                VPFX=true
             end
             if key then
                env=reaper.GetTrackEnvelopeByName(ch,Envname[key])
                if not env then
                   reaper.SetOnlyTrackSelected(ch)
                   reaper.Main_OnCommand(cmd[key],0)
                   env=reaper.GetTrackEnvelopeByName(ch,Envname[key])
                end
                br_env=reaper.BR_EnvAlloc(env,false)
                active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,_,faderScaling = reaper.BR_EnvGetProperties( br_env )
                reaper.BR_EnvSetProperties(br_env,Active,Visible,Armed,InLane,LaneHeight,DefaultShape,FaderScaling)
                reaper.BR_EnvSetProperties(br_Env,active,visible,armed,inLane,laneHeight,defaultShape,faderScaling)
                reaper.BR_EnvFree( br_env, true )
                reaper.BR_EnvFree( br_Env, true )
                Env=reaper.GetTrackEnvelopeByName(tr,Envname[key])
                env=reaper.GetTrackEnvelopeByName(ch,Envname[key])
                _,Chunk=reaper.GetEnvelopeStateChunk(Env,"", false)
                _,chunk=reaper.GetEnvelopeStateChunk(env,"", false)
                reaper.SetEnvelopeStateChunk(Env,chunk,true)
                reaper.SetEnvelopeStateChunk(env,Chunk,true)
                complete=complete+1
             end
             Chunk=nil
             chunk=nil
             key=nil
          end
          if complete == En and En==en then return end
      end
      for abiii=0,en-1 do
          env=reaper.GetTrackEnvelope(ch,abiii)
          _,envname=reaper.GetEnvelopeName(env)
          br_env=reaper.BR_EnvAlloc(env,false)
          active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,_,faderScaling = reaper.BR_EnvGetProperties( br_env )
          local ep=reaper.CountEnvelopePoints(env)
          if ep>1 then
             if envname=="Volume" and not volume then
                key=1
             elseif envname=="Pan" and not pan then
                key=2
             elseif envname=="Mute" and not mute then
                key=3
             elseif envname=="Volume (Pre-FX)" then
                key=4
             end
             if key then
                Env=reaper.GetTrackEnvelopeByName(tr,Envname[key])
                if not Env then
                   reaper.SetOnlyTrackSelected(tr)
                   reaper.Main_OnCommand(cmd[key],0)
                   Env=reaper.GetTrackEnvelopeByName(tr,Envname[key])
                end
                br_Env=reaper.BR_EnvAlloc(Env,false)
                Active,Visible,Armed,InLane,LaneHeight,DefaultShape,_,_,_,_,FaderScaling = reaper.BR_EnvGetProperties( br_Env )
                reaper.BR_EnvSetProperties(br_env,Active,Visible,Armed,InLane,LaneHeight,DefaultShape,FaderScaling)
                reaper.BR_EnvSetProperties(br_Env,active,visible,armed,inLane,laneHeight,defaultShape,faderScaling)
                reaper.BR_EnvFree( br_env, true )
                reaper.BR_EnvFree( br_Env, true )
                Env=reaper.GetTrackEnvelopeByName(tr,Envname[key])
                env=reaper.GetTrackEnvelopeByName(ch,Envname[key])
                _,Chunk=reaper.GetEnvelopeStateChunk(Env,"", false)
                _,chunk=reaper.GetEnvelopeStateChunk(env,"", false)
                reaper.SetEnvelopeStateChunk(Env,chunk,true)
                reaper.SetEnvelopeStateChunk(env,Chunk,true)
             end
             Chunk=nil
             chunk=nil
             key=nil
          end
      end
  end
  
  -------------------------------------------
  local function ExchangeTrack(tr_A,tr_B,tmp)
      
      idx_A=reaper.GetMediaTrackInfo_Value(tr_A,"IP_TRACKNUMBER")
      _,NAME=reaper.GetTrackName(tr_A)
      if NAME:find("Track "..tostring(math.floor(idx_A))) then
         NAME=""
      end
      
      idx_B=reaper.GetMediaTrackInfo_Value(tr_B,"IP_TRACKNUMBER")
      _,name=reaper.GetTrackName(tr_B)
      if name:find("Track "..tostring(math.floor(idx_B))) then
         name=""
      end
      
      it_A=reaper.CountTrackMediaItems(tr_A)
      it_B=reaper.CountTrackMediaItems(tr_B)
      
      ----- move current to tmp
      for abii=1,it_A do
          local it=reaper.GetTrackMediaItem(tr_A,0)
          if it then
             reaper.MoveMediaItemToTrack(it,tmp)
          end
      end
      ----- move mom to current
      for abii=1,it_B do
          local it=reaper.GetTrackMediaItem(tr_B,0)
          if it then
             reaper.MoveMediaItemToTrack(it,tr_A)
          end
      end
      ----- move tmp to target
      for abii=1,it_A do
          local it=reaper.GetTrackMediaItem(tmp,0)
          if it then
             reaper.MoveMediaItemToTrack(it,tr_B)
          end
      end
      
      ExchangeEnvelope(tr_A,tr_B)
      reaper.GetSetMediaTrackInfo_String(tr_A,"P_NAME",name,true)
      reaper.GetSetMediaTrackInfo_String(tr_B,"P_NAME",NAME,true)
      
  end
  
  local function Reset(mom,last_tr,parent_idx)
      
      if not mom then 
         return 
      elseif not last_tr then
         times=1
      else
         last_idx=reaper.GetMediaTrackInfo_Value(last_tr,"IP_TRACKNUMBER")
         times=last_idx-parent_idx
      end
      
      up=reaper.NamedCommandLookup("_RS3d3835dd37f2b25757bacee184e9e1010240d15b")
      
      for abi=1,times do
          reaper.Main_OnCommand(up,0)
      end
      
  end
  -------------------------------------------
  local function main()
      
      tr_n=reaper.CountSelectedTracks(0)
      
      if tr_n==0 then 
         return
      elseif tr_n>1 then  
         reaper.Main_OnCommand(40297,0)--unselect all track
         reaper.Main_OnCommand(41110,0)--select track under mouse 
      end
      
      target_tr=reaper.GetSelectedTrack(0,0)
      target_idx=reaper.GetMediaTrackInfo_Value(target_tr,"IP_TRACKNUMBER")
      _,layout=reaper.GetSetMediaTrackInfo_String(target_tr,"P_TCP_LAYOUT","",false)
      if layout =="d3 ------ Red Fader" then
         mom,last_tr,b,tr=FindKeyTrack(target_tr,target_idx)
         Reset(mom,last_tr,target_idx)
         return
      end
      pa_tr=reaper.GetParentTrack(target_tr)
      if not pa_tr then return end
      _,layout=reaper.GetSetMediaTrackInfo_String(pa_tr,"P_TCP_LAYOUT","",false)
      if layout~="d3 ------ Red Fader" then return end
      
      
      reaper.InsertTrackAtIndex(reaper.CountTracks(0),false)
      tmp=reaper.GetTrack(0,reaper.CountTracks(0)-1)
      
      reaper.SetOnlyTrackSelected(pa_tr)
      pa_idx=reaper.GetMediaTrackInfo_Value(pa_tr,"IP_TRACKNUMBER")
      
      mom,last_tr=FindKeyTrack(pa_tr,pa_idx)
      
      up=reaper.NamedCommandLookup("_RS3d3835dd37f2b25757bacee184e9e1010240d15b")
      down=reaper.NamedCommandLookup("_RS5e7fc0447f0a4da0e8e32173ced579ca05f31d5d")
      
      if last_tr then
         last_idx=reaper.GetMediaTrackInfo_Value(last_tr,"IP_TRACKNUMBER")
         times=target_idx-last_idx
         if times>0 then 
            for abi=1,times do
                reaper.Main_OnCommand(down,0)
            end
         elseif times<=0 then
            for abi=1,-times+1 do
                reaper.Main_OnCommand(up,0)
            end
         end
      else
         if target_tr ~= mom then
            times=target_idx-pa_idx
            if mom then
               times=times-1
            end
            for abi=1,times do
                reaper.Main_OnCommand(down,0)
            end
         else
            reaper.Main_OnCommand(up,0)
         end
      end
    
      reaper.DeleteTrack(tmp) 
      reaper.SetOnlyTrackSelected(target_tr)
      reaper.SetMixerScroll(target_tr)
      reaper.PreventUIRefresh(1)
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Switch to selected version",-1)
