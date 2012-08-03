% simulates interaction with an analyst given a prior probability
% distribution and a given number of queries.
%
% function [queries, responses, expected_costs, true_costs, pdfs, ...
%           candidate_lists] = simulate_interactive_search(pdf, ...
%           location_ind, beta, item_cost, largest_radius_fraction, num_queries)
%
% inputs:
%                       pdf: an (n x m) double array containing the
%                            current probability density function over
%                            the true location.  sum(pdf(:)) should
%                            equal 1.
%              location_ind: the index of the true location into the
%                            candidate_list matrix, i.e.,
%                            candidate_list(location_ind) returns the
%                            ordinal candidate containing the sought
%                            location.
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
%               num_queries: the number of queries to simulate
%
% outputs:
%          queries: an (n x m x num_queries) boolean array
%                   containing the chosen queries
%        responses: a (num_queries x 1) boolean vector containing
%                   the simulated responses
%   expected_costs: a (num_queriues + 1 x 1) double vector
%                   containing the expected cost after the (i + 1)th 
%                   query (including before any queries)
%       true_costs: a (num_queriues + 1 x 1) double vector
%                   containing the true cost after the (i + 1)th 
%                   query (including a priori).
%             pdfs: an (n x m x num_queries + 1) double array
%                   containing the probability density function over
%                   the true location after the (i + 1)th query
%                   (including a priori).
%   candidate_list: an (n x m x num_queries + 1) integer array
%                   containing the built candidate list after the
%                   (i + 1)th query (including a priori).  the j'th
%                   candidate after query (i + 1) can be found with
%                   found with (candidate_lists(:, :, i) == j).
%
% copyright (c) 2012, roman garnett.

function [queries, responses, expected_costs, true_costs, pdfs, ...
          candidate_lists] = simulate_interactive_search(pdf, ...
          location_ind, beta, item_cost, largest_radius_fraction, num_queries)

  [num_rows, num_cols] = size(pdf);

  queries         = false(num_rows, num_cols, num_queries);
  responses       = false(num_queries, 1);
  expected_costs  = zeros(num_queries + 1, 1);
  true_costs      = zeros(num_queries + 1, 1);
  pdfs            = zeros(num_rows, num_cols, num_queries + 1);
  candidate_lists = zeros(num_rows, num_cols, num_queries + 1);
  
  for i = 1:(num_queries + 1)
    pdfs(:, :, i) = pdf;

    % construct the current canddiate list
    candidate_list = build_candidate_list_greedy(pdf, item_cost, ...
            largest_radius_fraction);
    candidate_lists(:, :, i) = candidate_list;

    % evaluate expected and true costs for the constructed list
    expected_costs(i) = calculate_expected_cost(pdf, candidate_list, item_cost);
    true_costs(i) = calculate_cost(candidate_list, location_ind, item_cost);

    if (i > num_queries)
      return;
    end

    fprintf('constructing query %i of %i ...\n', i, num_queries);
    
    query = choose_best_query_from_candidates(pdf, candidate_list, ...
            beta, item_cost, largest_radius_fraction);
    queries(:, :, i) = query;

    % simulate a response for the given query
    response = simulate_response(query, location_ind, beta);
    responses(i) = response;

    % condition our distribution on that response
    pdf = calculate_posterior(pdf, query, response, beta);
  end
    
end
