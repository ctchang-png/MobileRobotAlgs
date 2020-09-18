% (MAYBE) Fixes high cpu usage when MATLAB is idle. See
% http://www.mathworks.com/matlabcentral/answers/114915-why-does-matlab-cause-my-cpu-to-spike-even-when-matlab-is-idle-in-matlab-8-0-r2012b
com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLRENDERER');

% I installed 2016a and it had similiar issues. I read online that turning
% off source code control in preferences is the solution. I tried it and it
% seems to be working after about an hour of testing.