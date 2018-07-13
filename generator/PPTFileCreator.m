function PPTFileCreator(PPT)

    % PPTFileCreator(PPT)
    % PPT   = Participant number. So, 101, 102, etc.
    % This monster script creates two very important files. The PPTFile and the PostTestFile. 
    % The PPTFile is the list of variables and everything else that will be used in the SISL task. 
    % The PostTestFile is a separate file to run the SISL Recognition test. 
    % The PostTestFile is basically the same thing as the PPTFile, but less complicated.

    rand('state', sum(100*clock));
    load('Seqs');                                                           % First, we need to load the Sequences   
    LevelType = logical([zeros(1,6) ones(1,1)]);                            % LevelType: logical array that defines which levels are training/test
    SeqLngth       = 12;                                                    % SeqLngth is the Sequence Length!
    blockLngth     = SeqLngth * 5;                                          % Why not define it?
    blocksPerLevel = 8;                                                     % I want 8 training blocks per level (1 block = 60 cues -> 480 cues)
%     seqReps             = (sum(LevelType == 0) * blocksPerLevel) * 4;       % Number of Sequence Repetitions for 20% Noise
    initialTimeToTarget = 1.50;                                             % The initial speed the program will start at. (time to target in seconds)
    distToTarg          = 583 ;                                             % This is the distance (in pixels) from cue entry to target
    ISI                 = (.350 * (distToTarg/initialTimeToTarget));        % This sets the initial ISI to 350ms
    
    % Now, I'll just make a ton of blank arrays to be filled in later.
    % Each Training level needs to have a LevelReps, LevelOrder, LevelNoise,
    % and LevelBlock array. Test doesn't need Noise, Reps, or Block, since there
    % is no noise in test and the blocks are easily defined.
    % Level Order = The trials broken into single digits for Matlab
    % Level Block = A list of where the blocks are so we can parse through the data
    % Level Noise = Logical arrays for the location of the noise trials during training
        
    Level1Order  = []; Level2Order  = []; Level3Order  = []; Level4Order  = []; Level5Order  = []; Level6Order  = []; Level7Order  = []; % Level8Order = [];
    Level1Block  = []; Level2Block  = []; Level3Block  = []; Level4Block  = []; Level5Block  = []; Level6Block  = []; Level7Block  = []; % Level8Block = [];
    Level1Noise  = []; Level2Noise  = []; Level3Noise  = []; Level4Noise  = []; Level5Noise  = []; Level6Noise  = [];

    % There are 32 distinct sets of THREE orthogonal SOC sequences!
    % To check them out go to NeuroHero Testing area -> Trigrams! -> Trigramer
    % So, first I'll assign them to the training sequence and foil sequences
    % And I also want to randomly grab 1 of the ISI sequences, and
    % randomize the starting point, and assign that to my ISISeq
    TrainingSeqs = OrthNoRuns(Randi(size(OrthNoRuns,1)),Shuffle([1 2 3]));
    ISISeq       = circshift(AllISIs(Randi(size(AllISIs,1)),1:SeqLngth),[0 Randi(11)]);
    Seq          = circshift(AllSOCs(TrainingSeqs(1),1:SeqLngth),[0 Randi(11)]);
    ImpF1        = circshift(AllSOCs(TrainingSeqs(2),1:SeqLngth),[0 Randi(11)]);
    ImpF2        = circshift(AllSOCs(TrainingSeqs(3),1:SeqLngth),[0 Randi(11)]);
    % SeqID is always 1. The training sequence is always the first one, it just happens to always be a random sequence!
    SeqID = TrainingSeqs(1); 
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
                       
    for i = 1:size(NoisePool,1)                                                     % Randomizing the starting point 
        NoisePool(i,1:SeqLngth) = circshift(NoisePool(i,1:SeqLngth),[0 Randi(11)]); % of the rest of the noise sequences by shifting
    end                                                                             % all of them over a random amount from 1 - 11.
    NoisePool(Shuffle(1:size(NoisePool,1)),1:12) = NoisePool;               % Then shuffle the hell out of it.

    RecF1 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                   % I need four recognition foils
    RecF2 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                   % This allows me to have 4 completely random foils that are
    RecF3 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];                   % also completely novel during the SISL test and Recog Test
    RecF4 = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];     

    % Now that I have my sequences assigned and my NoisePool and everything
    % else, I need to start constructing the training. 
    % Blocks   1:48
    
    for blockNum = 1:(sum(LevelType == 0) * blocksPerLevel)                 % This loop will run through all the blocks, starting with 

        if blockNum == 1                                                    % block 1, which is Sequence A, then running through the rest...
            LevelOrder = [NoisePool(1,1:SeqLngth) Seq Seq Seq Seq]; NoisePool(1,:) = [];  % Noise, 4 SeqReps, Delete the used NoiseSeq
            LevelNoise = [ones(1,SeqLngth)        zeros(1,48)    ];                           % Make the Noise Array according to above

        elseif any(blockNum == 09:blocksPerLevel:48)                        % These are the first blocks for each Seq level
            LevelOrder = [LevelOrder NoisePool(1,1:SeqLngth) Seq Seq Seq Seq]; NoisePool(1,:) = [];
            LevelNoise = [LevelNoise ones(1,SeqLngth) zeros(1,48)];         % I want each block to start just like before, but I had to

        elseif blockNum <= 48                                               % do this separately since at block1, there is no LevelOrder yet
            a = RandSample([1:SeqLngth:blockLngth]);                        % I want a starting point in each block for the NoiseSeq
            block = zeros(1,blockLngth); noise = zeros(1,blockLngth);       % Setting up the blank block and noise for the new block
            block(a:a+11) = NoisePool(1,1:SeqLngth); NoisePool(1,:) = [];   % Adding in the NoiseSeq (and deleting it)
            noise(block ~= 0) = ones(1,SeqLngth);                           % Making sure my LevelNoise puts in the noises
            block(block == 0) = [Seq Seq Seq Seq];                      % The rest of the block is made up of four SeqReps
            LevelOrder = [LevelOrder block];                                % Tack the block on to the end of each loop 
            LevelNoise = [LevelNoise noise];                                % Same goes for Noise!
        end
    end
                                                                            % At this point, NoisePerc doesn't matter.
    x = SeqLngth:SeqLngth:(length(LevelOrder)-1);                           % I need a sanity checker to make sure I don't have any 
    y = (SeqLngth+1):SeqLngth:length(LevelOrder);                           % repeating trials. 
    while any(LevelOrder(x) == LevelOrder(x+1))                             % X and Y are the points where sequences meet. I need to to run
        for i = 1:length(x)                                                 % while there are still repeats. If there ARE repeats,
            while LevelOrder(x(i)) == LevelOrder(y(i))                      % It needs to find the repeat, figure out WHICH one is the noise
                if LevelNoise(x(i)) == 1                                    % since Sequences can't repeat, and can't be shifted.
                    LevelOrder(x(i)-11:x(i)) = circshift(LevelOrder(x(i)-11:x(i)),[0 1]);   % If noise is the beginning sequence, shift
                elseif LevelNoise(y(i)) == 1                                                % That position and the 11 spots preceding it.
                    LevelOrder(y(i):y(i)+11) = circshift(LevelOrder(y(i):y(i)+11),[0 1]);   % However, if the noise is the second sequence
                end                                                         % then we need to shift that spot and the 11 spots after it.
            end                                                             % Just keep shifting noises by one until we have no more repeats.
        end                                                                 % The main while loop is necessary because sometimes shifting to 
    end                                                                     % fix one repeat creates another.
        
