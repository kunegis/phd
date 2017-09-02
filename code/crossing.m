%
% Close-up of an avoided crossing.
%
% INPUT
% 	dat/split.$CORPUS.mat		Dataset
%	dat/means.$CORPUS.mat		Additive normalization
%	dat/steps.$CORPUS.mat
%

path(path, '../matlab'); 

font_size = 20; 

corpus = 	'wikipedia-growth';
type = 		'sym';

marker_size = 	25; 
range = 	26:42;

steps = load(sprintf('dat/steps.%s.mat', corpus)); 
split = load(['dat/split.' corpus '.mat']); 
means = load(sprintf('dat/means.%s.mat', corpus)); 
at012 = normalize_additively([split.at_training; split.at_validation; split.at_test], ...
  means); 


for i = range
  i
  ai = myspconvert(at012(1:steps.r_steps(i),:), split.m, split.n);
  [u,d,v] = decompose(ai, 3, type); 
  d
  ii = find(diag(d) > 0)
  k_1 = ii(1)
  k_2 = ii(2)
  if i == range(1), u_first = u(:,[k_1 k_2]); end
  cor_1(i,1:2) = abs(u(:,[k_1 k_2])' * u_first(:,1)); 
  cor_2(i,1:2) = abs(u(:,[k_1 k_2])' * u_first(:,2)); 
  dd(i,1:2) = diag(d([k_1 k_2], [k_1 k_2]));
end

cor_1
cor_2
dd

hold on; 

for i = range
  for j = 1:2
    c_1 = cor_1(i,j); 
    c_2 = cor_2(i,j); 
    if c_1 > 1, c_1 = 1; end % may be 1+epsilon due to rounding
    if c_2 > 1, c_2 = 1; end		     
    color = [1 * c_2 (.8 * c_1) 0]
    plot(steps.r_steps(i), dd(i,j), '.k', ...
      'Color', color, 'MarkerSize', marker_size); 	      
  end
end

xlabel('Edge count (|E|)', 'FontSize', font_size); 
ylabel('Eigenvalues (\lambda_k)', 'FontSize', font_size); 

grid on; 

set(gca,'XTick', (1:.2:2)*1e7)
set(gca,'YTick', 400:25:700)

set(gca, 'FontSize', font_size); 

print(sprintf('plot/crossing.%s.%s.eps', type, corpus), '-depsc'); close all; 

