%USAGE: PPTWebCreator(PPT) - generates test files PPT-1.csv and PPT-2.csv in the ../PPTFile directory
% On matlab this should be faster because it uses outputfile buffering, if using octave this should be run from tmpfs or ramfs for maximum performance

function PPTWebCreator(PPT)
  % Pick a random sound order
  if randi(2) == 1
    TestFileMaker(strcat(s(PPT), "-1"), -1, true)             % Generate the first PPTFile
    load(strcat("../PPTFile/",s(PPT), "-1" , "_PPTFile"));    % Load so we can extract num
    TestFileMaker(strcat(s(PPT), "-2"), num, false)           % Generate a second test file using a different sequence and inverting sound
  else
    TestFileMaker(strcat(s(PPT), "-1"), -1, false)
    load(strcat("../PPTFile/",s(PPT), "-1" , "_PPTFile"));
    TestFileMaker(strcat(s(PPT), "-2"), num, true)
  end
end

%USAGE: TestFileMaker(PPTStr, Avoid, sound) - generate an example test file with name PPTStr.csv
% without using Sequence Avoid, and with majority sound determined by sound
function TestFileMaker(PPTStr, Avoid, sound)
  % keep track of our row
  global rowid;
  rowid = -1;
  enable_sound = sound;
  % open an outputfile in buffered mode (octave doesnt appear to support buffering, so is much slower)
  outfile = fopen(strcat("../PPTFile/", PPTStr, ".csv"), 'W');
  % generate the actual pptfile using the original generator
  PPTFileCreator(PPTStr, Avoid);
  load(strcat("../PPTFile/", PPTStr, "_PPTFile"));

  pposarr = [1,3,2,4,2,3,1,4,3,2,1,4,3,4,1,2,1,3,4,2,1,3,2,4];
  plenarr = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
  pcatarr = [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4];

  % Make our header and practice sequence. This is the same for every participant
  MKHeader(outfile);
  MKSequence(outfile, pposarr, plenarr, pcatarr, enable_sound);
  MKDialog(outfile, "dialog2", 2500);
  SetSpeed(outfile, -1);
  SetScore(outfile, -1);
  SetSpeed(outfile, 1);

  MKSequence(outfile, Level1Order, Level1ISIs, Level1Noise, enable_sound);  % output our level 1 sequence
  MKDialog(outfile, "dialog3", 2500);                                       % add break dialog
  SetScore(outfile, -1);                                                    % reset score
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
  MKSequence(outfile, Level8Order, Level8ISIs, Level8Noise, !enable_sound); % invert sound for level 8
  MKDialog(outfile, "dialog4", 2500);
  SetScore(outfile, -1);
  MKDialog(outfile, "dialog5", 2500);
  SetSpeed(outfile, 0);

  % generate post test order
  recorder = randperm(5);
  for i = recorder
    % generate front bookend dialog
    MKDialog(outfile, "dialog6", 500);
    % output sequence dependent on the order of the recognition test order (recorder)
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
    % generate read bookend dialog
    MKDialog(outfile, "dialog7", 5000);
  end
  % generare the thank you dialog
  MKDialog(outfile, "dialog8", 2500);

  % close and save our file
  fclose(outfile);
end

%USAGE: MKHeader(fd) - make the header we use at the beginning of each test and output to the file fd
function MKHeader(fd)
  global rowid;

  % add csv column names
  PrintRow(fd, "cue_row_id", "type", "value", "appear_time_ms", "time_to_targ_ms", "category");
  SetSpeed(fd, 0);
  MKDialog(fd, "dialog0", 0);
  % not sure why we do this, but this is how its written in the example csv, so both dialogs have the same row id
  rowid--;
  MKDialog(fd, "dialog1", 0);
end

%USAGE: MKSequence(fd, posarr, lenarr, catarr, sound) - generate sequence from Order array (posarr), ISI array (lenarr),
% category array (catarr) [noise vs sequence vs foil], with sound enabled or disabled  (true or false), and output to fd
function MKSequence(fd, posarr, lenarr, catarr, sound)
  for i = 1:(length(posarr))
    MKFall(fd, s(posarr(i) - 1), sound, lenarr(i), catarr(i));
  end
end

%USAGE: MKFall(fd, value, sound, length, category) - generate block in row value, with sound on or off, of length length,
% and with category category, and output to file fd
function MKFall(fd, value, sound, length, category)
  % get string from sound bool
  if(sound); type_string = "cue"; else; type_string = "off"; end % why cant we have a ternary operator?
  % get string from category
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

  % determine length in milliseconds
  l = length * 350;
  MKRow(fd, type_string, s(value), s(l), s(1500), cat);
end

%USAGE: MKDialog(fd, dialogstr, appear_time_ms) - generate a dialog with identifier dialogstr, that appears
% for appear_time_ms, and output to file fd
function MKDialog(fd, dialogstr, appear_time_ms)
  MKRow(fd, "dialog", dialogstr, s(appear_time_ms), s(0), s(0));
end

%USAGE: SetSpeed(fd, sped) - set speed in file fd to sped
function SetSpeed(fd, sped) % apparently speed is a reserved word
  MKRow(fd, "speed", s(sped), s(0), s(0), s(0));
end

%USAGE: SetScore(fd, score) - set score in file fd to score
function SetScore(fd, score)
  MKRow(fd, "score", s(score), s(0), s(0), s(0));
end

%USAGE: MKRow(fd, type, value, appear_time_ms, time_to_targ_ms, category) - generate a row in the file fd with columns
% defined by the arguments of the same name, and auto increment the rowid
function MKRow(fd, type, value, appear_time_ms, time_to_targ_ms, category)
  global rowid;
  PrintRow(fd, s(++rowid), type, value, appear_time_ms, time_to_targ_ms, category);
end

%USAGE: PrintRow(fd, cue_row_id, type, value, appear_time_ms, time_to_targ_ms, category) - print a row to fd, with columns
% defined by arguments of the same name
function PrintRow(fd, cue_row_id, type, value, appear_time_ms, time_to_targ_ms, category)
  fprintf(fd, "%s,%s,%s,%s,%s,%s\n", cue_row_id, type, value, appear_time_ms, time_to_targ_ms, category);
end

%USAGE: s(num) - shortcut to cunvert num to a string
function i = s(num)
  i = int2str(num);
end