%     LevelReps = zeros(1,length(LevelOrder))   ;                             % Starting my huge array for LevelReps
%     reps      = zeros(1,(SeqLngth*seqReps))   ;
%     x         = 1:SeqLngth:(length(reps))     ;
%     y         = SeqLngth:SeqLngth:length(reps);
%     for i = 1:length(x)
%        reps(x(i):y(i)) = ones(1,SeqLngth)*i;
%     end
%     
%     LevelReps(LevelNoise == 0) = reps;                                      % So, reps fills in all those spots and leaves the rest '0'
               
    lvlBgn = 1                           : (blocksPerLevel*blockLngth) : length(LevelOrder); % individual level arrays
    lvlEnd = (blocksPerLevel*blockLngth) : (blocksPerLevel*blockLngth) : length(LevelOrder); % based on trial number!

    Level1Order  = LevelOrder(lvlBgn( 1):lvlEnd( 1));   Level2Order  = LevelOrder(lvlBgn( 2):lvlEnd( 2));
    Level3Order  = LevelOrder(lvlBgn( 3):lvlEnd( 3));   Level4Order  = LevelOrder(lvlBgn( 4):lvlEnd( 4));
    Level5Order  = LevelOrder(lvlBgn( 5):lvlEnd( 5));   Level6Order  = LevelOrder(lvlBgn( 6):lvlEnd( 6));
        
    Level1Noise  = logical(LevelNoise(lvlBgn( 1):lvlEnd( 1)));   Level2Noise  = logical(LevelNoise(lvlBgn( 2):lvlEnd( 2)));
    Level3Noise  = logical(LevelNoise(lvlBgn( 3):lvlEnd( 3)));   Level4Noise  = logical(LevelNoise(lvlBgn( 4):lvlEnd( 4)));
    Level5Noise  = logical(LevelNoise(lvlBgn( 5):lvlEnd( 5)));   Level6Noise  = logical(LevelNoise(lvlBgn( 6):lvlEnd( 6)));

