%
% Find the best curve for one network/decomposition combination. 
%
% PARAMETERS
%	network		Network name
%	decomposition	E.g. "sym", "asymf", "lapb", etc.
%	normalization	"a", "n" or "l"
%	error_measure	Index of error measure to use
%	method_exclude_list (optional)
%			Pipe-separated list of methods to exclude; may be empty;
%			'perf' is always excluded. 
%
% RESULT
%	math		Latex code for expression describing the
%			learned transformation  
%	curve		Name of fitted curve 
%	error		Error value 
%

function [math curve error] = bestcurve_one(network, decomposition, normalization, error_group, method_exclude_list)

if nargin <= 4
  method_exclude_list = 'lksdfjoiwerucnoquwdn'; 
end

method_exclude_list

method_exclude_list = [method_exclude_list '|perf']; 

filename = sprintf('../webstore/analysis/dat/comp2.%s.%s.%s.mat', decomposition, network, normalization);

if exist(filename, 'file')

  load(filename);  

  error = -Inf; 

  for method = fieldnames(comp)'

    method = char(method)

    if ~size(regexp(method, ['^(' method_exclude_list ')$']))

      error_this = result_value(comp.(method), error_group)

      if error_this > error
        [math curve] = format_curve(decomposition, normalization, method); 
        error = error_this; 
      end		   
    end
  end

else
  math = '';
  curve = '';
  error = -Inf; 
end
