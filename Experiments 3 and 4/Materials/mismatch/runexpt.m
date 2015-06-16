% Run the full experiment and collect data

clear all;
close all;

w = Window();


e = ShapeGameExperiment(w);
e.promptSubjectNumber();
e.promptExptVersion();
e.constructExperiment();

e.run();
