function [headline,dataline] = parse_extrapoints(fdir,fname)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV line with visual search results.

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'InvestGame_CBE-20180212-154541-AUXJH.log';

f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
headline = '';
dataline = '';
ct=-1;
invest=-1;
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss) > 4)
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            invest=str2num(ss{4});
        end
    end
    tline = fgetl(fid);
end
prefix='extrapoints';
headline=sprintf('%s_investment',prefix);
dataline=sprintf('%d',invest);








