function [headline, dataline, rslthead, rsltline] = parse_visualsearchlog(fdir,fname,vsprefix)

% Provided a file directory (fdir) and file name (fname)
% Returns a CSV line with visual search results.

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'VisualSearchTask_1-20180212-153645-WDCRA.log';

f = fullfile(fdir,fname);
fid = fopen(f);
seq=1;  % sequence counter
sum_reliance = 0;
sum_nonreliance = 0;
headline = '';
dataline = '';
rslthead = '';
rsltline = '';
tline = fgetl(fid);
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss)>=12)
        if (strcmp(ss{2},'Nothing'))
            % Presentation trial number
            ptrial=str2num(ss{1});
            tt = strsplit(ss{3},{':',';'});
            if (length(tt)==5)
                % Clark's trial number
                ctrial=str2num(tt{2});
                fc=str2num(tt{4});
                ccmap=containers.Map({'nCC','nFNL','nANS'},[4,5,6]);
                kk=ccmap.keys();
                for ii = 1:length(kk)
                    uu = strsplit(ss{ccmap(kk{ii})},{':',';'});
                    if (length(uu) >= 2)
                        eval(sprintf('%s = str2num(uu{2});',kk{ii}));
                    end
                end
                % Now get the response time
                % Read 5 lines
                for mm = 1:5
                    tline=fgetl(fid);
                end
                ss = strsplit(tline);
                if (length(ss) > 5)
                    resptime=str2num(ss{5});
                    % If all is well so far, then add all the information to
                    % the output
                    prefix = sprintf('%s_ptrial%03d_seq%03d_ctrial%03d_',vsprefix,ptrial,seq,ctrial);
                    fcs = sprintf('%sfc',prefix);
                    fcd = sprintf('%d',fc);
                    ccs = sprintf('%scc',prefix);
                    ccd = sprintf('%d',nCC);
                    fnls = sprintf('%sfnl',prefix);
                    fnld = sprintf('%d',nFNL);
                    anss = sprintf('%sans',prefix);
                    ansd = sprintf('%d',nANS);
                    resps = sprintf('%sresptime',prefix);
                    respd = sprintf('%d',resptime);
                    % Calculate reliance: 1=reliance, -1=non-reliance, 0=trash
                    reliance=0;
                    if (not(fc==nCC) && (nFNL==nCC))
                        reliance=1;
                        sum_reliance = sum_reliance  + 1;
                    elseif (not(fc==nCC) && (not(nFNL==nCC)))
                        reliance=-1;
                        sum_nonreliance = sum_nonreliance +1;
                    else
                        reliance=0;
                    end
                    rels = sprintf('%srel',prefix);
                    reld = sprintf('%d',reliance);
                    headline=strjoin({headline,fcs,ccs,fnls,anss,rels,resps},',');
                    dataline=strjoin({dataline,fcd,ccd,fnld,ansd,reld,respd},',');
                    % Increment the counter
                    seq = seq+1;
                end
            end
        end
    end
    tline = fgetl(fid);
end

% Add totals
rels = sprintf('%s_total_reliance',vsprefix);
reld = sprintf('%d',sum_reliance);
nrels = sprintf('%s_total_nonreliance',vsprefix);
nreld = sprintf('%d',sum_nonreliance);
rfracs = sprintf('%s_reliance_fraction',vsprefix);
rfracd = sprintf('%.3f',sum_reliance/(sum_reliance+sum_nonreliance));
%outline = strjoin({outline,rels,nrels,rfrac},',');
rsltline = strjoin({reld,nreld,rfracd},',');
rslthead = strjoin({rels,nrels,rfracs},',');
% get rid of first comma

headline = remove_leading_comma(headline);
dataline = remove_leading_comma(dataline);
rsltline = remove_leading_comma(rsltline);
rslthead = remove_leading_comma(rslthead);

return







