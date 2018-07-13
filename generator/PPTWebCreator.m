function PPTWebCreator(PPT)
  global rowid;
  rowid = -1;
  enable_sound = true;
  outfile = fopen(strcat("../PPTFile/", int2str(PPT), ".csv"), 'W');
  PPTFileCreator(PPT);
  load(strcat("../PPTFile/", int2str(PPT), "_PPTFile"));

  pposarr = [1,3,2,4,2,3,1,4,3,2,1,4,3,4,1,2,1,3,4,2,1,3,2,4];
  plenarr = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
  pcatarr = [3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];

  MKHeader(outfile);
  MKSequence(outfile, pposarr, plenarr, pcatarr, enable_sound);
  MKDialog(outfile, "dialog2", 2500);
  SetSpeed(outfile, -1);
  SetScore(outfile, -1);
  SetSpeed(outfile, 1);

  MKSequence(outfile, Level1Order, Level1ISIs, Level1Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  MKSequence(outfile, Level1Order, Level2ISIs, Level2Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  MKSequence(outfile, Level1Order, Level3ISIs, Level3Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  MKSequence(outfile, Level1Order, Level4ISIs, Level4Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  MKSequence(outfile, Level1Order, Level5ISIs, Level5Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  MKSequence(outfile, Level1Order, Level6ISIs, Level6Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);

  fclose(outfile);
end

function MKHeader(fd)
  global rowid;
  PrintRow(fd, "cue_row_id", "type", "value", "appear_time_ms", "time_to_targ_ms", "category");
  SetSpeed(fd, 0);
  MKDialog(fd, "dialog0", 0);
  rowid--;
  MKDialog(fd, "dialog1", 0);
end

function MKSequence(fd, posarr, lenarr, catarr, sound)
  for i = 1:(length(posarr))
    MKFall(fd, s(posarr(i) - 1), sound, lenarr(i), catarr(i));
  end
end

function MKFall(fd, value, sound, length, category)
  if(sound); type_string = "cue"; else; type_string = "off"; end % why cant we have a ternary operator?
  switch category
    case 0
      cat = "s";
    case 1
      cat = "n";
    case 3
      cat = "p";
  end
  
  l = length * 350;
  MKRow(fd, type_string, s(value), s(l), s(1500), cat);
end

function MKDialog(fd, dialogstr, appear_time_ms)
  MKRow(fd, "dialog", dialogstr, s(appear_time_ms), s(0), s(0));
end

function SetSpeed(fd, sped) % apparently speed is a reserved word
  MKRow(fd, "speed", s(sped), s(0), s(0), s(0));
end

function SetScore(fd, score)
  MKRow(fd, "score", s(score), s(0), s(0), s(0));
end

function MKRow(fd, type, value, appear_time_ms, time_to_targ_ms, category)
  global rowid;
  PrintRow(fd, s(++rowid), type, value, appear_time_ms, time_to_targ_ms, category);
end

function PrintRow(fd, cue_row_id, type, value, appear_time_ms, time_to_targ_ms, category)
  fprintf(fd, "%s,%s,%s,%s,%s,%s\n", cue_row_id, type, value, appear_time_ms, time_to_targ_ms, category);
end

function i = s(num)
  i = int2str(num);
end
