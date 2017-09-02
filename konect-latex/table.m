%
% Generate a Latex table of dataset statistics. 
%
% For folksonomies, the *_ut entries show statistics for all three
% modes, therefore the *_ui and *_ti entries should be filtered out in
% $NETWORKS. 
%
% PARAMETERS
% 	$NETWORKS	Space-separated list of datasets
%	$HIDE_STAT	Don't show statistics when "1"
%	$OUTPUT		Output file
%	$FOLKSONOMY_FOLD
%			For folksonomies, use only _ut
%
% INPUT
%	dat/info.$NETWORK	
%			For all $NETWORK in $NETWORKS
%
% OUTPUT 
%	$OUTPUT		Results as tab-separated text file
%

cd('../projects/konect/analysis/'); 
addpath('../matlab/'); 
addpath('m/'); 

consts = constants(); 

networks_list = getenv('NETWORKS'); 
networks = regexp(networks_list, '[a-zA-Z0-9_-]+', 'match'); 

hide_stat = strcmp(getenv('HIDE_STAT'), '1'); 
folksonomy_fold = strcmp(getenv('FOLKSONOMY_FOLD'), '1'); 

OUTFILE = fopen(getenv('OUTPUT'), 'w'); 

for i = 1:size(networks, 2)

  network = networks(i);
  network = network{:}

  if folksonomy_fold
    if size(regexp(network, '[_2-][ut]i')), continue; end
  end

  info = read_info(network); 

  if info.format == consts.BIP
    vertex_count_text = sprintf('%s + %s', format_number(info.m), format_number(info.n)); 
  else
    vertex_count_text = sprintf('%s', format_number(info.m)); 
  end
  if size(regexp(network, 'ut$'))
    network_i = network;
    network_i(end) = 'i'; 
    info_i = read_info(network_i); 
    vertex_count_text = sprintf('%s + %s', vertex_count_text, format_number(info_i.n)); 
  end

  flags = ''; 
  if info.format == consts.SYM,  flags = [flags 'U'   ]; end
  if info.format == consts.ASYM, flags = [flags 'D'   ]; end
  if info.format == consts.BIP
    if size(regexp(network, 'ut$'))
      flags = [flags 'T'   ]; 
    else
      flags = [flags 'B'   ]; 
    end
  end

  if info.weights == consts.UNWEIGHTED, flags = [flags '$-$'];   end
  if info.weights == consts.POSITIVE,   flags = [flags '$=$'];   end
  if info.weights == consts.SIGNED,     flags = [flags '$\pm$']; end
  if info.weights == consts.WEIGHTED,   flags = [flags '$\APLstar$'];   end

  if has_timestamps(network), flags = [flags '\Clocklogo']; end; 

  metadata = read_metadata(network)

  long_name = metadata.name;

  name_with_link = sprintf('\\href{%s}{%s}', metadata.url, long_name)

  %
  % Statistics
  %
  if hide_stat
    stat_text = ''; 				   
  else

    try
      power = read_statistic('power', network); 
      power_text = sprintf('%.1f', power(1)); 
    catch exception
      if ~strcmp(exception.identifier, 'MATLAB:load:couldNotReadFile')
        throw(exception);
      end
      power_text = '--'; 
    end

    try
      diameter = read_statistic('diameter', network);
      diameter_text = sprintf('%.1f', diameter(1)); 
    catch exception
      if ~strcmp(exception.identifier, 'MATLAB:load:couldNotReadFile'), throw exception; end
      diameter_text = '--'; 
    end

    try
      coco = read_statistic('coco', network);
      coco_text = format_number(coco(1)); 
    catch exception
      if ~strcmp(exception.identifier, 'MATLAB:load:couldNotReadFile'), throw exception; end
      coco_text = '--'; 
    end

    stat_text = sprintf('\t%s\t%s\t%s', diameter_text, power_text, coco_text);   
  end

  %
  % Short name
  % 
  code = metadata.code;

  if size(regexp(network, 'ut$'))
    code = code(1 : end-4); 
  end
  code = sprintf('\\textsf{%s}', code); 

  %
  % Description
  %
  description_network = network;
  if size(regexp(description_network, 'ut$'))
    description_network = [description_network 'i']; 
  end
  description = metadata.description; 

  % 
  % Citation 
  %
  if isfield(metadata, 'cite') 
    cite_text = sprintf('[%s]', metadata.cite); 
  else
    cite_text = ''; 
  end

  %
  % Output
  %
  fprintf(OUTFILE, '%s [%s]\t%s\t%s\t%s\t%s\t%s\t%s%s\n', ...
    network_key(metadata), ...
    cite_text, flags, ...
    code, name_with_link, ...
    description, ...
    vertex_count_text, format_number(info.r), ...
    stat_text); 
end

if 0 > fclose(OUTFILE), error 'fclose'; end
