% calculates the expected expected cost of the greedily built
% candidate list after posing a given query to an analyst.
%
% function expected_expected_cost = calculate_expected_expected_cost(pdf, ...
%           query, beta, item_cost)
%
% inputs:
%                       pdf: an (n x m) double array containing the
%                            current probability density function over
%                            the true location.  sum(pdf(:)) should
%                            equal 1.
%                 item_cost: a double representing the constant cost
%                            per list item examined.
%                     query: an (n x m) boolean array identifying the
%                            query posed to the analyst.  query(i, j)
%                            is true if and only if pixel (i, j) was
%                            contained in the query.
%                      beta: a double in [0, 1] identifying the rate
%                            of label noise increase.  an analyst is
%                            assumed to tell the truth about query q
%                            with probability
%                            (1 - beta * min(area(q), 1 - area(q))). 
%   largest_radius_fraction: a double representing the radius of the
%                            largest candidate to consider, as a
%                            fraction of the shorter side length of
%                            pdf, i.e., min(n, m).
%
% outputs:
%   expected_expected_cost: the expected expected cost of the greedily
%                           built candidate list after receiving an
%                           answer to the given query.
%
% copyright (c) 2012, roman garnett.

function expected_expected_cost = calculate_expected_expected_cost(pdf, ...
          query, beta, item_cost, largest_radius_fraction)

  probability = sum(pdf(query));
  
  area = mean(mean(query));
  noise_probability = min(area, 1 - area) * beta;

  probability = (1 - 2 * noise_probability) * probability + noise_probability;

  % condition on a "true" response and calculate the expected cost
  % of the resulting candidate list
  posterior = calculate_posterior(pdf, query, true, beta);
  candidate_list = build_candidate_list_greedy(posterior, item_cost, ...
          largest_radius_fraction);
  true_expected_cost = ...
      calculate_expected_cost(posterior, candidate_list, item_cost);

  % condition on a "false" response and calculate the expected cost
  % of the resulting candidate list
  posterior = calculate_posterior(pdf, query, false, beta);
  candidate_list = build_candidate_list_greedy(posterior, item_cost, ...
          largest_radius_fraction);
  false_expected_cost = ...
      calculate_expected_cost(posterior, candidate_list, item_cost);

  % calculate the expected expected cost weighting by the current
  % probability of the given query.
  expected_expected_cost = ...
           probability  *  true_expected_cost + ...
      (1 - probability) * false_expected_cost;
  
end
