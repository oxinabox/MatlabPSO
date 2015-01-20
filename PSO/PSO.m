function [ Solution, Score, gbest_history ] = PSO( nParticles, ...
                                      nDimensions,...
                                      Limits, ...
                                      nGenerations, ...
                                      Eval,...
                                      priors, ...
                                      saveName,...
                                      convergence,...
                                      inertia,cognition,social)
    %%% PSO is configured to minimise the score      
    %%% 
    %%% nParticles: How many particles in the swarm.
    %%% this is how many times the Eval function will be called each
    %%% generation.
    %%%
    %%% Limits should be a nDimentions x 4 matrix, 
    %%% For each dimention (row)
    %%% the first column specifying the minimum value (inclusive)
    %%% the second column specifying the maximum value (inclusive)
    %%% the thirst column specifying the maximum velocity that can be done
    %%% to that dimention (ie the most it can change between two
    %%% generations)
    %%% The forth column is a logical value specifying if that dimention
    %%% should be always an integer (setting it to true will make it round)
    %%% For example: a row of limits being [1.5, 10.0, Inf, false], allows
    %%% the dimention to be any value from 1.5 to 10.0, and move with
    %%% out restriction on speed.
    %%% where are [1,3,1,true], allows the particles value for that
    %%% dimention to only take the value 1,2 or 3, and it can only change
    %%% by 1 step (either direction) at a time.
    %%%
    %%%
    %%% Priors (optional) a column vectors of prior known good values.
    %%% Each column should have length equal to nDimentions
    %%% Set to [] to have none.
    
    
    tic
    if ((nargin < 7) || (isempty(saveName)))
        saveName = '';
    end
    if ((nargin < 8) || (isempty(convergence)))
        convergence = 0;
    end
    
    if ~exist('inertia', 'var')
        inertial = 0.9;
    end
    
    if ~exist('cognition', 'var')
        cognition = 2;
    end
        
    
    if ~exist('social', 'var')
        social = cognition;
    end
    
    
    minimum  = Limits(:,1);
    maximum  = Limits(:,2);
    maxVel   = Limits(:,3);
    forceInt = Limits(:,4);
    
    
    function swarm = clip_pos (swarm)
        swarm(logical(forceInt),:) = round(swarm(logical(forceInt),:));
        swarm = max( min( (swarm), repmat(maximum,1,nParticles)),repmat(minimum, 1,nParticles)); 
    end

    % Initial Values
    rand_vel = @(n) random_velocity(minimum, maximum, maxVel, nDimentions,n);
    rand_pos = @(len) repmat(minimum + (maximum-minimum),1,len) .* rand(nDimentions, len);
    
    vel=rand_vel(nParticles);
    swarm = rand_pos(nParticles); % Each col vector represents a particle solution
    if ~isempty(priors)
        swarm(:,  1:size(priors,2)) = priors;
    end
    
    swarm = clip_pos(swarm);
    
    pbest = Inf((nDimentions + 1), nParticles); % The personal best solution of each particle
    
    gbest = Inf((nDimentions + 1), 1); % The globally best solution
    gbest_history = zeros((nDimentions + 1), nGenerations); %Store the gbest for each generation
    
    for  gen_num=1:nGenerations 
        % Update personal bests
        score = zeros(1,nParticles);
        for particle = 1:nParticles
           score(particle) = Eval(swarm(:,particle));
        end
        
        unfit = logical(score == Inf);
        
        improved_particles = score<=pbest(nDimentions+1,:); %We are typing to minimise the score (like golf)
        cur_scores = [swarm; score];
        pbest(:,improved_particles) = cur_scores(:,improved_particles);
        
        no_pbest = pbest(nDimentions+1,:)==Inf;
        

        % Update global best
        [~,best_pbest] = min(pbest(nDimentions+1,:)); %Find which column, the best pbest fitenss was max
        gbest = pbest(:,best_pbest);
        gbest_history(:,gen_num) = gbest;
        
       
        p_displace = (pbest(1:nDimentions,:)-swarm);
        g_displace = (bsxfun(@minus,gbest(1:nDimentions,1),swarm));
        
        i_vel = inertia*vel;
        p_vel =  cognition * rand_factor(nDimentions,nParticles) .* p_displace;
        g_vel = social * rand_factor(nDimentions,nParticles) .* g_displace;
        
        vel = i_vel + p_vel + g_vel;  
        vel = min(vel,repmat(maxVel,1,nParticles)); % Clip to be less than maxVel
        
        vel(:,unfit & no_pbest)=rand_vel(nnz(unfit& no_pbest));
        
        % Update Position
        swarm = swarm+vel;
        
		% If a particle is not fit and never has found a pbest, then it teleports randomly
        swarm(:,unfit & no_pbest)=rand_pos(nnz(unfit& no_pbest));

        swarm = clip_pos(swarm);
        
        
        gen_num
        gbest


        
        if ~isempty(saveName)
            csvwrite(saveName, gbest_history');
        end 
        
        deviation = getPSOswarmDeviation(swarm);
        if (deviation < convergence)
            disp('Converged')
            break;
        end
    end
    Solution = gbest(1:nDimentions);
    Score = gbest(nDimentions+1);
    
    toc
end

function [random_vals] = rand_factor(d,n)
    %%Returns a factor matrix suitable for causing row-wise multipciation
    entries = rand(1, n); %Per particle a random factor same for in all dimentions (thus d does not appear here)
    random_vals = repmat(entries,d,1); % use that same factor in each dimention
end

function [vel] = random_velocity(minimumPos,maximumPos, maxVel, nDim, nParticles)
    rand_fact = rand(nDim, nParticles); % Each col vector represents a particle's velocity
    constraints = repmat(minimumPos + (maximumPos-minimumPos)*0.5, 1,nParticles);
    vel = constraints.*rand_fact;
    
    vel = min(vel,repmat(maxVel,1,nParticles)); % Clip to be less than maxVel
    vel = (-1).^randi(2,nDim,nParticles).*vel; %Randomise direction
end


    