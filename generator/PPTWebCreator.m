function PPTWebCreator(PPT)
  if randi(2) == 1
    TestFileMaker(strcat(s(PPT), "-1"), -1, true)
    load(strcat("../PPTFile/",s(PPT), "-1" , "_PPTFile"));
    TestFileMaker(strcat(s(PPT), "-2"), num, false)
  else
    TestFileMaker(strcat(s(PPT), "-1"), -1, false)
    load(strcat("../PPTFile/",s(PPT), "-1" , "_PPTFile"));
    TestFileMaker(strcat(s(PPT), "-2"), num, true)
  end
end

function TestFileMaker(PPTStr, Avoid, sound)
  global rowid;
  rowid = -1;
  enable_sound = sound;
  outfile = fopen(strcat("../PPTFile/", PPTStr, ".csv"), 'W');
  PPTFileCreator(PPTStr, Avoid);
  load(strcat("../PPTFile/", PPTStr, "_PPTFile"));

  pposarr = [1,3,2,4,2,3,1,4,3,2,1,4,3,4,1,2,1,3,4,2,1,3,2,4];
  plenarr = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
  pcatarr = [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4];

  MKHeader(outfile);
  MKSequence(outfile, pposarr, plenarr, pcatarr, enable_sound);
  MKDialog(outfile, "dialog2", 2500);
  SetSpeed(outfile, -1);
  SetScore(outfile, -1);
  SetSpeed(outfile, 1);

  MKSequence(outfile, Level1Order, Level1ISIs, Level1Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level2Order, Level2ISIs, Level2Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level3Order, Level3ISIs, Level3Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level4Order, Level4ISIs, Level4Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level5Order, Level5ISIs, Level5Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level6Order, Level6ISIs, Level6Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level7Order, Level7ISIs, Level7Noise, enable_sound);
  MKDialog(outfile, "dialog3", 2500);
  SetScore(outfile, -1);
  MKSequence(outfile, Level8Order, Level8ISIs, Level8Noise, !enable_sound);
  MKDialog(outfile, "dialog4", 2500);
  SetScore(outfile, -1);
  MKDialog(outfile, "dialog5", 2500);
  SetSpeed(outfile, 0);

  recorder = randperm(5);
  for i = recorder
    MKDialog(outfile, "dialog6", 500);
    switch i
      case 1
	MKSequence(outfile, Post1Order, Post1ISIs, ones(1, length(Post1Order)) * 0, enable_sound)
      case 2
	MKSequence(outfile, Post2Order, Post2ISIs, ones(1, length(Post2Order)) * 2, enable_sound)
      case 3
	MKSequence(outfile, Post3Order, Post3ISIs, ones(1, length(Post3Order)) * 3, !enable_sound)
      case 4
	MKSequence(outfile, Post4Order, Post4ISIs, ones(1, length(Post4Order)) * 1, enable_sound)
      case 5
	MKSequence(outfile, Post5Order, Post5ISIs, ones(1, length(Post5Order)) * 1, !enable_sound)
    end
    MKDialog(outfile, "dialog7", 5000);
  end
  MKDialog(outfile, "dialog8", 2500);

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
      cat = "sequence";
    case 1
      cat = "noise";
    case 2
      cat = "impfoil1";
    case 3
      cat = "impfoil2";
    case 4
      cat = "practice";
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
