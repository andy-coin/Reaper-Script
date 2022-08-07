  
  r=reaper
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackabi={}
  trackzzz={}
  trackzz={}
  local function SaveSelectedTracks (table)--trackabi
    
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks(table)--trackabi
    reaper.Main_OnCommand(40297,0)
    if #table~=0 then   
       reaper.SetOnlyTrackSelected(table[#table])
    end
    for i=1,#table do
        reaper.SetTrackSelected(table[i],true)
    end
    for _, track in ipairs(table) do
      --reaper.SetTrackSelected(track,true)
    end
  end
  
  -----------------------------------------------------------------------------------
  local function DeepCopy(ori_table)
    local copy_table={}
    for abi=1,#ori_table do
      local a=ori_table[abi]
      copy_table[abi]=a
    end
    return copy_table
  end
  
  ----------------------------------------------------------------------------------
  local function KillRepeatValue(missabi)
    
    t=DeepCopy(missabi)
    table.sort(t)
    
    if t[1]==t[#t] then
      return t,1
    end
    
    abi=1
    repeat
      if t[abi]==t[abi+1]then
        table.remove(t,abi+1) 
      else
        abi=abi+1
      end
    until abi==#t 
  
    return t,#t
  end
  
  -----
  local function CountChildrenTrack(trrr)
      idx=reaper.GetMediaTrackInfo_Value(trrr,"IP_TRACKNUMBER")
      Abigel=0
      repeat
      tmp=reaper.GetTrack(0,idx+Abigel)
      Abigel=Abigel+1
      until -1 == reaper.GetMediaTrackInfo_Value(tmp,"I_FOLDERDEPTH") or Abigel==500
      return Abigel
  end
  
  -----
  local function SetTrackHeight(trr,bbest)
      
      _,cchunk=reaper.GetTrackStateChunk(trr,"",false)
      x=reaper.GetMediaTrackInfo_Value(trr,"I_TCPH")
      Cchunk=string.gsub(cchunk,cchunk:match("TRACKHEIGHT "..tostring(math.floor(x))),"TRACKHEIGHT "..bbest)
      reaper.SetTrackStateChunk(trr,Cchunk,false)
      
  end
  
  -----
  local function SetTrackHeight2(cODE,tCPH,trable)
      
      trrrr={}
      for xuan=1,#cODE do
          trrrr[xuan]=reaper.BR_GetMediaTrackByGUID(0,cODE[xuan])
          _,ccchunk=reaper.GetTrackStateChunk(trrrr[xuan],"",false)
          xx=reaper.GetMediaTrackInfo_Value(trrrr[xuan],"I_TCPH")
          Ccchunk=string.gsub(ccchunk,ccchunk:match("TRACKHEIGHT "..tostring(math.floor(xx))),"TRACKHEIGHT "..tCPH[xuan])
          reaper.SetTrackStateChunk(trrrr[xuan],Ccchunk,false)
      end
      
  end
  
  ----------------------------------------------------------------------------------
  local nl = string.char(10) -- newline
  local function serialize (tabl, indent)
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
  
  ----------------------------------------------------------------------------------
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
  
  ------------------------------------------------------------------------------
  local function SaveVerticalZoom(TR_TCPH,TR_code)
 
    local TR_TCPH = serialize(TR_TCPH)
    local TR_code = serialize(TR_code)
    ext_name = "Vertical zoom 1_TR_TCPH"
    reaper.SetExtState(ext_name,"Vertical zoom 1_TR_TCPH",TR_TCPH, true)
    
    ext_name = "Vertical zoom 1_TR_code"
    reaper.SetExtState(ext_name,"Vertical zoom 1_TR_code",TR_code, true)
  
  end
  
  -----------------------------------------------------------------------------------
  local function LoadVerticalZoom()
    
    SaveSelectedTracks(trackzzz)
    local ext_name = "Vertical zoom 1_TR_code"
    local TR_code = reaper.GetExtState(ext_name,"Vertical zoom 1_TR_code",false)
    
    local ext_name = "Vertical zoom 1_TR_TCPH"
    local TR_TCPH = reaper.GetExtState(ext_name,"Vertical zoom 1_TR_TCPH",false)
    
    local code=unserialize(TR_code)
    local TCPH=unserialize(TR_TCPH)
    --SetTrackHeight2(code,TCPH)
    local tr={}
    local tcph={}
    cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
    
    if type(code[1])=='table' then
      for abi=1,#code do 
        reaper.Main_OnCommand(40297,0)
        for abii=1,#code[abi] do
          tr[abii]=reaper.BR_GetMediaTrackByGUID(0,code[abi][abii])
          if tr[abii] then 
            tcph[#tcph+1]=reaper.GetMediaTrackInfo_Value(tr[abii],"I_TCPH")
            if tcph[#tcph] ~= TCPH[abi] then
              reaper.SetTrackSelected(tr[abii],true)
            end
          end
        end
        times=(TCPH[abi]-22)/2
        reaper.Main_OnCommand(cmd,0)--minimize selected tracks
        for abii=1,times do
          reaper.Main_OnCommand(41327,0)--increase track height a bit
        end
      end
    else
      for abi=1,#code do 
        reaper.Main_OnCommand(40297,0)
        tr[abi]=reaper.BR_GetMediaTrackByGUID(0,code[abi])
        if tr[abi] then 
          tcph[#tcph+1]=reaper.GetMediaTrackInfo_Value(tr[abi],"I_TCPH")
          if tcph[#tcph] ~= TCPH[abi] then
            reaper.SetTrackSelected(tr[abi],true)
          end
        end
        times=(TCPH[abi]-22)/2
        reaper.Main_OnCommand(cmd,0)--minimize selected tracks
        for abii=1,times do
          reaper.Main_OnCommand(41327,0)--increase track height a bit
        end
      end
    end
    
    RestoreSelectedTracks(trackzzz)
    
  end
    
  -----------------------------------Folder State---------------------------------------
  local function FolderState()
  
    trackzz={}
    
    local tr_all={}
    local tcph_ori={}
    local TR_code={}
    local small = 0
    local tinY = 0
    local TCPH=0
    local hide=0
    abi=0
    repeat 
      tr_all[abi+1] = reaper.GetTrack(0,abi)
       if reaper.GetMediaTrackInfo_Value(tr_all[abi+1],"B_SHOWINTCP")==1 then
        _,TR_code[#TR_code+1] = reaper.GetSetMediaTrackInfo_String(tr_all[abi+1],"GUID","",false)
        tcph_ori[#tcph_ori+1] = reaper.GetMediaTrackInfo_Value(tr_all[abi+1],"I_TCPH")
        TCPH=TCPH+tcph_ori[#tcph_ori]
        if 1 == reaper.GetMediaTrackInfo_Value(tr_all[abi+1],"I_FOLDERDEPTH") then
            reaper.SetOnlyTrackSelected(tr_all[abi+1],true)
          if 1==reaper.GetMediaTrackInfo_Value(tr_all[abi+1],"I_FOLDERCOMPACT") then-- small children
            newmember=CountChildrenTrack(tr_all[abi+1])
            abi=abi+newmember+1
            small=small+newmember
            goto tail
          elseif 2==reaper.GetMediaTrackInfo_Value(tr_all[abi+1],"I_FOLDERCOMPACT")then--tiny children
            newmember=CountChildrenTrack(tr_all[abi+1])
            tinY=tinY+newmember
            abi=abi+newmember+1
            goto tail
          end
        end
      end
      abi=abi+1
      ::tail::
    until abi==reaper.CountTracks(0)
  
    local code=DeepCopy(TR_code)
    local V,N=KillRepeatValue(tcph_ori)
          
    TR_GROUP={}
    
    if N>1 then
      for abi=1,N do
        TR_GROUP[abi]={}
        abii=1
        repeat  
          if tcph_ori[abii]==V[abi] then
            TR_GROUP[abi][#TR_GROUP[abi]+1]=TR_code[abii]
            table.remove(TR_code,abii)
            table.remove(tcph_ori,abii)
          else
            abii=abii+1
          end
        until abii-1 == #TR_code 
      end
    else
      TR_GROUP=TR_code
    end

    return TCPH,tinY,small,#code,V,code,TR_GROUP
     
  end
  
  ----------------------------------MAIN ACTION------------------------------------
  local function main()
    
    SaveSelectedTracks(trackabi)
    local tr_n = reaper.CountTracks(0)
    if tr_n == 0 then return end
    
    TCPH,X,Y,Z,V,all_code,TR_GROUP=FolderState()
   
    space = 1160-0*X-24*Y
    tcph = math.floor(TCPH/Z)
    best = math.floor(space/Z)
    
    if best%2==1 then
       best=best+1
    end
    
    if tcph%2==1 then
       tcph=tcph+1
    end
    
    if best < 24 then
       best = 24
    elseif best > 232 then 
       best = 232
    end  
    
    dis=best-tcph
    
    if  dis ~= 0 then 
        Toggle=1
        SaveVerticalZoom(V,TR_GROUP)
        cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
        for abi=1,#all_code do
          trr=reaper.BR_GetMediaTrackByGUID(0,all_code[abi])
          --SetTrackHeight(trr,best)
          reaper.SetTrackSelected(trr,true)
        end
        reaper.Main_OnCommand(cmd,0)
        
        times = math.floor((best-22)/2)

        for abi=1,times do
            reaper.Main_OnCommand(41327,0)
        end
        
      if #all_code<=49 then
        cmd = reaper.NamedCommandLookup("_XENAKIOS_TVPAGEHOME")
        reaper.Main_OnCommand(cmd,0)--scroll to top
      end
      
    else
      Toggle=0
      LoadVerticalZoom()
    end
    
    RestoreSelectedTracks(trackabi)
    if Toggle==0 then
       reaper.Main_OnCommand(40913,0)--Vertical scroll selected tracks into view 
    end
    reaper.UpdateArrange()
    
  end
  
  reaper.defer(main)

  

