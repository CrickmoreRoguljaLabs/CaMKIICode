function [avg, psem, msem] = align_time_series(t_axis, trace_cell)
% align_time_series(t_axis, trace_cell) with trace_cell a cell, each entry
% being an N x 2 array with the first column the time stamps and the second
% column the values
trace_pool = zeros(length(t_axis)-1,length(trace_cell));
for arg_num = 1:length(trace_cell)
    trace=trace_cell{arg_num};
    for k = 1:(length(t_axis)-1)
        pooled_bins = logical((trace(:,1) >= t_axis(k)).*(trace(:,1) < t_axis(k+1)));
        trace_pool(k,arg_num) = nansum(trace(pooled_bins,2))/nansum(pooled_bins);
    end
end
avg = nanmean(trace_pool,2);
sem = nanstd(trace_pool,0,2)/sqrt(size(trace_pool,2));
psem = avg+sem;
msem = avg-sem;