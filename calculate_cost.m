% calculates the (true) modified cost function associated with a
% given location and candidate list.
%
% function cost = calculate_cost(candidate_list, location_ind, item_cost)
%
% inputs:
%     location_ind: the index of the true location into the
%                   candidate_list matrix, i.e.,
%                   candidate_list(location_ind) returns the
%                   ordinal candidate containing the sought location.
%   candidate_list: an (n x m) integer array containing the candidate
%                   list.  the i'th candidate can be found with
%                   (candidate_list == i).
%        item_cost: a double representing the constant cost per
%                   list item examined.
%
% outputs:
%   cost: a double representing the cost of the candidate list
%         given the true location.
%
% copyright (c) 2012, roman garnett.

function cost = calculate_cost(candidate_list, location_ind, item_cost)

  containing_ind = candidate_list(location_ind);

  cost = item_cost * containing_ind + ...
         mean(mean(candidate_list <= containing_ind));

end