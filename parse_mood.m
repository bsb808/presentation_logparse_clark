function outline = parse_mood(fdir,fname,mprefix)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV line with visual search results.

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'InvestGame_CBE-20180212-154541-AUXJH.log';

f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
outline = '';
resp=-1;
seq=1;
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss) > 4)
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            resp=str2num(ss{4});
            outline=strjoin({outline,...
                sprintf('%s_q%02d,%d',mprefix,seq,resp)},',');
            seq=seq+1;
        end
    end
    tline = fgetl(fid);
end

if (length(outline)>2)
    outline=outline(2:end);
end









