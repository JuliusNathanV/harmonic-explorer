%Harmonic explorer. Exploration process where the colour of undiscovered
%hexagons is determined by a random walk. we start at the uncoloured
%hexagon and perform a simple random walk until a coloured hexagaon is
%reached. the uncoloured hexagon will then inherit the colour of the
%hexagon the walk landed on.

%if this is =1 then it will draw the hexagons as they're being discovered
%(only the ones that are being explored/ on the boundary of the interface.
%otherwise it will only draw the interface and the boundary hexagons.
drawHexagons = 0;

%percolation probability. critical is p=1/2
p=1/2;

%rectangle width w (#cols) and height h (#rows)
w = 400;
h = 400; 

%line width for exploration interface. should make this smaller the larger
%your domain is
lineWidth = 1;
%colours for yellow/blue hexagons. top row is RGB for 'blue' hexagons,
%bottom row is the RGB for 'yellow' hexagons.
%default is [0 0 1; 1 1 0] for yellow/blue.
faceColor = [0 0 1; 1 1 0];
% faceColor = [0 0 0; 1 1 1];


%interface color. RGB for interface colour. default is [1 0 0] for red or
%[0 0 0] for black
%[185 145 220]/255 for light lilac
%[165 110 215]/255; for purple
% interfaceColor = [185 145 220]/255;
interfaceColor = [1 0 0];

figure
axis off
hold on
%define the master hexagon
hex0 = rotate(nsidedpoly(6,'SideLength',1/sqrt(3)),360/12);

%define the percolation configuration
config = 2*ones([h,w]);

%colour the left side and bottom side yellow +1 and right and top side blue
%-1. top left corner = +1, bottom right corner = -1, explore from top row

config(1,:) = 0;
config(h,:) = 1;
config(:,1) = 1;
config(:,w) = 0;

%draw boundary vertices
%top and bottom
for j = 1:w
    hex = translate(hex0,[real(j+1*exp(1i*pi()/3)),...
        imag(j+1*exp(1i*pi()/3))]);
    plot(hex,'FaceColor', ...
        faceColor(config(1,j)+1,:))
    hex = translate(hex0,[real(j+h*exp(1i*pi()/3)),...
        imag(j+h*exp(1i*pi()/3))]);
    plot(hex,'FaceColor', ...
        faceColor(config(h,j)+1,:))
end
%left and right
for i = 2:(h-1)
    hex = translate(hex0,[real(1+i*exp(1i*pi()/3)),...
        imag(1+i*exp(1i*pi()/3))]);
    plot(hex,'FaceColor', ...
        faceColor(config(i,1)+1,:))
    hex = translate(hex0,[real(w+i*exp(1i*pi()/3)),...
        imag(w+i*exp(1i*pi()/3))]);
    plot(hex,'FaceColor', ...
        faceColor(config(i,w)+1,:))
end

%keep track of the boundary of two vertices you're on. start between (1,1)
%and (1,2). yellow on left and blue on right. 
%row vertex so multiply on the right
yellow = 1+1*exp(1i*pi()/3);
blue = 2+1*exp(1i*pi()/3);
displacement = blue-yellow;
facing = yellow + displacement*exp(1i*pi()/3);

yellowVertex = [round(2*imag(yellow)/sqrt(3)),...
    round(real(yellow)-imag(yellow)/sqrt(3))];
blueVertex = [round(2*imag(blue)/sqrt(3)),...
    round(real(blue)-imag(blue)/sqrt(3))];
facingVertex =[round(2*imag(facing)/sqrt(3)),...
    round(real(facing)-imag(facing)/sqrt(3))];


%explore until facing vertex is outside of lattice
while facingVertex(1) >= 1 && facingVertex(1) <= h && ...
        facingVertex(2) >= 1 && facingVertex(2) <= w
%if facing vertex colour is undiscovered i.e. then discover it. then colour
%it in.
%discover it via random walk
    if config(facingVertex(1),facingVertex(2)) == 2
        config(facingVertex(1),facingVertex(2)) = ...
            randomWalk(facingVertex,config);
        %colour it in
        if drawHexagons == 1
            color = config(facingVertex(1),facingVertex(2)) ;
            hexCenterCoords = [real(facing),imag(facing)];
            hex = translate(hex0,hexCenterCoords);
            plot(hex,'FaceColor', ...
                faceColor(color+1,:))
%                 [color, color, 1-color])

        end
    end
    %walk along the interface (draw the line segment between the currently
    %occupied vertices.
% line([oldVertex(1),currentVertex(1)],...
%     [oldVertex(2),currentVertex(2)],...
%     'Color','black','LineWidth',1)
    lineStart = yellow + displacement*(1+1i*(1/sqrt(3)))/2;
    lineEnd = yellow + displacement*(1-1i*(1/sqrt(3)))/2;
    line([real(lineStart),real(lineEnd)],...
        [imag(lineStart),imag(lineEnd)],...
        'Color',interfaceColor,'LineWidth',lineWidth);

    %then change the currently occupied yellow/blue vertex to the facing
    %vertex and find the new facing vertex.
    if config(facingVertex(1),facingVertex(2)) == 1
        yellow = facing;
    else
        blue = facing;
    end
    displacement = blue-yellow;
    facing = yellow + displacement*exp(1i*pi()/3);
    
    yellowVertex = [round(2*imag(yellow)/sqrt(3)),...
        round(real(yellow)-imag(yellow)/sqrt(3))];
    blueVertex = [round(2*imag(blue)/sqrt(3)),...
        round(real(blue)-imag(blue)/sqrt(3))];
    facingVertex =[round(2*imag(facing)/sqrt(3)),...
        round(real(facing)-imag(facing)/sqrt(3))];

end

axis equal

function [hexConfig] = randomWalk(facingVertex,config)
    %start at the vertex facingVertex and end when you hit a vertex whose
    %colour is discovered, i.e. not 2. then inherit that colour.
    %since the boundary is always coloured at the beginning we can just
    %pick one of the six directions uniformly at random and not worry about
    %falling off the configuration.

    %possible directions to travel in hex lattice
    directions = [0 1; 0 -1; 1 0; -1 0; -1 1; 1 -1];
    while config(facingVertex(1),facingVertex(2)) == 2
        facingVertex = facingVertex + directions(randi(6),:);
    end
    hexConfig = config(facingVertex(1),facingVertex(2));

end