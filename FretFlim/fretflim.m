%%% Script for extracting info from Yao's .m files
clear Number
[file_name, folder_name] = uigetfile('/Users/stephen/Desktop/Data/!! Imaging !!/FRET-FLIM Camui');
Number = length(dir([folder_name file_name(1:end-7) '*.mat']));
xsize=128;
ysize=128;
tsize=256;
%max_count = zeros(xsize,ysize,Number-4);
clear time_stamp
clear avg_lifetime
clear emp_tau
px_life = zeros(xsize,ysize,Number-4);
time_bins = zeros(Number-4,1);
avg_lifetime = zeros(Number-4,1);
emp_tau = zeros(Number-4,1);
%proj = zeros(xsize,ysize,Number-4);
frames = 1;
ii = 1;
pop1 = zeros(Number-4,1);
imgs = zeros(xsize,ysize,Number-4);
spcs = zeros(xsize,ysize,Number-4);

while frames < Number-3
    clear spcSave
    base_string = [folder_name file_name(1:end-7)];
    try % in case of skipped numbers.
        if ii < 6
                load([base_string '00' num2str(ii+4) '.mat'])
                %imgs(:,:,frames) = imread([base_string(1:end-8) '00' num2str(ii+4) '.tif',3]);
        else
            if ii < 96
                load([base_string '0' num2str(ii+4) '.mat'])
                %imgs(:,:,frames) = imread([base_string(1:end-8) '0' num2str(ii+4) '.tif',3]);
            else
                load([base_string num2str(ii+4) '.mat'])
                %imgs(:,:,frames) = imread([base_string(1:end-8) num2str(ii+4) '.tif',3]);
            end
        end
        % Keep track of the time axis
        time_stamp{frames} = datetime([spcSave.datainfo.date ' ' spcSave.datainfo.time]);
        % Returns a t by x by y array of doubles for my own lifetime
        % calculation
        empiricals = calcLifetimeMapFromGY(spcSave);
        px_life(:,:,frames) = empiricals{1};
        emp_tau(frames) = empiricals{2};
        avg_lifetime(frames) = spcSave.fits{1,1}.avgTauTrunc; 
        pop1(frames) = spcSave.fits{1,1}.pop1;
        %proj(:,:,frames) = spcSave.projects{1,1};
        frames = frames + 1;
        spcs(:,:,frames) = spcSave.projects{1,1};
    catch e %e is an MException struct
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        % more error handling...
    end
    ii = ii+1;
    if mod(ii,100) == 0
        disp(['Frame number: ',num2str(frames)])
    end
end
t_axis = cellfun(@(x) minutes(x- time_stamp{1}), time_stamp, 'UniformOutput',1);

filted = zeros(size(px_life));
thresh = 40; % spc threshold to show up in the filtered image
for k = 1:size(px_life,3)
filted(:,:,k) = medfilt2((spcs(:,:,k+1)>thresh).*px_life(:,:,k));
end
%t_axis = t_axis(1:end-1);
%avg_lifetime = avg_lifetime(2:end);
%% Analyze the pulse
figure;
plot(t_axis,emp_tau,'.');
notebook = load([folder_name '/autonotes.mat']);
notebook = notebook.notebook; % I am well aware of how ridiculous this looks
epoch_change = zeros(length(notebook),1); %tracks the index at which the new epoch starts
pulses = zeros(length(notebook),120); % 5 minutes before and 15 minutes after each pulse
ptimes = zeros(length(notebook),120);
fits = {};
for note = 1:length(notebook)
   time_info = notebook{note};
   time_info = datetime(time_info(1:20)); 
   epoch_change(note) = find(cellfun(@(x) x > time_info, time_stamp, 'UniformOutput', 1),1);
   ptimes(note,:) = t_axis(max(1,(epoch_change(note)-30)):(epoch_change(note) + 70)) - t_axis(epoch_change(note));
   pulses(note,:) = emp_tau(max(1,(epoch_change(note)-30)):(epoch_change(note) + 70));
   fits{note} = fit(ptimes(note,31:end)',pulses(note,31:end)'-pulses(note,end),'exp1');
   figure; plot(ptimes(note,:)',pulses(note,:)','.',0:0.05:ptimes(note,end),fits{note}.a*exp((0:0.05:ptimes(note,end))*fits{note}.b)+pulses(note,end),'r-')
end

