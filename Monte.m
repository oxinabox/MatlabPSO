function [ Solution, score, mbest_history ] = Monte( ...
                                      dimension,...
                                      Limits, ...
                                      generations, ...
                                      Eval)

    tic
    global num_errors 
    num_errors = 0;
        
    % Variable initialisation
    d = dimension;
    g = generations;
    minimum = Limits(1);
    maximum = Limits(2);
    
    
    mbest = Inf((d + 1), 1); % The globally best solution
    mbest_history =-Inf((d + 1), g); %Store the mbest for each generation
    for gen_num = 1:g % Looping through each generation       
        Ws = minimum + (maximum-minimum) * rand(d,1);
        score = Eval(Ws);
        if (score<=mbest(end))
           mbest=[Ws;score];
        end
        mbest_history(:,gen_num)=mbest;
    end
    Solution = mbest(1:d);
    score = mbest(d+1);
    
    toc
end