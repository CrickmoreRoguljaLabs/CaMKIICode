# Code for CaMKII measures the passage time to coordinate behavior and motivation

## Contents:

### ACR ASAP:
Code used in analyzing time series voltage imaging experiments on raw fluoresence (MATLAB)

### Calcium imaging:
Code used analyzing .tif files corresponding to time series calcium imaging data after XXM stimulation (MATLAB)

### FretFlim:
Code used for extracting fluorescence lifetime data from .mat files storing relevant variables using a ScanImage spin-off written by Bernardo Sabatini and Gary Yellen (MATLAB)

### Proportions:
Python code using the *pymc* package to sample from the posterior distribution for estimating proportions. Just need to run mcmcm_indep.py if you have the packages installed.

### align_time_series.m
MATLAB script for taking an array of cells, each containing a n x 2 array in which the first row is the t_axis relative to some event, and aligning them within time bins.
