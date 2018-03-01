function [headline, dataline] = parse_mood(fdir,fname,mprefix)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV lines (header and data) with visual search results.

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'InvestGame_CBE-20180212-154541-AUXJH.log';

f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
headline = '';
dataline= '';
resp=-1;
seq=1;
answers = [];
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss) > 4)
        if (strcmp(ss{2},'Text') && strcmp(ss{3},'Input'))
            resp=str2num(ss{4});
            headline=strjoin({headline,...
                sprintf('%s_q%02d',mprefix,seq)},',');
            dataline=strjoin({dataline,...
                sprintf('%d',resp)},',');
            answers(seq)=resp;
            seq=seq+1;
        end
    end
    tline = fgetl(fid);
end

% Scoring STAI
% array to indicate which questions are negatively scored
neg_ii = [1,2,5,8,10,11,15,16,19,20];
n = length(answers);
score=0;
if (n~=20)
    fprintf('WARNING - number of answers to STAI is not 20 - it is %d\n', n);
    fprintf('Setting score to 0\n');
    score=0;
else
    score = 0;
    for ii = 1:n
        % Check answer - just in case
        if  (answers(ii) < 1) || (answers(ii) > 4)
            fprintf('WARNING - mood answer to question %d is not between 1 and 4, it is %d\n', ...
                ii,answers(ii));
        end
        % Do ths scoring
        if ismember(ii,neg_ii)
            score = score + (5-answers(ii));
        else
            score = score+answers(ii);
        end
    end
end

% Add score to results
headline=strjoin({headline,sprintf('%s_stai_score',mprefix),','});
dataline=strjoin({dataline,sprintf('%d',score),','});
        
% Remove leading comma
headline = remove_leading_comma(headline);
dataline = remove_leading_comma(dataline);

return









