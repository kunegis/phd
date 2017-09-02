%
% Output Latex table of best fitting curves for all datasets.
%
% PARAMETERS
%	$NETWORKS	Space-separated list of networks to show
%	$OUTPUT		Output filename
%	$ERROR_GROUP	Error group as defined in result_value() 
%	$METHOD_NAME_EXCLUDE_LIST
%			(optional) Pipe-separated list of methods to exclude 
%	$DECOMPOSITION_EXCLUDE_LIST
%			(optional) Pipe-separated list of methods to exclude
%
% OUTPUT
%	$OUTPUT		Latex file
%
% INPUT
%	../webstore/analysis/uni/out.*
%

path(path, '../webstore/analysis'); 
path(path, '../webstore/latex'); 

error_group = getenv('ERROR_GROUP'); 

method_name_exclude_list = getenv('METHOD_NAME_EXCLUDE_LIST') 
decomposition_exclude_list = getenv('DECOMPOSITION_EXCLUDE_LIST') 

if strcmp(decomposition_exclude_list, '')
  decomposition_exclude_list = 'oasero2uoweukwueroiweuvnf'; 
end

output = getenv('OUTPUT'); 

networks = getenv('NETWORKS'); 
networks = regexp(networks, '[a-zA-Z0-9_-]+', 'match'); 

BESTCURVE = fopen(output, 'w'); 

%
% Iterate over all decompositions.  For all decompositions except the Laplacian
% decompositions, there is an A and an N variant.  The Laplacian decompositions have
% only an A variant. 
%
decompositions = 'sym symf asym asymf back backf bip bipf lapb lapbf lapbc lapbcf laps lapsf lapsc lapscf'; 
decompositions = regexp(decompositions, '[a-z]+', 'match'); 

for i = 1:size(networks, 2)
  network = networks(i); network = network{:}

  name = corpus_long_name(network); 
  short_name = network_code(network); 
  short_name = regexprep(short_name, '_{', '$_\\textrm{');
  short_name = regexprep(short_name, '}', '}$'); 

  error_best = -Inf; 

  for j = 1:size(decompositions, 2)
    decomposition = decompositions(j); decomposition = decomposition{:}

    if size(regexp(decomposition, ['^(' decomposition_exclude_list ')$'])),
      'CONTINUE'; 
      continue;
    end

    for k = 1:3

      letters = 'anl'; 
      normalization = letters(k)

      [math curve error] = bestcurve_one(network, decomposition, normalization, ...
        error_group, method_name_exclude_list)  
      if error > error_best
	math_best = math;
	curve_best = curve;
	error_best = error; 
      end
    end
  end

  fprintf(BESTCURVE, '%s (\\textsf{%s}) & $%s$ & \\textrm{%s} & %.3f \\\\\n', ...
	  name, short_name, ...
	  math_best, curve_best, error_best); 
end

if 0 ~= fclose(BESTCURVE), error; end
