function [outline, rsltline] = parse_visualsearchlog(fdir,fname,vsprefix)

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
outline = '';
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
                    fcs = sprintf('%sfc,%d',prefix,fc);
                    ccs = sprintf('%scc,%d',prefix,nCC);
                    fnls = sprintf('%sfnl,%d',prefix,nFNL);
                    anss = sprintf('%sans,%d',prefix,nANS);
                    resps = sprintf('%sresptime,%d',prefix,resptime);
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
                    rels = sprintf('%srel,%d',prefix,reliance);
                    outline=strjoin({outline,fcs,ccs,fnls,anss,rels,resps},',');
                    % Increment the counter
                    seq = seq+1;
                end
            end
        end
    end
    tline = fgetl(fid);
end

% Add totals
rels = sprintf('%s_total_reliance,%d',vsprefix,sum_reliance);
nrels = sprintf('%s_total_nonreliance,%d',vsprefix,sum_nonreliance);
rfrac = sprintf('%s_reliance_fraction,%.3f',vsprefix,sum_reliance/(sum_reliance+sum_nonreliance));
%outline = strjoin({outline,rels,nrels,rfrac},',');
rsltline = strjoin({rels,nrels,rfrac},',');

% get rid of first comma
if (length(outline) > 2)
    outline=outline(2:end);
end







