function p = analyze_image(im,pix2um,cutoff)
    %% Get boundaries of contaminants
    global debug
    [B,L] = bwboundaries(im);                                               % Get bounderies and label them
    if debug == 1
        figure; imshow(label2rgb(L,@jet,[.5 .5 .5]))
        title('Labeled Image')
    end

    %% Get properties
    eCircle = 0.8;
    N = length(B);
    stats = regionprops(L,'Area','Centroid','MajorAxisLength',...
            'Orientation','MinorAxisLength', 'Eccentricity','Extrema');

    % Assign each particulate its properties in structure
    p = []; counter = 1;
    for k = 1:N
        boundary = B{k};
        x = boundary(:,2);                                                  % X-Boundary
        y = boundary(:,1);                                                  % Y-Boundary                

        if stats(k).Eccentricity <= eCircle
           sz = stats(k).MajorAxisLength;
        else            
           sz = getsize(stats(k).Extrema,stats(k).Orientation);
        end

        % Capture properties of particules that meet area criteria
        tmpSize = sz * pix2um;                                              % Temporary Size [um]
        if tmpSize >= cutoff(1) && tmpSize <= cutoff(2)                     % Cutoff for particules areas to consider
            name = ['n' num2str(counter)];
            p.(name).x = x * pix2um ;                                       % X boundary [um]
            p.(name).y = y * pix2um ;                                       % Y boundary [um]
            p.(name).Size = sz * pix2um;                                    % Feret Size [um]
            p.(name).Area = stats(k).Area * pix2um^2 ;                      % Area [um^2]
            p.(name).Center = stats(k).Centroid * pix2um ;                  % Center [um]
            p.(name).MajorAxisLength = stats(k).MajorAxisLength * pix2um ;  % Major axis length
            p.(name).Orientation = stats(k).Orientation;                    % Angle [degrees]
            p.(name).MinorAxisLength = stats(k).MinorAxisLength* pix2um;    % Minor axis (perpendicular to major axis)
            p.(name).Eccentricity = stats(k).Eccentricity;                  % Eccentiricity (eCircle defines circle cut off)
            p.(name).Extrema = stats(k).Extrema;                            % The format of the vector is [top-left top-right right-top right-bottom bottom-right bottom-left left-bottom left-top]                
            counter = counter+1;           
        else
           if debug==1
               hold on;plot(x,y,'w','LineWidth',2)
           end
        end       
    end
end

%%
function [sz,edge1,edge2] = getsize(ext,ang)      
    ang = abs(ang);
    if ang >= 45 && ang <= 90
        edge1 = [ext(2,1),ext(2,2)];
        edge2 = [ext(6,1),ext(6,2)];                              
    end            
    if ang >= 0 && ang < 45
        edge1 = [ext(8,1),ext(8,2)];
        edge2 = [ext(3,1),ext(3,2)];                                
    end
    sz = sqrt((edge2(1)-edge1(1))^2 + (edge2(2)-edge1(2))^2);
end