%     Level1Reps  = LevelReps(lvlBgn( 1):lvlEnd( 1));   Level2Reps  = LevelReps(lvlBgn( 2):lvlEnd( 2));
%     Level3Reps  = LevelReps(lvlBgn( 3):lvlEnd( 3));   Level4Reps  = LevelReps(lvlBgn( 4):lvlEnd( 4));
%     Level5Reps  = LevelReps(lvlBgn( 5):lvlEnd( 5));   Level6Reps  = LevelReps(lvlBgn( 6):lvlEnd( 6));
        
    levelBlock  = zeros(1,length(Level1Order))              ;
    x           = 1         :blockLngth:(length(levelBlock));
    y           = blockLngth:blockLngth:(length(levelBlock));
    for i = 1:length(x)
       levelBlock(x(i):y(i)) = ones(1,blockLngth)*i;
    end

    % All the training blocks are the same despite noise type or percent!
    % Frankly, I'm not sure this even matters too much, but it means I won't have to edit the NHScore file.
    Level1Block  = levelBlock; Level2Block  = levelBlock; Level3Block  = levelBlock;  
    Level4Block  = levelBlock; Level5Block  = levelBlock; Level6Block  = levelBlock; 
        
%     x = Shuffle(1:size(NoisePool,1));
%     x(16:length(x)) = [];
%     noiseReset = NoisePool(x,1:SeqLngth);
%     NoisePool(x,:) = [];
%     noiseReset = reshape(noiseReset',1,180);
    
    % Finally, the test level order!
    testBlocks = {[Seq Seq Seq Seq Seq], [ImpF1 ImpF1 ImpF1 ImpF1 ImpF1], [ImpF2 ImpF2 ImpF2 ImpF2 ImpF2]};
    TestOrderKey = [Shuffle(1:3) Shuffle(1:3) Shuffle(1:3)];
    
    while any(TestOrderKey(1:length(TestOrderKey)-1) == TestOrderKey(2:length(TestOrderKey)))
        TestOrderKey = [Shuffle(1:3) Shuffle(1:3) Shuffle(1:3)];
    end
    
    testOrder    = [testBlocks{TestOrderKey}];
    
    Level7Order  = testOrder;
    Level7Block = [ones(1,60)       ones(1,60)*02    ones(1,60)*03    ones(1,60)*04    ones(1,60)*05    ...
                   ones(1,60)*06    ones(1,60)*07    ones(1,60)*08    ones(1,60)*09    ];          
    
%     x = SeqLngth:SeqLngth:(length(Level7Order)-1);                           % I need a sanity checker to make sure I don't have any 
%     y = (SeqLngth+1):SeqLngth:length(Level7Order);                           % repeating trials. 
%     while any(Level7Order(x) == Level7Order(x+1))                             % X and Y are the points where sequences meet. I need to to run
%         for i = 1:length(x)                                                 % while there are still repeats. If there ARE repeats,
%             while Level7Order(x(i)) == Level7Order(y(i))                      % It needs to find the repeat, figure out WHICH one is the noise
%                 if Level7Noise(x(i)) == 1                                    % since Sequences can't repeat, and can't be shifted.
%                     Level7Order(x(i)-11:x(i)) = circshift(Level7Order(x(i)-11:x(i)),[0 1]);   % If noise is the beginning sequence, shift
%                 elseif Level7Noise(y(i)) == 1                                                % That position and the 11 spots preceding it.
%                     Level7Order(y(i):y(i)+11) = circshift(Level7Order(y(i):y(i)+11),[0 1]);   % However, if the noise is the second sequence
%                 end                                                         % then we need to shift that spot and the 11 spots after it.
%             end                                                             % Just keep shifting noises by one until we have no more repeats.
%         end                                                                 % The main while loop is necessary because sometimes shifting to 
%     end                                                                     % fix one repeat creates another.
               
    ISIs = ISISeq;                                                          % Now I gotta make some ISI's
    for i = 1:6                                                             % Doubling the ISI's 6 times will create enough so 
        ISIs = [ISIs ISIs];                                                 % that I can just take out the necessary number of ISI's
    end                                                                     % for each level (test needs a few more ISI reps)
   
    Level1ISIs  = ISIs(1:length(Level1Order));  Level2ISIs = ISIs(1:length(Level2Order));   Level3ISIs = ISIs(1:length(Level3Order)); 
    Level4ISIs  = ISIs(1:length(Level4Order));  Level5ISIs = ISIs(1:length(Level5Order));   Level6ISIs = ISIs(1:length(Level6Order)); 
    Level7ISIs  = ISIs(1:length(Level7Order)); %  Level8ISIs = ISIs(1:length(Level8Order));  
    
    % This only matters for the dual-key expts. I'll just make it for the single-key, so I don't have to edit code elsewhere.
    dualKey1  = false(1,length(Level1Order )); dualKey2  = false(1,length(Level2Order )); dualKey3  = false(1,length(Level3Order )); 
    dualKey4  = false(1,length(Level4Order )); dualKey5  = false(1,length(Level5Order )); dualKey6  = false(1,length(Level6Order ));
    dualKey7  = false(1,length(Level7Order )); % dualKey8  = false(1,length(Level8Order )); 
        
    clear T1 T2 T3 Order1 Order2 Order3 ISISeqs ISIs LevelOrder LevelNoise LevelReps  AllSOCs ...
          levelBlock i j x y a lvlBgn lvlEnd noise reps block blockNum testBlocks testOrder
    
    save(['../PPTFile/' num2str(PPT) '_PPTFile'])

    % To make things a bit simpler I tacked the original
    % PostTestFileCreator on the end of the original PPTFileCreator.
    % So now, I have one PPTFileCreator that makes the file for the
    % Participant to run NeuroHero training, test, and recognition
    
    %---------------------------------%
    % This is the end of the original %
    % PPT File Creator!               %
    %---------------------------------%
    
    clear LevelType crossChecks dualKey1  dualKey2  dualKey3  dualKey4  dualKey5  dualKey6 dualKey7 ...
          dualKey8 dualKey9    dualKey10 dualKey11 dualKey12 dualKey13 dualKey14                   ...
          Level1Block Level2Block Level3Block  Level4Block  Level5Block  Level6Block  Level7Block  ...
          Level8Block Level9Block Level10Block Level11Block Level12Block Level13Block Level14Block ...
          Level1ISIs  Level2ISIs  Level3ISIs   Level4ISIs   Level5ISIs   Level6ISIs   Level7ISIs   ...
          Level8ISIs  Level9ISIs  Level10ISIs  Level11ISIs  Level12ISIs  Level13ISIs  Level14ISIs  ...
          Level1Noise Level2Noise Level3Noise  Level4Noise  Level5Noise  Level6Noise  Level7Noise  ...
          Level8Noise Level9Noise Level10Noise Level11Noise Level12Noise                           ...
          Level1Order Level2Order Level3Order  Level4Order  Level5Order  Level6Order  Level7Order  ...
          Level8Order Level9Order Level10Order Level11Order Level12Order Level13Order Level14Order ...
          Level1Reps  Level2Reps  Level3Reps   Level4Reps   Level5Reps   Level6Reps  Level7Reps    ...
          Level8Reps  Level9Reps  Level10Reps  Level11Reps  Level12Reps                            ...
          startSpeed blockLength blocksPerLevel blockLngth distToTarg seqReps

    
    %------------------------------%
    % This is the beginning of the %
    % original PostTestFileCreator %
    %------------------------------%
    
    numPostSeqs = 5;                                                        % We want to use 7 post-test sequences
    
    % Now each post will repeat twice
    Post1Order = [Seq   Seq  ]; 
    Post2Order = [RecF1 RecF1]; 
    Post3Order = [RecF2 RecF2]; 
    Post4Order = [RecF3 RecF3];
    Post5Order = [RecF4 RecF4];
     
    % Now I gotta make some ISI's    
    Post1ISIs = [ISISeq ISISeq];  
    Post2ISIs = [ISISeq ISISeq];  
    Post3ISIs = [ISISeq ISISeq];  
    Post4ISIs = [ISISeq ISISeq];  
    Post5ISIs = [ISISeq ISISeq];  
      
    dualKey1 = false(1,24); dualKey2 = false(1,24); dualKey3 = false(1,24); dualKey4 = false(1,24);
    dualKey5 = false(1,24);
    
    clear AllSOCs ISISeqs SeqLngth
    
    save(['../PPTFile/' num2str(PPT) '_PPTPostTestFile'])
  
end