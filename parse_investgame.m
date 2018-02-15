function outline = parse_investgame(fdir,fname,prefix)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV line with visual search results.

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'InvestGame_CBE-20180212-154541-AUXJH.log';

f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
outline = '';
ct=-1;
invest=-1;
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss)>=3)
        if (strfind(ss{3},'CurrentTotal'))
            tt = strsplit(ss{3},{':'});
            if (length(tt)==2)
                % Clark's trial number
                ct=str2num(tt{2});
            end
        end
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            invest=str2num(ss{4});
        end
    end
     tline = fgetl(fid);
end

outline=sprintf('%s_currenttotal,%d,%s_investment,%d',prefix,ct,prefix,invest);








