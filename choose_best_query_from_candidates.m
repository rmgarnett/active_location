% constructs a query from a candidate list by finding the candidate
% which is expected to reduce the expected cost of the returned
% candidate list as much as possible.
%
% function query = choose_best_query_from_candidates(pdf, candidate_list, ...
%          beta, item_cost, largest_radius_fraction)
%
% inputs:
%                       pdf: an (n x m) double array containing the
%                            current probability density function over
%                            the true location.  sum(pdf(:)) should
%                            equal 1.
%            candidate_list: an (n x m) integer array containing
%                            a candidate list.  the i'th candidate
%                            can be found with (candidate_list == i). 
%                      beta: a double in [0, 1] identifying the rate
%                            of label noise increase.  an analyst is
%                            assumed to tell the truth about query q
%                            with probability
%                            (1 - beta * min(area(q), 1 - area(q))).
%                 item_cost: a double representing the constant cost
%                            per list item examined.
%   largest_radius_fraction: a double representing the radius of the
%                            largest candidate to consider, as a
%                            fraction of the shorter side length of
%                            pdf, i.e., min(n, m).
%
% outputs:
%   query: an (n x m) boolean array containing the chosen query
%
% copyright (c) 2012, roman garnett.

function query = choose_best_query_from_candidates(pdf, candidate_list, ...
          beta, item_cost, largest_radius_fraction)

  % find most informtative candidate
  num_candidates = max(candidate_list(:)) - 1;
  expected_expected_costs = zeros(num_candidates, 1);
  parfor i = 1:num_candidates
    expected_expected_costs(i) = calculate_expected_expected_cost(pdf, ...
            candidate_list == i, beta, item_cost, largest_radius_fraction);
  end

  % construct query corresponding to most informative candidate
  [~, ind] = min(expected_expected_costs);
  query = (candidate_list == ind);
    
end
