

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


% Open CVS file for storing data
outfname = 'rare_combined.csv';
fid = fopen(outfname,'wt');

% Loop through each directory
for jj = 1:length(logdirs)
    
% Directory with files for one user
    user_dir = fullfile(logdir,logdirs{jj}); %'./logs/UserA_CBE';
    fprintf('Processing %d of %d folders\n',jj,length(logdirs));
    fprintf('Parsing log files in directory <%s>\n',user_dir);
    
    % Find the files to parse
    ff = dir(user_dir);
    cnt = 0;  % Counter as a way to verify we find everything

    % defaults
    out_vs1 = '';
    out_vs2 = '';
    id = 0;
    for ii = 1:length(ff)
        if (strfind(ff(ii).name,'VisualSearchTask_1'))
            out_vs1=parse_visualsearchlog(user_dir,ff(ii).name,'vs1');
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'VisualSearchTask_2'))
            out_vs2=parse_visualsearchlog(user_dir,ff(ii).name,'vs2');
            cnt=cnt+1;
        elseif (strfind(ff(ii).name,'ParticipantID'))
            id = parse_participantid(user_dir,ff(ii).name);
            if (length(pmap) > 0)
                fprintf('Success: Found partipant ID = %d\n',id);
            else
                fprintf('Failure: No partipant ID\n');
            end
            cnt=cnt+1;
        end
    end
    fprintf('Found %d files\n',cnt);

    % Put all outputs on one line CSV
    row=strjoin({'participantid',sprintf('%d',id),out_vs1,out_vs2},',');
    
    % Save output for this participant
    part_outfile = sprintf('rare_%d.csv',id);
    pfid = fopen(part_outfile,'wt');
    fprintf(pfid,'%s\n',row);
    fclose(pfid);

    % Save output to combined file
    fprintf(fid,'%s\n',row);
end
fclose(fid);
