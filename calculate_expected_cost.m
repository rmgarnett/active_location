% calculates the expected cost of a candidate list given the
% current probability distribution over location.
%
% function expected_cost = calculate_expected_cost(pdf, candidate_list, ...
%           item_cost)
%
% inputs:
%              pdf: an (n x m) double array containing the current
%                   probability density function over the true
%                   location.  sum(pdf(:)) should equal 1.
%   candidate_list: an (n x m) integer array containing the built
%                   candidate list.  the i'th candidate can be found
%                   with (candidate_list == i).
%        item_cost: a double representing the constant cost per list
%                   item examined.
%
% outputs:
%   expected_cost: the expected cost of finding the sought location
%                  in the given list.
%
% copyright (c) 2012, roman garnett.

function expected_cost = calculate_expected_cost(pdf, candidate_list, ...
          item_cost)

  num_candidates = max(candidate_list(:));
  
  area = @(candidate) (mean(mean(candidate)));
  probability_exhausted = @(i) (sum(pdf(candidate_list < i)));

  expected_cost = 0;
  for i = 1:num_candidates
    expected_cost = expected_cost + ...
        (1 - probability_exhausted(i)) * (item_cost + area(candidate_list == i));
  end
end