clc;clear;close all
% Determine boundaries of black areas on a background 

addpath('./sub')                                                            % Subroutines
global debug                                                                % Debug flag across subroutines

%% User Input
ifile  = './Image.tif';
pix2real = 5;                                                           % Pixels to real measuremetn conversion (e.g. pixel to meters)
cutoff = [0 1E99];                                                      % Size cutoff for detecting areas [real units]
debug = 1;                                                              % Flag for debugging

%% Read and clean image    
[imOrignal,im] = clean_image(ifile);  

%% Get particulate boundaries
p = analyze_image(im,pix2real,cutoff);

%% Plot image with boundaries
% Convert image to real size
[N,M] = size(imOrignal);RI = imref2d(size(imOrignal)); 
RI.XWorldLimits = [0 M*pix2real]; RI.YWorldLimits = [0 N*pix2real];

h = figure('Name','Identified Particulates');
imshow(imOrignal,RI);hold on
ax = gca;ax.Visible = 'on';xlabel('X [\mum]');ylabel('Y [\mum]')

% Plot particulates
pN = length(fieldnames(p));
for k = 1:pN
    name = ['n' num2str(k)];
    x = p.(name).x; y = p.(name).y;                    
    plot(x,y,'r','LineWidth', 2)                                        % Plot boundaries particulate        

    % Label Size of particulate
    cX = p.(name).Center(1); cY= p.(name).Center(2);
    sz = num2str(p.(name).Size,'%2.0f');
    text(cX,cY,sz,...
         'Color','w','FontWeight','bold','FontSize',10)                   
end    
% Plot more properties if debug flag is on
if debug == 1;plot_properties(h,p);end

%% Largest Particulates Zoomed-in
% Plot top 9 large particulates (or however many available)
sz = zeros(1,pN);
for i = 1:pN
    name = ['n' num2str(i)];   
    sz(i) = p.(name).Size;
end
[~,I] = sort(sz,'descend');    
figure('Name','Largest Particulates');hold on 
for k = 1:min([pN,9]) % either do top 9, or if less than that particles then all of them
    curP = I(k);
    name = ['n' num2str(curP)];

    subplot(3,3,k)
    imshow(imOrignal,RI);hold on
    plot(p.(name).x , p.(name).y , 'r', 'LineWidth', 2) 
    xlim([min(p.(name).x)-100,max(p.(name).x)+100])
    ylim([min(p.(name).y)-100,max(p.(name).y)+100])
    ax = gca;ax.Visible = 'off';

    % Draw Ferret line
    if debug == 1
        ps.(name) = p.(name);
        subplot_properties(gcf,ps)
        clear ps;
    end

    % Label Size of particulate
    cX = p.(name).Center(1); cY= p.(name).Center(2);
    sz = num2str(p.(name).Size,'%2.0f');
    text(cX,cY,[sz '\mum'],...
   'Color','w','FontWeight','bold','FontSize',10)

end
hold off

%% Output results
% Historgram 
edges = [0 15  25 50 100 250 500 750 1000 1250 1E99];                   % Histogram edges
nE = length(edges);sz = zeros(1,pN);    
for i = 1:pN
    name = ['n' num2str(i)];
    sz(i) = p.(name).Size;                                              % Sizes of all 
end    
[pBin,~] = histcounts(sz,edges);
figure('Name','Size Distribtuion'); bar(pBin);

% Label X axis
str = cell(1,nE);
str{1} = ['<' num2str(edges(2))];                                       % First axis label
for i = 2:nE-2
    str{i} = ['[' num2str(edges(i)) ' - ' num2str(edges(i+1)) ')'];     % Other axis labels
end
str{nE-1} = ['>=' num2str(edges(nE-1))];                                 % Last axis label
ax=gca;ax.XTickLabel = str;
grid on;ylabel('Count');xlabel('Size [\mum]')

% Tabular bin results
for i = 1:nE-1
    fprintf('%15s = %5i\n',str{i},pBin(i))
end

%% PAC
ar = zeros(1,pN);
for i = 1:pN
    name = ['n' num2str(i)];
    ar(i) = p.(name).Area;                                              % Area of all 
end
s_pA = sum(ar);                                                         % Sum of particules area [um^2]
s_iA = M*pix2real * N*pix2real;                                             % Image area [um^2]
PAC = s_pA/s_iA * 100;
fprintf('PAC = %4.2f%%\n',PAC);