function subplot_properties(h,p)
    % Make the figure to annotate active
    figure(h);hold on
    
    % Elipse formula properties
    phi = linspace(0,2*pi,50);
    cosphi = cos(phi);
    sinphi = sin(phi);

    name = char(fieldnames(p));
        xbar = p.(name).Center(1);
        ybar = p.(name).Center(2);

        a = p.(name).Size/2;
        b = p.(name).MinorAxisLength/2;

        theta = pi* p.(name).Orientation/180;
        R = [ cos(theta)   sin(theta)
             -sin(theta)   cos(theta)];

        xy = [a*cosphi; b*sinphi];
        xy = R*xy;

        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;

        plot(x,y,'b','LineWidth',2);

        % Draws line
        cosOrient = cosd(p.(name).Orientation);
        sinOrient = sind(p.(name).Orientation);
        xcoords = xbar + a * [cosOrient -cosOrient];
        ycoords = ybar + a * [-sinOrient sinOrient];
        line(xcoords, ycoords,'Color','g','LineWidth',2);
   
end