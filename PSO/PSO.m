function [ Solution, Score, gbest_history ] = PSO( particles, ...
                                      dimension,...
                                      Limits, ...
                                      generations, ...
                                      Eval,...
                                      saveName,...
                                      convergence,...
                                      acc_coeffs)
                                  
    %%% PSO is configured to minimise the score              
    tic
    if ((nargin < 6) || (isempty(saveName)))
        saveName = '';
    end
    if ((nargin < 7) || (isempty(convergence)))
        convergence = 0;
    end
    if ((nargin < 8) || (isempty(acc_coeffs)))
        acc_coeffs = [0.9, 2];
    end
    
   
    % Parameter setting
    INERTIA = acc_coeffs(1);
    COGNITION = acc_coeffs(2);
    SOCIAL = acc_coeffs(2);
    
    % Variable initialisation
    nDimentions = dimension;
    nParticles = particles;
    nGenerations = generations;
    
    minimum  = Limits(:,1);
    maximum  = Limits(:,2);
    maxVel   = Limits(:,3);
    forceInt = Limits(:,4);

    % Initial Values
    rand_vel = @(n) random_velocity(minimum, maximum, maxVel, nDimentions,n);
    rand_pos = @(len) repmat(minimum + (maximum-minimum),1,len) .* rand(nDimentions, len);
    
    vel=rand_vel(nParticles);
    swarm = rand_pos(nParticles); % Each col vector represents a particle solution
    swarm(logical(forceInt),:) = round(swarm(logical(forceInt),:));
    
    pbest = Inf((nDimentions + 1), nParticles); % The personal best solution of each particle
    
    gbest = Inf((nDimentions + 1), 1); % The globally best solution
    gbest_history = zeros((nDimentions + 1), nGenerations); %Store the gbest for each generation
    
    for  gen_num=1:nParticles 
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
        
        i_vel = INERTIA*vel;
        p_vel =  COGNITION * rand_factor(nDimentions,nParticles) .* p_displace;
        g_vel = SOCIAL * rand_factor(nDimentions,nParticles) .* g_displace;
        
        vel = i_vel + p_vel + g_vel;  
        vel = min(max(vel,-maxVel),maxVel); %CLIP velocity
        
        vel(:,unfit & no_pbest)=rand_vel(nnz(unfit& no_pbest));
        
        % Update Position
        swarm = swarm+vel;
        
		% If a particle is not fit and never has found a pbest, then it teleports randomly
        swarm(:,unfit & no_pbest)=rand_pos(nnz(unfit& no_pbest));

        %CLIP VALUES
        swarm(logical(forceInt),:) = round(swarm(logical(forceInt),:));
        swarm = max( min( (swarm), maximum),minimum); 
        
        
        gen_num
        gbest

        deviation = getPSOswarmDeviation(swarm);
        if (deviation < convergence)
            break;
        end
        
        if ~isempty(saveName)
            csvwrite(saveName, gbest_history);
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

    