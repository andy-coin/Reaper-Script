  
  r=reaper
  
  -----
  
  local function iterAllMIDINotes(t, idx)
  
      if not idx then return iterAllMIDINotes,t, 0 end
  
      local note = {}
      note.retval, note.selected, note.muted, note.startppqpos, note.endppqpos, 
      note.chan, note.PITCH, note.vel = reaper.MIDI_GetNote(t, idx)
  
      idx = idx + 1
  
      if note.retval then return idx, note end
  
  end
  
  -----
  
  local function get_note_at_mouse(t)
      
      local time = reaper.BR_GetMouseCursorContext_Position()
      mouseppqpos = reaper.MIDI_GetPPQPosFromProjTime(t,time)
  
      for idx, note in iterAllMIDINotes(t) do
  
          if  note.startppqpos <= mouseppqpos 
          and note.endppqpos >= mouseppqpos
          and note.PITCH == ({reaper.BR_GetMouseCursorContext_MIDI()})[3] then
  
              return idx,note,mouseppqpos
  
          end
  
      end
      
  end
  
  -----
  
  local function CheckNote(E,t)
  
      reaper.BR_GetMouseCursorContext()
  
      local idx,note,pos = get_note_at_mouse(t)
      if not (idx and note.retval) then return false end
      
      return idx-1,note,pos
  end
  
  --------------------------------------MAIN---------------------------------------------
  local function main()

      local midi_item={}
      
      local In=reaper.CountSelectedMediaItems(0)
      if In==0 then
         E = reaper.MIDIEditor_GetActive()
         if E then 
            t=reaper.MIDIEditor_GetTake(E)
            reaper.SetMediaItemSelected(reaper.GetMediaItemTake_Item(t),true)
            midi_item[1]="Abigel"
         else
            return 
         end
      else
         for abi=1,In do
             local item=reaper.GetSelectedMediaItem(0,abi-1)
             local take=reaper.GetActiveTake(item)
             if reaper.TakeIsMIDI(take) then
                midi_item[abi]=reaper.GetSelectedMediaItem(0,abi-1)
             end
         end
      end
      
      local E = reaper.MIDIEditor_GetActive()
      
      if #midi_item==1 then
         t = reaper.MIDIEditor_GetTake(E)
         local SEL=false
         local pick,note,cut=CheckNote(E,t)
         if not pick then return end
         _,ALL,_,_ = reaper.MIDI_CountEvts(t)
         for abi=1,ALL do
             local _,sel = reaper.MIDI_GetNote(t,abi-1)
             if sel then 
                SEL=true
                break
             end
         end
         if not SEL then
            if pick then 
               reaper.MIDI_SetNote(t,pick,note.selected, note.muted, note.startppqpos,cut)
               goto END
            end
            return
         end
         if not note.selected then return end
         for abii=1,ALL do
             local _,selected,muted,s,e = reaper.MIDI_GetNote(t,abii-1)
             if selected and s<cut and e>cut then
                reaper.MIDI_SetNote(t,abii-1,selected,muted,s,cut)
             end  
         end
      else
         for abi=1,#midi_item do
             t=reaper.GetActiveTake(midi_item[abi])
             _,ALL,_,_ = reaper.MIDI_CountEvts(t)
             for abi=1,ALL do
                 local _,sel = reaper.MIDI_GetNote(t,abi-1)
                 if sel then 
                    SEL=true
                    break
                 end
             end
             if SEL then break end
         end
         for abi=1,#midi_item do
             t=reaper.GetActiveTake(midi_item[abi])
             pick,note,cut=CheckNote(E,t)
             if pick then
                if not SEL then
                   reaper.MIDI_SetNote(t,pick,note.selected, note.muted, note.startppqpos,cut)
                   return
                end
                break
             end
         end
         if not pick then return end
         for abi=1,#midi_item do
             t=reaper.GetActiveTake(midi_item[abi])
             reaper.BR_GetMouseCursorContext()
             local time = reaper.BR_GetMouseCursorContext_Position()
             local cut = reaper.MIDI_GetPPQPosFromProjTime(t,time)
             _,ALL,_,_ = reaper.MIDI_CountEvts(t)
             if note.selected then
                for abii=1,ALL do
                    local _,selected,muted,s,e = reaper.MIDI_GetNote(t,abii-1)
                    if selected and s<cut and e>cut then
                       reaper.MIDI_SetNote(t,abii-1,selected,muted,s,cut)
                    end  
                end
             end
         end
      end 
      ::END::
      if midi_item[1]=="Abigel" then
         reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0,0),false)
         reaper.UpdateArrange()
      end
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Split selected notes under mouse cursor",-1)

