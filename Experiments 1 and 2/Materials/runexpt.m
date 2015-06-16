% Run the full experiment and collect data

clear all;
close all;

addpath game;

w = Window();


e = StructureLearningExperiment(w);
e.promptSubjectNumber();
e.constructExperiment();

e.run();
