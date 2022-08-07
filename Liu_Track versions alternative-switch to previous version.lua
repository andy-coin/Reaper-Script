  
  r=reaper
  
  -----
  
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
  
  -------------------------------------------
  local function Rename(tr_a,idx_a)
  
      LABEL={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
      
      tr_b=reaper.GetTrack(0,idx_a)
      _,name_a=reaper.GetTrackName(tr_a)
      _,name_b=reaper.GetTrackName(tr_b)
      for labqiv=1,#LABEL do
          if name_a:match("|  "..LABEL[labqiv]) then
             for lab=1,500 do
                 if name_a:match("|  "..LABEL[labqiv].."-"..tostring(lab)) then
                    sub_1=true
                    sub_key=lab
                    break
                 end
             end    
             key_1=labqiv
          end
          if name_b:match("|  "..LABEL[labqiv]) then
             for lab=1,500 do
                 if name_a:match("|  "..LABEL[labqiv].."-"..tostring(lab)) then
                    sub_2=true
                    sub_key_2=lab
                    break
                 end
             end    
             key_2=labqiv
          end
          if key_1 and key_2 or sub then 
             break 
          end
      end
      
      if sub_1 and sub_2 then
         name_b=name_b:gsub("|  "..LABEL[key_1].."-".."%d+","|  "..LABEL[key_1]..tostring(sub_key+1))
         reaper.GetSetMediaTrackInfo_String(tr_b,"P_NAME",name_b,true)
      elseif sub_1 and sub_2 then
         return
      elseif key_1 and key_2 and key_1~=key_2 then
         name_b=name_b:gsub("|  "..LABEL[key_2],"|  "..LABEL[key_1+1])
         reaper.GetSetMediaTrackInfo_String(tr_b,"P_NAME",name_b,true)
      end
       
      
  end
  --------------------------------------
  local function KillSame(tr_A,idx_A)
      
      if not tr_A then return end
      
      
      _,chunk_A=reaper.GetTrackStateChunk(tr_A,"",false)
      _,layout_A=reaper.GetSetMediaTrackInfo_String(tr_A,"P_TCP_LAYOUT","",false)
  
      chunk_A=chunk_A:gsub("ID [^\n]+","ID ")
      chunk_A=chunk_A:gsub("SEL [^\n]+","SEL ")
      chunk_A=chunk_A:gsub("NAME [^\n]+","NAME ")
      chunk_A=chunk_A:gsub("ISBUS [^\n]+","ISBUS ")
      chunk_A=chunk_A:gsub("LAYOUTS [^\n]+\n","")
      chunk_A=chunk_A:gsub("PEAKCOL [^\n]+","PEAKCOL ")
      posi_A={}
      for position in chunk_A:gmatch("POSITION [^\n]+") do
          posi_A[#posi_A+1]=position:gsub("POSITION ","")
      end
      chunk_A=chunk_A:gsub("POSITION [^\n]+","POSITION ")
      
      --reaper.ShowConsoleMsg("\n\n"..chunk_A)
      
      tr_B=reaper.GetTrack(0,idx_A)
      _,chunk_B=reaper.GetTrackStateChunk(tr_B,"",false)
      _,layout_B=reaper.GetSetMediaTrackInfo_String(tr_B,"P_TCP_LAYOUT","",false)
      
      chunk_B=chunk_B:gsub("ID [^\n]+","ID ")
      chunk_B=chunk_B:gsub("SEL [^\n]+","SEL ")
      chunk_B=chunk_B:gsub("NAME [^\n]+","NAME ")
      chunk_B=chunk_B:gsub("ISBUS [^\n]+","ISBUS ")
      chunk_B=chunk_B:gsub("LAYOUTS [^\n]+\n","")
      chunk_B=chunk_B:gsub("PEAKCOL [^\n]+","PEAKCOL ")
      posi_B={}
      for position in chunk_B:gmatch("POSITION [^\n]+") do
          posi_B[#posi_B+1]=position:gsub("POSITION ","")
      end
      chunk_B=chunk_B:gsub("POSITION [^\n]+","POSITION ")
      
      match=true
      
      if #posi_A ~= #posi_B then
         match=false
         return false
      end
      
      for abi=1,#posi_A do
          pos=posi_A[abi]-posi_B[abi] 
          if pos>0.00000000005 or pos<-0.00000000005 then
             match=false
             return false
          end
      end
      --reaper.ShowConsoleMsg("\n\n"..chunk_B)
  
      if chunk_A==chunk_B and match then 
         bottom=reaper.GetMediaTrackInfo_Value(tr_B,"I_FOLDERDEPTH")
         reaper.DeleteTrack(tr_B)
         if bottom==-1 then
            reaper.SetMediaTrackInfo_Value(tr_A,"I_FOLDERDEPTH",-1)
         end
         if layout_B=="d5 -- Tmp" and layout_A == "" then
            reaper.GetSetMediaTrackInfo_String(tr_A,"P_TCP_LAYOUT",lauout_B,true)
         --elseif  layout_B=="d5 -- Tmp" and layout_A == "d1 -- Fader" then
         --   reaper.GetSetMediaTrackInfo_String(tr_B,"P_TCP_LAYOUT",,true)
         end
         return true
      end
      
      return false
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
  
  -----
  
  local function Up()
      
      reaper.PreventUIRefresh(-1)

      cur_tr=reaper.GetSelectedTrack(0,0)
      
      if cur_tr==nil then return end
      
      reaper.InsertTrackAtIndex(reaper.CountTracks(0),false)
      tmp=reaper.GetTrack(0,reaper.CountTracks(0)-1)
               
      local _,layout=reaper.GetSetMediaTrackInfo_String(cur_tr,"P_TCP_LAYOUT","",false)
      if layout=="d3 ------ Red Fader" then
         
         reaper.SetOnlyTrackSelected(cur_tr)
         cur_it=reaper.CountTrackMediaItems(cur_tr)
         cur_idx=reaper.GetMediaTrackInfo_Value(cur_tr,"IP_TRACKNUMBER")
         _,NAME=reaper.GetTrackName(cur_tr)
         if NAME:find("Track "..tostring(math.floor(cur_idx))) then
            NAME=""
         end
         
         mom,last_tr,bottom_tr=FindKeyTrack(cur_tr,cur_idx)
         
         if mom and last_tr then 
            last_idx=reaper.GetMediaTrackInfo_Value(last_tr,"IP_TRACKNUMBER")
            target_tr=last_tr
            pre_tr=reaper.GetTrack(0,last_idx-2)
            reaper.GetSetMediaTrackInfo_String(last_tr,"P_TCP_LAYOUT","",true)
         elseif mom and not last_tr then
            target_tr=mom
            mom_idx=reaper.GetMediaTrackInfo_Value(mom,"IP_TRACKNUMBER")
            pre_tr=reaper.GetTrack(0,mom_idx-2)
            reaper.GetSetMediaTrackInfo_String(mom,"P_TCP_LAYOUT","",true)
         elseif not mom then
            goto END
         end
         
         if pre_tr~=mom and pre_tr~= cur_tr then
            reaper.GetSetMediaTrackInfo_String(pre_tr,"P_TCP_LAYOUT","d5 -- Tmp",true)
         end
         
         ::Start::
         _,name=reaper.GetTrackName(target_tr)
         target_idx=reaper.GetMediaTrackInfo_Value(target_tr,"IP_TRACKNUMBER")
         if name:find("Track "..tostring(math.floor(target_idx))) then
            name=""
         end
         target_it=reaper.CountTrackMediaItems(target_tr)

         ----- move current to tmp
         for abii=1,cur_it do
             local it=reaper.GetTrackMediaItem(cur_tr,0)
             reaper.MoveMediaItemToTrack(it,tmp)
         end
         ----- move target to current
         for abii=1,target_it do
             local it=reaper.GetTrackMediaItem(target_tr,0)
             reaper.MoveMediaItemToTrack(it,cur_tr)
         end
         ----- move tmp to target
         for abii=1,cur_it do
             local it=reaper.GetTrackMediaItem(tmp,0)
             reaper.MoveMediaItemToTrack(it,target_tr)
         end
         
         ExchangeEnvelope(cur_tr,target_tr)
         reaper.GetSetMediaTrackInfo_String(cur_tr,"P_NAME",name,true)
         reaper.GetSetMediaTrackInfo_String(target_tr,"P_NAME",NAME,true)
      end 
      KillSame(target_tr,target_idx,bottom)
      ::END::
      reaper.DeleteTrack(tmp)  
      reaper.SetOnlyTrackSelected(cur_tr)
      reaper.SetMixerScroll(cur_tr)
      reaper.PreventUIRefresh(1)
  end
  
  reaper.Undo_BeginBlock()
  Up()
  reaper.Undo_EndBlock("Switch to previous track version",-1)

  
  
