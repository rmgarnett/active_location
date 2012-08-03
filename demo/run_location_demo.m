load('population_pdf');
pdf = interp2(population_pdf, -2);

% parameters

% constant cost per list item
item_cost               = 0.015;
% size of largest candidate radius as a fraction of min(size(pdf))
largest_radius_fraction = 0.025;
% index into pdf of true location to search for
location_ind            = sub2ind(size(pdf), 70, 270);
% rate of label noise growth
beta                    = 1;
% number of queries to simulate
num_queries             = 20;

% simulate interactive analyst session
[queries, responses, expected_costs, true_costs, pdfs, candidate_lists] ...
    = simulate_interactive_search(pdf, location_ind, beta, item_cost, ...
        largest_radius_fraction, num_queries);

% animate resulting pdfs, candidate lists, and queries 
for i = 1:num_queries
  figure(1);
  imagesc(pdfs(:, :, i));
  colormap('hot');
  axis('equal');
  axis('off');
  title(['pdf before query ' num2str(i)]);
  
  figure(2);
  imagesc(-candidate_lists(:, :, i));
  colormap('hot');
  axis('equal');
  axis('off');
  title(['candidate list before query ' num2str(i)]);

  figure(3);
  imagesc(queries(:, :, i));
  colormap('hot');
  axis('equal');
  axis('off');
  title(['location of query ' num2str(i)]);

  drawnow;
  pause(1);
end