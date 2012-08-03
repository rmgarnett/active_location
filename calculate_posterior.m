% conditions a prior pdf over location given the response from an
% analyst to a query.  an analyst is assumed to tell the truth with
% noise that varies linearly with min(query area, 1 - query area).
%
% function posterior = calculate_posterior(prior, query, response, beta)
%
% inputs:
%      prior: an (n x m) double array containing the prior
%             probability density function over the true location.
%      query: an (n x m) boolean array identifying the query posed
%             to the analyst.  query(i, j) is true if and only if
%             pixel (i, j) was contained in the query.
%   response: a boolean containing the analyst's response
%       beta: a double in [0, 1] identifying the rate of labe noise
%             incease.  an analyst is assumed to tell the truth
%             about query q with probability
%             (1 - beta * min(area(q), 1 - area(q))). 
%
% outputs:
%   posterior: an (n x m) double array containing the posterior
%              probability density function over the true location.
%
% copyright (c) 2012, roman garnett.

function posterior = calculate_posterior(prior, query, response, beta)

  % constrain beta to [0, 1]. 
  beta = min(1, max(0, beta));
  
  area = mean(mean(query));
  noise_probability = min(area, 1 - area) * beta;

  posterior = prior;
  if (response)
    posterior( query) = posterior( query) * (1 - noise_probability);
    posterior(~query) = posterior(~query) *      noise_probability;
  else
    posterior(~query) = posterior(~query) * (1 - noise_probability);
    posterior( query) = posterior( query) *      noise_probability;
  end

  % renormalize posterior
  posterior = posterior / sum(posterior(:));
  
end
