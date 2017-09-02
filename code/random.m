%
% Random graph growth test (Section 3.4.1 in Jérôme's PhD thesis).
%
% PARAMETERS
%	$NETWORK	Name of dataset (must be square)
%
% INPUT
%	dat/time_decomp.sym.$NETWORK.mat 
%
% OUTPUT
%	plot/random.eigenvalue_evolution.$NETWORK.eps
%	plot/random.eigenvector_evolution.$NETWORK.eps
%	plot/random.permutation_map.$NETWORK.eps
%

cd('..'); 
addpath('../matlab/'); 

network = getenv('NETWORK'); 

time_wp = load(['dat/time_decomp.sym.' network '.mat']); 

% Rank
k = time_wp.k; 

split = load(['dat/split.' network '.mat']); 
steps = load(sprintf('dat/steps.%s.mat', network)); 

step_begin = 1+steps.steps_training
step_end = steps.count; 

at = [split.at_training; split.at_validation; split.at_test]; 
at = at(:,1:2); 
ati = [at(1:steps.r_steps(step_begin),:); 1+floor(split.m*rand(steps.r_steps(end)-steps.r_steps(step_begin), 2))]; 

range_all = step_begin:step_end; 

for i = range_all 
  i 

  ai = myspconvert(ati(1:steps.r_steps(i),:), split.m, split.n); 

  [u,d] = decompose(ai, time_wp.k, 'sym'); 
  decompositions(i).d = d;
  decompositions(i).u = u;
end

%
% Draw 
%
marker_size = 11.3; 
font_size = 20; 
line_width = 3; 

%
% Eigenvalue evolution 
%
hold on; 

d_random = zeros(1,1:range_all(end)); 
d_actual = zeros(1,1:range_all(end)); 

for j = 1:k

    for i = range_all
      d_random(i) = decompositions(i).d(j,j); 
      d_actual(i) = time_wp.decompositions(i).d(j,j);
    end
    d_random
    d_actual
    handle_random = plot(steps.r_steps(range_all), d_random(range_all), 's', 'Color', [0 .7 0], 'MarkerSize', marker_size); 
    handle_actual = plot(steps.r_steps(range_all), d_actual(range_all), '.b', 'MarkerSize', marker_size); 
end

xlabel('Edge count (|E|)', 'FontSize', font_size); 
ylabel('Eigenvalues (\lambda_k)', 'FontSize', font_size); 

set(gca, 'FontSize', font_size); 

gridxy([], [0], 'LineStyle', '--');

legend([handle_actual handle_random], [cellstr('Actual growth'), cellstr('Artificial growth')], ...
  'Location', 'NorthWest'); 
	       
print(sprintf('plot/random.eigenvalue_evolution.%s.eps', network), '-depsc'); close all; 

%
% Eigenvector evolution
%

for i = k:-1:1
  products_random = zeros(steps.count,1);
  products_actual = zeros(steps.count,1);
  for j = range_all
    products_random(j) = abs(        decompositions(step_begin).u(:,i)' *         decompositions(j).u(:,i));
    products_actual(j) = abs(time_wp.decompositions(step_begin).u(:,i)' * time_wp.decompositions(j).u(:,i));
  end
  products_random
  products_actual 
  h_actual = plot(steps.r_steps(range_all), products_actual(range_all), 'Color', ...
    (i-1)/k * [1 1 1] + (k - (i-1))/k * [0 0 .8], ...
    'LineWidth', line_width); 
  h_random = plot(steps.r_steps(range_all), products_random(range_all), '--', 'Color', ...
    (i-1)/k * [1 1 1] + (k - (i-1))/k * [0 .7 0], ...
    'LineWidth', line_width); 
  if i == k
    hold on;
  end;
  if i == 1 
    handle_random = h_random; 
    handle_actual = h_actual; 
  end; 
end

xlabel('Edge count (|E|)', 'FontSize', font_size); 
ylabel('Similarity (sim(k,k))', 'FontSize', font_size);

legend([handle_actual handle_random], [cellstr('Actual growth') cellstr('Artificial growth')], 'Location', 'SouthWest'); 

ax = axis();
axis([ax(1) ax(2) 0 1.05]); 

set(gca, 'FontSize', font_size); 
print(sprintf('plot/random.eigenvector_evolution.%s.eps', network), '-depsc');  close all; 

%
% Diagonality test 
%

ubu = decompositions(step_begin).u' * myspconvert(ati(steps.r_steps(step_begin):end,:), split.m, split.n) * decompositions(step_begin).u;
imageubu(ubu);
print(sprintf('plot/random.random_permutation_map.%s.eps', network), '-depsc'); close all; 

ubu = time_wp.decompositions(step_begin).u' * myspconvert(at(steps.r_steps(step_begin):end,:), split.m, split.n) * time_wp.decompositions(step_begin).u;
imageubu(ubu);
print(sprintf('plot/random.actual_permutation_map.%s.eps', network), '-depsc'); close all; 
