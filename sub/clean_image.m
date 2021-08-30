function [im,imbw] = clean_image(filename)
    % Fucnction for reading image and cleaning it up
    global debug
    
    %% Read image    
    warning('off', 'Images:initSize:adjustingMag');
    im   = imread(filename);                                                % Orignal image        
    im = im(:,:,1);                                                         % temporary for editted picture
    
    % Convert image to grayscale, only if it is RGB
    [~,~, nColor] = size(im);
    if nColor >1
        imgray = rgb2gray(im);    
    else
        imgray = im;
    end

    %% Clean up image
    mf = ones(2,2)/4;                                                       % Median filter
    imclean = imfilter(imgray,mf);                                          % Apply filter

    % Convert image to binary image
    imbw = imbinarize(imclean,'adaptive','Sensitivity',0.99,...
                             'ForegroundPolarity','bright');                              
    %% Debug flag                         
    if debug == 1                    
        % Show cleaned image
        figure;
        subplot(2,2,1); imshow(im);      title('Orignal Image');            % Show original image
        subplot(2,2,2); imshow(imgray);  title('Grayscale Image');          % Show grayscale image
        subplot(2,2,3); imshow(imclean); title('Cleaned Image');            % Show cleaned image
        subplot(2,2,4); imshow(imbw);    title('B&W Image');                % Show B&W image    
    end         
end