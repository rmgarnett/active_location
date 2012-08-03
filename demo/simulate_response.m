% simulates a user response to a query assuming the observation model
% used throughout the code.
%
% function response = simulate_response(query, location_ind, beta)
%
% inputs:
%          query: an (n x m) boolean array identifying the query posed
%                 to the analyst.  query(i, j) is true if and only if
%                 pixel (i, j) was contained in the query.
%   location_ind: the index of the true location into the
%                 candidate_list matrix, i.e.,
%                 candidate_list(location_ind) returns the
%                 ordinal candidate containing the sought location.
%           beta: a double in [0, 1] identifying the rate of label
%                 noise increase.  an analyst is assumed to tell the
%                 truth about query q with probability
%                 (1 - beta * min(area(q), 1 - area(q))).
%
% outputs:
%   response: the simulated response.
%
% copyright (c) 2012, roman garnett.

function response = simulate_response(query, location_ind, beta)

  % constrain beta to [0, 1]. 
  beta = min(1, max(0, beta));
  
  area = mean(mean(query));
  noise_probability = min(area, 1 - area) * beta;

  % simulate a response using the given noise model
  if (query(location_ind))
    response = (rand < 1 - noise_probability);
  else
    response = (rand < noise_probability);
  end
  
end
