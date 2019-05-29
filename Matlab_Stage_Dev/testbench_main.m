delete(timerfindall);
delete(instrfindall);
try
    delete(imaqfind);
catch
    disp('Image Aquisition Toolbox is not installed.');
end

clear all;
close all;
clc;

addpath(genpath('./'));

testbench = TestBenchClass;
