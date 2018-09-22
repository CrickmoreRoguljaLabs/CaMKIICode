function empiricals = calcLifetimeMapBFromGY(spcSave)
% Hacked up version of Gary Yellen's code, which is itself an extension of
% Ryohei Yasuda. Hope he didn't make mistakes...
chan = 1;
spc = spcSave;
nsPerPoint=spc.datainfo.psPerUnit/1000;
range = round([spc.fits{chan}.fitstart spc.fits{chan}.fitend]/nsPerPoint);
pos_max2 = spc.switchess{chan}.figOffset;

% now validate some parameters TODO: make this central
if pos_max2 == 0 || isnan (pos_max2)
    pos_max2 = nsPerPoint; % GY changed from 1.0 (!)
    spc.switchess{chan}.figOffset = pos_max2;
    spc_updateGUIbyGlobal('spc.switchess',chan,'figOffset');
end
if range(2) > length(spc.lifetimes{chan})
    range(1) = 1;
    range(2) = length(spc.lifetimes{chan});
    spc.fits{chan}.fitstart=range(1)*nsPerPoint;
    spc.fits{chan}.fitend=range(2)*nsPerPoint;
    spc_updateGUIbyGlobal('spc.fits',chan,'fitstart');
    spc_updateGUIbyGlobal('spc.fits',chan,'fitend');
end

% why do we need to recalculate the projection map here??
% project = reshape(sum(spc.imageMods{chan}, 1),spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);

% get the lifetime for all photons in all pixels
spc.lifetimeAlls{chan} = reshape(sum(sum(spc.imageMods{chan}, 2), 3), spc.size(1), 1);

% find the position of the maximum
[~, pos_max] = max(spc.lifetimeAlls{chan}(range(1):1:range(2)));
pos_max = pos_max+range(1)-1; % and reference it to the full range

% GY: integrate (N(t)*t), ultimately to get mean lifetime
x_project = 1:length(range(1):range(2));  % T (but unscaled), using the first point as t=1 (unscaled)
x_project2 = repmat(x_project, [1,spc.SPCdata.scan_size_x*spc.SPCdata.scan_size_y]);
x_project2 = reshape(x_project2, length(x_project), spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);
sumX_project = spc.imageMods{chan}(range(1):range(2),:,:).*x_project2;
sumX_project = sum(sumX_project, 1);
% add empirical tau
emp_tau = (x_project*spc.lifetimeAlls{chan}(range(1):range(2)))/sum(spc.lifetimeAlls{chan}(range(1):range(2)))*nsPerPoint-pos_max2;

% GY: now calculate Ntotal for each pixel
sum_project = sum(spc.imageMods{chan}(range(1):range(2),:,:), 1);
sum_project = reshape(sum_project, spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);

spc.lifetimeMaps{chan} = zeros(spc.SPCdata.scan_size_y, spc.SPCdata.scan_size_x);

% GY: make a mask to exclude pixels with no photons
bw = (sum_project > 0);

% GY: calculate sum(N(t)*t)/Ntotal, scale according to time, and subtract
% the Figure Offset value from the GUI
spc.lifetimeMaps{chan}(bw) = (sumX_project(bw)./sum_project(bw))*nsPerPoint-pos_max2;
lifetimeMap = spc.lifetimeMaps{chan};
empiricals{1} = lifetimeMap;
empiricals{2} = emp_tau;
end
