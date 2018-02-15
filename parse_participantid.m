function id = parse_participantid(fdir,fname)

% For debugging
%fdir = './logs/UserA_CBE';
%fname = 'ParticipantID-20180212-153324-PWAKJ.log';

id=0;
f = fullfile(fdir,fname);
fid = fopen(f);
tline = fgetl(fid);
while ischar(tline)
    ss = strsplit(tline);
    if (length(ss)>3)
        if (strcmp(ss{2},'Picture') && strfind(ss{3},'ID'))
            nn = strsplit(ss{3},':');
            try
                id=str2num(nn{2});
            catch
                disp("Error converting ID to number!")
            end
        end
    end
    tline = fgetl(fid);
end


