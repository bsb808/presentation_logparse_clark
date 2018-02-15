

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
wrote_header=false;
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
            [head_vs1, data_vs1, rslt_head_vs1, rslt_data_vs1] = parse_visualsearchlog(user_dir,ff(ii).name,'vs1');
            fprintf('\tParsed visual task 1 - results in %d header columns and %d data columns\n', ...
                length(strsplit(head_vs1,',')),length(strsplit(data_vs1,',')));
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'VisualSearchTask_2'))
             [head_vs2, data_vs2, rslt_head_vs2, rslt_data_vs2]=parse_visualsearchlog(user_dir,ff(ii).name,'vs2');
             fprintf('\tParsed visual task 2 - results in %d header columns and %d data columns\n', ...
                length(strsplit(head_vs2,',')),length(strsplit(data_vs2,',')));
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
            if (any(strfind(ff(ii).name,'CBE'))|| any(strfind(ff(ii).name,'IBV')) )
                [head_ig1,data_ig1]=parse_investgame(user_dir,ff(ii).name,'ig1');
                if (strfind(ff(ii).name,'CBE'))
                    typestr='CBE';
                elseif (strfind(ff(ii).name,'IBV'))
                    typestr='IBV';
                else 
                    typestr='???';
                end
                fprintf('\tParsed investment game 1, type %s, with %d header columns and %d data columns\n', ...
                      typestr,length(strsplit(head_ig1,',')),length(strsplit(data_ig1,',')));
                cnt=cnt+1;
            elseif (strfind(ff(ii).name,'Final'))
                [head_ig2,data_ig2]=parse_investgame(user_dir,ff(ii).name,'ig2');
                fprintf('\tParsed investment game 2, with %d header columns and %d data columns\n', ...
                     length(strsplit(head_ig2,',')),length(strsplit(data_ig2,',')));
                cnt=cnt+1;
            end
        elseif (strfind(ff(ii).name,'ExtraPoints'))
            [head_ep,data_ep] = parse_extrapoints(user_dir,ff(ii).name);
            fprintf('\tParsed extra points with %d header columns and %d data columns\n', ...
                     length(strsplit(head_ep,',')),length(strsplit(data_ep,',')));
                 cnt=cnt+1;
        elseif (strfind(ff(ii).name,'MoodQuestionnaire_1'))
            [head_mood1,data_mood1] = parse_mood(user_dir,ff(ii).name,'mood1');
            fprintf('\tParsed mood 1 with %d header columns and %d data columns\n', ...
                     length(strsplit(head_mood1,',')),length(strsplit(data_mood1,',')));
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'MoodQuestionnaire_2'))
            [head_mood2,data_mood2] = parse_mood(user_dir,ff(ii).name,'mood2');
            fprintf('\tParsed mood 1 with %d header columns and %d data columns\n', ...
                     length(strsplit(head_mood2,',')),length(strsplit(data_mood2,',')));
            cnt=cnt+1;

        end
    end
    fprintf('\tFound %d files\n',cnt);

    % Put all outputs on one line CSV
    head=strjoin({'participantid','type',head_vs1,rslt_head_vs1,...
        head_vs2,rslt_head_vs2,head_ig1,head_ig2,head_ep,head_mood1,head_mood2},',');
    data=strjoin({sprintf('%d',id),typestr,data_vs1,rslt_data_vs1,...
        data_vs2,rslt_data_vs2,data_ig1,data_ig2,data_ep,data_mood1,data_mood2},',');
    % Abbreviated
    head_abv = strjoin({'participantid','type',rslt_head_vs1,...
        rslt_head_vs2,head_ig1,head_ig2,head_ep},',');
    data_abv=strjoin({sprintf('%d',id),typestr,rslt_data_vs1,...
        rslt_data_vs2,data_ig1,data_ig2,data_ep},',');
    % Save output for this participant
    part_outfile = sprintf('rare_%d.csv',id);
    pfid = fopen(part_outfile,'wt');
    fprintf('\tWriting individual data file for participant <%d> to <%s>, %d header fields and %d data fields\n',...
        id,part_outfile,count_fields(head),count_fields(data));
    fprintf(pfid,'%s\n',head);
    fprintf(pfid,'%s\n',head);
    fclose(pfid);

    % Save output to combined files
    if (not(wrote_header))
        fprintf('\tWriting header with %d columns to combined output file <%s>\n',...
            count_fields(head),outfname);
        fprintf(fid,'%s\n',head);
        fprintf('\tWriting header with %d columns to abreviated combined output file <%s>\n',...
            count_fields(head),rsltfname);
        fprintf(rid,'%s\n',head_abv);
        wrote_header=true;
    end
    fprintf('\tWriting %d data columns to <%s>\n',count_fields(data),outfname);
    fprintf(fid,'%s\n',data);
    fprintf('\tWriting %d data columns to <%s>\n',count_fields(data_abv),rsltfname);
    fprintf(rid,'%s\n',data_abv);
end
fclose(fid);
