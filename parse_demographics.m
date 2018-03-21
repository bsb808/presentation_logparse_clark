function [headline,dataline] = parse_demographics(fdir,fname)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV line with visual search results.

% For debugging
%  fdir = './logs/UserA_CBE';
%  fname = 'Demographics-20180212-155756-EJSHO.log';

f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
headline = '';
dataline = '';
ct=-1;
invest=-1;
cnt=1;
resp={};
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss) > 4)
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            tinput = ''; %ss{4};
            jj=1;
            cont = true;
            while ((jj < length(ss)) && cont)
                if ~isempty(str2num(ss{3+jj+1})) && str2num(ss{3+jj+1})>1000
                    cont=false;
                end
                tinput = strcat(tinput, ss{3+jj},' ');
                jj=jj+1;
            end
            resp{cnt}=tinput;
            cnt=cnt+1;
        end
    end
    tline = fgetl(fid);
end
prefix='demographics';
for ii = 1:length(resp)
    headline = strjoin({headline,sprintf('%s_q%d',prefix,ii),','});
    dataline = strjoin({dataline,sprintf('"%s"',resp{ii}),','});
end

disp(headline);
disp(dataline);

return









