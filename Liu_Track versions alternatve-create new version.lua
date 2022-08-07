  
  r=reaper
  
  LABEL={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  local itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0,reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0,i)
    end
  end
  ----------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      if item then
         reaper.SetMediaItemSelected(item, true)
      end
    end
  end
  
  -----
  
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
  
  -------------------------------------------
  local function FindKeyTrack(parent_tr,tmp_idx)
    
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
             bottom_idx=reaper.GetMediaTrackInfo_Value(tmp_tr,"IP_TRACKNUMBER")  
             break
          end
          
      until tmp_idx==500
      
      return mom,cur,bottom_tr
      
  end
  
  --------------------------------------
  local function CopyEnvelope(tr,ch,idx)
      
      Env=reaper.GetTrackEnvelope(tr,idx)
      
      if not Env then return end
      
      local En=reaper.CountEnvelopePoints(Env)
      if En>0 then
         _,Envname=reaper.GetEnvelopeName(Env)
         _,chunk=reaper.GetEnvelopeStateChunk(Env,"", false)
      else
         return
      end
      
      reaper.SetOnlyTrackSelected(ch)
      if     Envname == "Volume" then reaper.Main_OnCommand(40406,0) -- show track volume envelope
      elseif Envname == "Pan" then reaper.Main_OnCommand(40407,0)    -- show track pan envelope
      elseif Envname == "Mute" then reaper.Main_OnCommand(40867,0)   -- show track mute envelope
      elseif Envname == "Volume (Pre-FX)" then reaper.Main_OnCommand(40408,0) -- show track pre-FX volume envelope
      end
      env=reaper.GetTrackEnvelopeByName(ch,Envname)
      if not env then return end
      reaper.SetEnvelopeStateChunk(env,chunk,true)
      free_env=reaper.BR_EnvAlloc(env,false)
      active,visible,armed,inLane,laneHeight,defaultShape,_,_,_,Type,faderScaling=reaper.BR_EnvGetProperties(free_env)
      reaper.BR_EnvSetProperties(free_env,true,false,armed,true,130,defaultShape,faderScaling)
      reaper.BR_EnvFree(free_env,true)
      
  end
  
  ----- 
  local function main()
      
      local n=reaper.CountSelectedTracks(0)
      if n==0 and itn ==0 then return end
      reaper.Undo_BeginBlock()
      reaper.PreventUIRefresh(1)
      SaveSelectedItems(itemzzz)
      local cur_tr={}
      for abi=1,n do
          cur_tr[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      
      for abi=1,n do
        
          local state=TrackState(cur_tr[abi])
          
          if state=="children" then
             --cur_tr[abi]=reaper.GetParentTrack(cur_tr[abi])
             cmd=reaper.NamedCommandLookup("_RS96977fc411a2c0c288c0690f808ac849eab1740f")
             reaper.Main_OnCommand(cmd,0)
             reaper.SetOnlyTrackSelected(cur_tr[abi])
             reaper.PreventUIRefresh(-1)
             --child=cur_tr[abi]
             return
             --goto NEXT
          end
          
          reaper.SetOnlyTrackSelected(cur_tr[abi])
          local idx=reaper.GetMediaTrackInfo_Value(cur_tr[abi],"IP_TRACKNUMBER")
          local _,NAME=reaper.GetTrackName(cur_tr[abi])
          if NAME:find("Track "..tostring(math.floor(idx))) then
             NAME=""
          end
          local compact=reaper.GetMediaTrackInfo_Value(cur_tr[abi],"I_FOLDERCOMPACT")
          local TYPE=reaper.GetMediaTrackInfo_Value(cur_tr[abi],"I_RECMODE")
          local cur_it = reaper.CountTrackMediaItems(cur_tr[abi]) 
          if cur_it==0 then return end
          
          if state=="parent" then
             mom,last,bottom_tr=FindKeyTrack(cur_tr[abi],idx)
          end
          
          if not bottom_tr then
             POS=cur_tr[abi]
          elseif mom and last then
             POS=last
          elseif mom and not last then
             POS=mom
             exp=true
          else
             POS=bottom_tr
          end
          
          reaper.SetOnlyTrackSelected(POS)
          
          if TYPE==7 or TYPE==8 or TYPE==4 then -- midi track
             cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE1")
             reaper.Main_OnCommand(cmd,0)
          else -- audio track
             cmd=reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE3")
             reaper.Main_OnCommand(cmd,0)
          end
          
          child=reaper.GetSelectedTrack(0,0)
          
          Env_n=reaper.CountTrackEnvelopes(cur_tr[abi])
          for abii=1,Env_n do
              CopyEnvelope(cur_tr[abi],child,abii-1)
          end
          
          reaper.SetOnlyTrackSelected(child)
          
          local send = reaper.CreateTrackSend(child,cur_tr[abi])
          reaper.SetMediaTrackInfo_Value(child, "B_MAINSEND", 0)
          reaper.SetTrackSendInfo_Value(child,0,send,"D_VOL", 1)
          reaper.SetTrackSendInfo_Value(child,0,send,"I_SENDMODE",0)
          reaper.SetMediaTrackInfo_Value(child,"B_MUTE",1)
          reaper.GetSetMediaTrackInfo_String(cur_tr[abi],"P_TCP_LAYOUT","d3 ------ Red Fader",true)
          
          if mom then
             local P=reaper.GetCursorPosition()
             for abii=1,cur_it do
                 it=reaper.GetTrackMediaItem(cur_tr[abi],abii-1)
                 if abii==1 then
                    point=reaper.GetMediaItemInfo_Value(it,"D_POSITION")
                 end
                 reaper.SetMediaItemSelected(it,true)
             end
             reaper.Main_OnCommand(40698,0)--copy items
             reaper.SetEditCurPos(point,false,false)
             reaper.Main_OnCommand(42398,0)--paste items
             reaper.SetEditCurPos(P,false,false)
          else
             for abii=1,cur_it do
                 local it = reaper.GetTrackMediaItem(cur_tr[abi],0)
                 reaper.MoveMediaItemToTrack(it,child)
             end
          end
          
          if state=="normal" then
             reaper.SetMediaTrackInfo_Value(cur_tr[abi],"I_FOLDERDEPTH",1)
             reaper.SetMediaTrackInfo_Value(child,"I_FOLDERDEPTH",-1)
             reaper.SetMediaTrackInfo_Value(child,"B_SHOWINMIXER",0)
             reaper.SetMediaTrackInfo_Value(child,"B_SHOWINTCP",0)
             reaper.GetSetMediaTrackInfo_String(child,"P_NAME",NAME.."  |  A",true)
          else 
             if mom then
                for abigel=1,25 do
                    if NAME:match("  |  "..LABEL[abigel]) then
                       if NAME:match("-%d+") then
                          reaper.GetSetMediaTrackInfo_String(child,"P_NAME",NAME,true)
                          key=NAME:match("-%d+")
                          key=key:gsub("-","")
                          new_name=NAME:gsub("-%d+","-"..tostring(math.floor(key+1)))
                          reaper.GetSetMediaTrackInfo_String(cur_tr[abi],"P_NAME",new_name,true)
                       else
                          reaper.GetSetMediaTrackInfo_String(cur_tr[abi],"P_NAME",NAME.."-2",true)
                          reaper.GetSetMediaTrackInfo_String(child,"P_NAME",NAME.."-1",true)
                       end
                    end
                    if POS==bottom_tr then 
                       reaper.SetMediaTrackInfo_Value(POS,"I_FOLDERDEPTH",0)
                       reaper.SetMediaTrackInfo_Value(child,"I_FOLDERDEPTH",-1)
                    end
                end
                if not exp then
                   reaper.GetSetMediaTrackInfo_String(POS,"P_TCP_LAYOUT","",true)
                end
                reaper.GetSetMediaTrackInfo_String(child,"P_TCP_LAYOUT","d5 -- Tmp",true)
             else
                key=1
                next_idx=idx
                repeat
                    next_tr=reaper.GetTrack(0,next_idx)
                    if not next_tr then break end
                    _,name=reaper.GetTrackName(next_tr)
                    for abigel=key,25 do
                        if name:match("  |  "..LABEL[abigel]) then
                           key=abigel
                           found=true
                           break
                        end
                    end
                    next_idx=next_idx+1
                until reaper.GetMediaTrackInfo_Value(next_tr,"FOLDERDEPTH")==-1 or next_idx==500
                
                if found then 
                   reaper.GetSetMediaTrackInfo_String(child,"P_NAME",NAME.."  |  "..LABEL[key+1],true)
                end
                reaper.SetMediaTrackInfo_Value(POS,"I_FOLDERDEPTH",0)
                reaper.SetMediaTrackInfo_Value(child,"I_FOLDERDEPTH",-1)
             end
             
             sub=reaper.GetTrack(0,idx)
             _,X=reaper.GetTrackState(sub)
             if X>=1544 then
                reaper.SetMediaTrackInfo_Value(child,"B_SHOWINMIXER",0)
                reaper.SetMediaTrackInfo_Value(child,"B_SHOWINTCP",0)
             end
          end
          ::NEXT::
      end
      RestoreSelectedItems(itemzzz)
      reaper.PreventUIRefresh(-1)
      tcph=reaper.GetMediaTrackInfo_Value(child,"I_TCPH")
      target_tcph=reaper.GetMediaTrackInfo_Value(reaper.GetTrack(0,0),"I_TCPH")
      zoom=math.abs((tcph-target_tcph))/2
      reaper.SetOnlyTrackSelected(child)
      if tcph<target_tcph then
         cmd=41327
      else
         cmd=41328
      end
      
      for abi=1,zoom do
          reaper.Main_OnCommand(cmd,0)
      end
      
      reaper.SetOnlyTrackSelected(reaper.GetParentTrack(child))
      reaper.Undo_EndBlock("Create new track version",-1)
  end
   
  main()
  
