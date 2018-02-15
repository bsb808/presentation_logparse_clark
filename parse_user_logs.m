

% Parsing log files
% Directory where all the log files are
logdir = './logs' 

% Find all the subdirectories
dd = dir(logdir)
logdirs = {};
cnt=1;
for d = 1:length(dd)
    if (dd(d).isdir && not(strcmp(dd(d).name,'.')) && not(strcmp(dd(d).name,'..')))
        logdirs{cnt} = dd(d).name;
        cnt=cnt+1;
    end
    
end

% Open combined CVS file for storing data
outfname = 'rare_combined.csv';
fid = fopen(outfname,'wt');
rsltfname = 'rare_combined_abbrev.csv'
rid = fopen(rsltfname,'wt');
% Loop through each directory, i.e., each participant
for jj = 1:length(logdirs)
    
% Directory with files for one user
    user_dir = fullfile(logdir,logdirs{jj}); %'./logs/UserA_CBE';
    fprintf('Processing %d of %d folders: <%s>\n',jj,length(logdirs),user_dir);
         
    % Find the files to parse
    ff = dir(user_dir);
    cnt = 0;  % Counter as a way to verify we find everything

    % defaults
    out_vs1 = '';
    rslt_vs1 = '';
    out_vs2 = '';
    rslt_vs2 = '';
    out_ep = '';
    id = 0;
    
    typestr = 'type,XXX'; 
    for ii = 1:length(ff)
        if (strfind(ff(ii).name,'VisualSearchTask_1'))
            [out_vs1, rslt_vs1] = parse_visualsearchlog(user_dir,ff(ii).name,'vs1');
            fprintf('\tParsed visual task 1 - results in %d columns\n', ...
                length(strsplit(out_vs1,',')));
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'VisualSearchTask_2'))
            [out_vs2, rslt_vs2]=parse_visualsearchlog(user_dir,ff(ii).name,'vs2');
            fprintf('\tParsed visual task 2 - results in %d columns\n', ...
                length(strsplit(out_vs2,',')));
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'ParticipantID'))
            id = parse_participantid(user_dir,ff(ii).name);
            if (id > 0)
                fprintf('\tSuccess: Found partipant ID = %d\n',id);
            else
                fprintf('\tFailure: No partipant ID\n');
            end
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'InvestGame_'))
            if (strfind(ff(ii).name,'CBE'))
                typestr='type,CBE';
                out_ig1=parse_investgame(user_dir,ff(ii).name,'ig1');
                fprintf('\tParsed investment game 1, type CBE with %d columns\n', ...
                      length(strsplit(out_ig1,',')));
                cnt=cnt+1;
            elseif (strfind(ff(ii).name,'IBV'))
                typestr='type,IBV';
                out_ig1=parse_investgame(user_dir,ff(ii).name,'ig1');
                fprintf('\tParsed investment game 1, type IBV with %d columns\n', ...
                     length(strsplit(out_ig1,',')));
                cnt=cnt+1;
            elseif (strfind(ff(ii).name,'Final'))
                out_ig2=parse_investgame(user_dir,ff(ii).name,'ig2');
                fprintf('\tParsed investment game 2, with %d columns\n', ...
                     length(strsplit(out_ig2,',')));
                cnt=cnt+1;
            end
        elseif (strfind(ff(ii).name,'ExtraPoints'))
            out_ep = parse_extrapoints(user_dir,ff(ii).name);
            fprintf('\tParsed extra points with %d columns\n', ...
                     length(strsplit(out_ep,',')));
                 cnt=cnt+1;
        elseif (strfind(ff(ii).name,'MoodQuestionnaire_1'))
            out_mood1 = parse_mood(user_dir,ff(ii).name,'mood1');
            fprintf('\tParsed mood 1 with %d columns\n', ...
                     length(strsplit(out_mood1,',')));
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'MoodQuestionnaire_2'))
            out_mood2 = parse_mood(user_dir,ff(ii).name,'mood2');
            fprintf('\tParsed mood 2 with %d columns\n', ...
                     length(strsplit(out_mood2,',')));
            cnt=cnt+1;

        end
    end
    fprintf('\tFound %d files\n',cnt);

    % Put all outputs on one line CSV
    row=strjoin({'participantid',sprintf('%d',id),typestr,out_vs1,rslt_vs1,...
        out_vs2,rslt_vs2,out_ig1,out_ig2,out_ep,out_mood1,out_mood2},',');
    % Abbreviated
    rrow=strjoin({'participantid',sprintf('%d',id),typestr,rslt_vs1,...
        rslt_vs2,out_ig1,out_ig2,out_ep},',');
    % Save output for this participant
    part_outfile = sprintf('rare_%d.csv',id);
    pfid = fopen(part_outfile,'wt');
    fprintf(pfid,'%s\n',row);
    fclose(pfid);

    % Save output to combined files
    fprintf('\tWriting %d columns to <%s>\n',length(strsplit(row,',')),outfname);
    fprintf(fid,'%s\n',row);
    fprintf('\tWriting %d columns to <%s>\n',length(strsplit(rrow,',')),rsltfname);
    fprintf(rid,'%s\n',rrow);
end
fclose(fid);
