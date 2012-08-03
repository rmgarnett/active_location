% builds a candidate list by greedily optimizing the expected cost
% of the list returned.
%
% function candidate_list = build_candidate_list_greedy(pdf, item_cost, ...
%           largest_radius_fraction)
%
% inputs:
%                       pdf: an (n x m) double array containing the
%                            current probability density function over
%                            the true location.  sum(pdf(:)) should
%                            equal 1.
%                 item_cost: a double representing the constant cost
%                            per list item examined.
%   largest_radius_fraction: a double representing the radius of the
%                            largest candidate to consider, as a
%                            fraction of the shorter side length of
%                            pdf, i.e., min(n, m).
%
% outputs:
%   candidate_list: an (n x m) integer array containing the built
%                   candidate list.  the i'th candidate can be found
%                   with (candidate_list == i).
%
% copyright (c) 2012, roman garnett.

function candidate_list = build_candidate_list_greedy(pdf, item_cost, ...
          largest_radius_fraction)

  candidate_list = ones(size(pdf));

  % create functions for calculating the probability and area of a
  % specified candidate
  uniform_pdf = ones(size(pdf)) / numel(pdf);  
  probability = @(candidate)         (sum(pdf(candidate)));
  area        = @(candidate) (sum(uniform_pdf(candidate)));

  [num_rows, num_cols] = size(pdf);
  [col_inds, row_inds] = meshgrid(1:num_cols, 1:num_rows);

  largest_radius = floor(min(num_rows, num_cols) * largest_radius_fraction);

  % pregenerate a set of filters for various circle sizes
  filters = cell(largest_radius, 1);
  for radius = 1:largest_radius
    filters{radius} = fspecial('disk', radius);
    filters{radius} = filters{radius} / max(max(filters{radius}));
  end
  
  keep_searching = true;
  while (keep_searching)
    keep_searching = false;

    % identify the last candidate in the list; this is always "everything
    % else," i.e., all area not yet assigned to a candidate.
    last_candidate_ind = max(candidate_list(:));
    last_candidate = (candidate_list == last_candidate_ind);
    
    probability_remaining = probability(last_candidate);
    area_remaining        =        area(last_candidate);

    % calculate the current cost associated with the last
    % candidate; to split, we must find a candidate that results in
    % a lower cost.
    best_cost = probability_remaining * (item_cost + area_remaining);

    % search over potential new candidates to add, calculating
    % their associated expected costs.
    for radius = 1:largest_radius
      % we may calculate areas and probabilities for every
      % potential candidate center using a convolution 
      areas         = conv2(uniform_pdf .* last_candidate, filters{radius}, 'same');
      probabilities = conv2(        pdf .* last_candidate, filters{radius}, 'same');

      % calculate the costs associated with each potential split
      costs = ...
                                   probabilities  .* (    item_cost + areas) + ...
          (probability_remaining - probabilities) .* (2 * item_cost + area_remaining);

      % determine if we have found a beneficial split; if so, we
      % note its location and set the keep_searching flag.
      [this_best_cost, ind] = min(costs(:));
      if (this_best_cost < best_cost)
        keep_searching = true;
        best_cost = this_best_cost;
        [row, col] = ind2sub(size(pdf), ind);

        best_candidate = ((row_inds - row).^2 + (col_inds - col).^2) <= radius^2;
      end
    end

    % if we identified an advantageous split, assign the new
    % candidate and continue.
    if (keep_searching)
      candidate_list(last_candidate & ~best_candidate) = last_candidate_ind + 1;
    end
  end
  
end
