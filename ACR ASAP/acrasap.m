%%% Script for extracting info from single .tif containing a ACR + ASAP
%%% imaging data
[file_name, folder_name] = uigetfile('/Users/stephen/Desktop/Data/!! Imaging !!/Calcium Imaging');
xsize=128;
ysize=128;
data = bfopen([folder_name file_name]);
ca = data{1,1};
tsize=(size(ca,1))/3;
cadat = zeros(xsize,ysize,tsize);
for k = 1:3:size(ca,1)
cadat(:,:,(k+2)/3) = ca{k,1};
end
imgs_zeroed = cadat - mean(mean(cadat(:,:,1),1),2);
t_axis = 0:.1385:.1385*(tsize-1);
F = squeeze(sum(sum(imgs_zeroed(:,:,1:end),1),2));
pulse_before_shutter = 72;
t_axis = t_axis - t_axis(pulse_before_shutter);
%t_axis = t_axis / 60;
baseline = mean(F(pulse_before_shutter-20:pulse_before_shutter));
dFoF = (F - baseline)/baseline;
t_axis = [t_axis(1:pulse_before_shutter), 0.5, t_axis(115:end)]';
dFoF =[dFoF(1:pulse_before_shutter); NaN; dFoF(115:end)];
plot(t_axis,dFoF);