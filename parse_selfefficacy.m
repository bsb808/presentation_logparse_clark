function [headline,dataline] = parse_selfefficacy(fdir,fname)

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
cnt=1;
resp=[];
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss) > 4)
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            resp(cnt)=str2num(ss{4});
            cnt=cnt+1;
        end
    end
    tline = fgetl(fid);
end
prefix='selfefficacy';
for ii = 1:length(resp)
    headline = strjoin({headline,sprintf('%s_q%d',prefix,ii),','});
    dataline = strjoin({dataline,sprintf('%d',resp(ii)),','});
end

return









