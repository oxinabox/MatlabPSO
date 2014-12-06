function [ deviation ] = getSwarmDeviation( swarm )
%GETSWARMDEVIATION Given a swarm of particles, find the standard deviation
%   Detailed explanation goes here
mu = mean(swarm,2);
diff = bsxfun(@minus,swarm,mu);
deviation = sqrt(mean(dot(diff,diff)));

end

