function PPTFileCreator(PPTStr, Avoid)

  rand('state', sum(100*clock));
  load('Seqs');                                                                    % First, we need to load the Sequences   
  LevelType = logical([zeros(1,6) ones(1,1)]);                                     % LevelType: logical array that defines which levels are training/test
  SeqLngth       = 12;                                                             % SeqLngth is the Sequence Length!
  blockLngth     = SeqLngth * 5;
  blocksPerLevel = 8;                                                              % I want 8 training blocks per level (1 block = 60 cues -> 480 cues)

  % get a sequence offset not equivilant to Avoid
  num = Randi(size(OrthNoRuns, 1));
  while num == Avoid
    num = Randi(size(OrthNoRuns, 1));
  end

  TrainingSeqs = OrthNoRuns(num,Shuffle([1 2 3]));
  ISISeq       = circshift(AllISIs(Randi(size(AllISIs,1)),1:SeqLngth),[0 Randi(11)]);
  Seq          = circshift(AllSOCs(TrainingSeqs(1),1:SeqLngth),[0 Randi(11)]);
  ImpF1        = circshift(AllSOCs(TrainingSeqs(2),1:SeqLngth),[0 Randi(11)]);
  ImpF2        = circshift(AllSOCs(TrainingSeqs(3),1:SeqLngth),[0 Randi(11)]);
  % These while loops spin around the Foils so that we have no doubles during test!
  while (ImpF1(1) == Seq(12)) || (ImpF1(12) == Seq(1))
    ImpF1 = circshift(ImpF1,[0 1]);
  end
  while (ImpF2(1) == Seq(12)) || (ImpF2(12) == Seq(1)) || (ImpF2(1) == ImpF1(12)) || (ImpF2(12) == ImpF1(1))
    ImpF2 = circshift(ImpF2,[0 1]);
  end
  % Now I want to delete out the sequences used for training and test
  AllSOCs(TrainingSeqs,:) = [];
  % And set the rest to be used as foils and noise during training
  NoisePool = AllSOCs; 
  
  clear AllSOCs OrthNoRuns AllISIs
  
  for i = 1:size(NoisePool,1)                                                      % Randomizing the starting point 
    NoisePool(i,1:SeqLngth) = circshift(NoisePool(i,1:SeqLngth),[0 Randi(11)]);    % of the rest of the noise sequences by shifting
  end                                                                              % all of them over a random amount from 1 - 11.
  NoisePool(Shuffle(1:size(NoisePool,1)),1:12) = NoisePool;                        % Then shuffle the hell out of it.

  RecF1 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                            % I need four recognition foils
  RecF2 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                            % This allows me to have 4 completely random foils that are
  RecF3 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                            % also completely novel during the SISL test and Recog Test
  RecF4 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];

  % Now that I have my sequences assigned and my NoisePool and everything
  % else, I need to start constructing the training. 
  % Blocks   1:48
  
  for blockNum = 1:(sum(LevelType == 0) * blocksPerLevel)                          % This loop will run through all the blocks, starting with 
    if blockNum == 1                                                               % block 1, which is Sequence A, then running through the rest...
      LevelOrder = [NoisePool(1,1:SeqLngth) Seq Seq Seq Seq]; NoisePool(1,:) = []; % Noise, 4 SeqReps, Delete the used NoiseSeq
      LevelNoise = [ones(1,SeqLngth)        zeros(1,48)    ];                      % Make the Noise Array according to above

    elseif any(blockNum == 09:blocksPerLevel:48)                                   % These are the first blocks for each Seq level
      LevelOrder = [LevelOrder NoisePool(1,1:SeqLngth) Seq Seq Seq Seq]; NoisePool(1,:) = [];
      LevelNoise = [LevelNoise ones(1,SeqLngth) zeros(1,48)];                      % I want each block to start just like before, but I had to

    elseif blockNum <= 48                                                          % do this separately since at block1, there is no LevelOrder yet
      a = RandSample([1:SeqLngth:blockLngth]);                                     % I want a starting point in each block for the NoiseSeq
      block = zeros(1,blockLngth); noise = zeros(1,blockLngth);                    % Setting up the blank block and noise for the new block
      block(a:a+11) = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                % Adding in the NoiseSeq (and deleting it)
      noise(block ~= 0) = ones(1,SeqLngth);                                        % Making sure my LevelNoise puts in the noises
      block(block == 0) = [Seq Seq Seq Seq];                                       % The rest of the block is made up of four SeqReps
      LevelOrder = [LevelOrder block];                                             % Tack the block on to the end of each loop 
      LevelNoise = [LevelNoise noise];                                             % Same goes for Noise!
    end
  end

  % At this point, NoisePerc doesn't matter.
  x = SeqLngth:SeqLngth:(length(LevelOrder)-1);                                    % I need a sanity checker to make sure I don't have any 
  y = (SeqLngth+1):SeqLngth:length(LevelOrder);                                    % repeating trials. 
  while any(LevelOrder(x) == LevelOrder(x+1))                                      % X and Y are the points where sequences meet. I need to to run
    for i = 1:length(x)                                                            % while there are still repeats. If there ARE repeats,
      while LevelOrder(x(i)) == LevelOrder(y(i))                                   % It needs to find the repeat, figure out WHICH one is the noise
        if LevelNoise(x(i)) == 1                                                   % since Sequences can't repeat, and can't be shifted.
          LevelOrder(x(i)-11:x(i)) = circshift(LevelOrder(x(i)-11:x(i)),[0 1]);    % If noise is the beginning sequence, shift
        elseif LevelNoise(y(i)) == 1                                               % That position and the 11 spots preceding it.
          LevelOrder(y(i):y(i)+11) = circshift(LevelOrder(y(i):y(i)+11),[0 1]);    % However, if the noise is the second sequence
        end                                                                        % then we need to shift that spot and the 11 spots after it.
      end                                                                          % Just keep shifting noises by one until we have no more repeats.
    end                                                                            % The main while loop is necessary because sometimes shifting to 
  end                                                                              % fix one repeat creates another.

  lvlBgn = 1                           : (blocksPerLevel*blockLngth) : length(LevelOrder); % individual level arrays
  lvlEnd = (blocksPerLevel*blockLngth) : (blocksPerLevel*blockLngth) : length(LevelOrder); % based on trial number!

  Level1Order  = LevelOrder(lvlBgn( 1):lvlEnd( 1));   Level2Order  = LevelOrder(lvlBgn( 2):lvlEnd( 2));
  Level3Order  = LevelOrder(lvlBgn( 3):lvlEnd( 3));   Level4Order  = LevelOrder(lvlBgn( 4):lvlEnd( 4));
  Level5Order  = LevelOrder(lvlBgn( 5):lvlEnd( 5));   Level6Order  = LevelOrder(lvlBgn( 6):lvlEnd( 6));

  Level1Noise  = logical(LevelNoise(lvlBgn( 1):lvlEnd( 1)));   Level2Noise  = logical(LevelNoise(lvlBgn( 2):lvlEnd( 2)));
  Level3Noise  = logical(LevelNoise(lvlBgn( 3):lvlEnd( 3)));   Level4Noise  = logical(LevelNoise(lvlBgn( 4):lvlEnd( 4)));
  Level5Noise  = logical(LevelNoise(lvlBgn( 5):lvlEnd( 5)));   Level6Noise  = logical(LevelNoise(lvlBgn( 6):lvlEnd( 6)));

  % generate Level 7 and 8 orders with foils
  testBlocks = {[Seq Seq Seq Seq Seq], [ImpF1 ImpF1 ImpF1 ImpF1 ImpF1]};
  testNoiseBlocks  = {[ones(1, SeqLngth * 5) * 0], [ones(1, SeqLngth * 5) * 2]};
  TestOrderKey = [Shuffle(1:2) Shuffle(1:2)];
  while any(TestOrderKey(1:length(TestOrderKey)-1) == TestOrderKey(2:length(TestOrderKey)))
    TestOrderKey = [Shuffle(1:2) Shuffle(1:2)];
  end
  testOrder    = [testBlocks{TestOrderKey}];
  testNoise    = [testNoiseBlocks{TestOrderKey}];

  Level7Order  = testOrder;
  Level7Noise  = testNoise;

  testBlocks = {[Seq Seq Seq Seq Seq], [ImpF2 ImpF2 ImpF2 ImpF2 ImpF2]};
  testNoiseBlocks  = {[ones(1, SeqLngth * 5) * 0], [ones(1, SeqLngth * 5) * 3]};
  TestOrderKey = [Shuffle(1:2) Shuffle(1:2)];
  while any(TestOrderKey(1:length(TestOrderKey)-1) == TestOrderKey(2:length(TestOrderKey)))
    TestOrderKey = [Shuffle(1:2) Shuffle(1:2)];
  end
  testOrder    = [testBlocks{TestOrderKey}];
  testNoise    = [testNoiseBlocks{TestOrderKey}];

  Level8Order  = testOrder;
  Level8Noise  = testNoise;
  
  ISIs = ISISeq;
  for i = 1:6
    ISIs = [ISIs ISIs];
  end

  Level1ISIs  = ISIs(1:length(Level1Order));  Level2ISIs = ISIs(1:length(Level2Order));   Level3ISIs = ISIs(1:length(Level3Order)); 
  Level4ISIs  = ISIs(1:length(Level4Order));  Level5ISIs = ISIs(1:length(Level5Order));   Level6ISIs = ISIs(1:length(Level6Order)); 
  Level7ISIs  = ISIs(1:length(Level7Order));  Level8ISIs = ISIs(1:length(Level8Order));

  % Geerate post test orders
  Post1Order = [Seq   Seq  ];
  Post2Order = [ImpF1 ImpF1];
  Post3Order = [ImpF2 ImpF2];
  Post4Order = [RecF3 RecF3];
  Post5Order = [RecF4 RecF4];

  % Generate post test ISIs
  Post1ISIs = [ISISeq ISISeq];
  Post2ISIs = [ISISeq ISISeq]; 
  Post3ISIs = [ISISeq ISISeq];
  Post4ISIs = [ISISeq ISISeq];
  Post5ISIs = [ISISeq ISISeq];

  % Clear unused variables
  clear T1 T2 T3 Order1 Order2 Order3 ISISeqs ISIs LevelOrder LevelNoise LevelReps  AllSOCs   ...
        levelBlock i j x y a lvlBgn lvlEnd noise reps block blockNum testBlocks testOrder     ...
	testNoise testNoiseBlock Seq RecF1 RecF2 RecF3 RecF4 SeqLngth TestOrderKey blockLngth ...
	TrainingSeqs argn blocksPerLevel testNoiseBlocks ISISeq ImpF1 ImpF2

  save(['../PPTFile/' PPTStr '_PPTFile'])

end
