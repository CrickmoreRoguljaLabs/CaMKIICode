%%% Script for extracting info from Yao's .m files
[file_name, folder_name] = uigetfile('/Users/stephen/Desktop/Data/!! Imaging !!/Calcium Imaging');
Number = length(dir([folder_name file_name(1:end-7) '*.tif']));
xsize=128;
ysize=128;
tsize=256;
%max_count = zeros(xsize,ysize,Number-4);
%full_photon_counts = zeros(tsize,xsize,ysize,Number-4);
%p_counts = zeros(Number,1);
%time_bins = zeros(Number,1);
%avg_lifetime = zeros(Number,1);
%proj = zeros(xsize,ysize,Number-4);
frames = 1;
ii = 1;
clear time_stamp
clear avg_lifetime
imgs = zeros(xsize,ysize,uint8(Number));
while frames < Number - 4;
    clear spcSave
    base_string = [folder_name file_name(1:end-7)];
    try % in case of skipped numbers.
        if ii < 6
                img = imread([base_string '00' num2str(ii+4) '.tif']);
        else
            if ii < 96
                img = imread([base_string '0' num2str(ii+4) '.tif']);
            else
                img = imread([base_string num2str(ii+4) '.tif']);
            end
        end
        imgs(:,:,ii) = img;
        % Keep track of the time axis
        %time_bins(frames) = spcSave.datainfo.psPerUnit;
        %time_stamp{frames} = datetime([spcSave.datainfo.date ' ' spcSave.datainfo.time]);
        % Returns a t by x by y array of doubles for my own lifetime
        % calculation
        %photon_counts = spcSave.imageMods{1,1};
        %full_photon_counts(:,:,:,frames) = photon_counts;
        %max_count(:,:,frames) = squeeze(max(photon_counts));
        %avg_lifetime(frames) = spcSave.fits{1,1}.avgTau;
        %p_counts(frames) = sum(sum(sum(spcSave.imageMods{1,1},1),2),3);
        %proj(:,:,frames) = spcSave.projects{1,1};
        frames = frames + 1;
    end
    ii = ii+1;
    if mod(ii,100) == 0
        disp(['Frame number: ',num2str(frames)])
    end
end

imgs_zeroed = imgs - repmat(median(median(imgs,1),2),[size(imgs,1),size(imgs,2),1]);
t_axis = 0:5.54:5.54*(size(imgs_zeroed,3)-5);
F = squeeze(sum(sum(imgs_zeroed(:,:,1:end-4),1),2));
[peakval, peaktime] = max(F);
t_axis = t_axis - t_axis(peaktime-1);
t_axis = t_axis / 60;
baseline = mean(F(peaktime-20:peaktime-2));
dFoF = (F - baseline)/baseline;
dFoF(peaktime-1) = NaN;
t_axis = t_axis(1:end-1);
dFoF = dFoF(1:end-1);
plot(t_axis,dFoF);