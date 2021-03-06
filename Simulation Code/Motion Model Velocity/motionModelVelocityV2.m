% motionModelVelocity.m
% Author: Francis Poole
% Date: 23/10/14
%
% Motion Model Velocity - Function that computes p(x_t | u_t, x_(t-1)) 
% based on velocity information
%
% Code has been adapted from: Probabilistic Robotics by Sebastian Thrun

function motionModelVelocityV2( )
% motionModelVelocity computes p(x_end | u, x_start) based on velocity 
% information

%Initalisation
    clc
    clear all
    
    x_end = [0.98, 0.9, 2*pi]; %End pose
    u = [1,1]; %Control
    x_start = [0.9,0.9,2*pi]; %Start pose
    
   %runMotionModelVelocity(x_end, u, x_start)
    %probabilityTheta = zeros(1,631);
    %probability = zeros(201);
    %runMotionModelVelocity(x_end, u, x_start)
    for x = 1:20
        clc
        strcat(num2str(x),'/',num2str(2/0.01))
        xin = 1+(x*(0.01)-0.1)
        for y = 1:20
            for theta = 0:20
                probabilityTheta(theta+1) = runMotionModelVelocity([1+(x*(0.01)-0.1), 0.9+(y*(0.01)-0.1), 2*pi], u, x_start);
            end
            
            yin = 0.9+(y*(0.01)-0.1)
            probability(x,y) = max(probabilityTheta(theta+1))
        end
    end
    surf(probability);
    
    hold on
    %plotCircle(1,1,20,'k'); %Plot noisy agent
    %plot([1, 1 + 20 * cos(2*pi)], [1, 1 + 20 * sin(2*pi)], 'k')
    %plot([1,
    hold off
    %runMotionModelVelocity(x_end, u, x_start)
end

function [probability] = runMotionModelVelocity(x_end, u, x_start)

%Initalisation
    %Start phase
    x1 = x_start(1); %x location
    y1 = x_start(2); %y location
    theta1 = x_start(3); %Bearing
    
    %End phase
    x2 = x_end(1); %x location
    y2 = x_end(2); %y location
    theta2 = x_end(3); %Bearing
    
    %Control
    v = u(1); %Translational velocity
    w = u(2); %Rotational velocity
    
    a = [0.1,0.1,5,5,0.1,0.1]; %Error terms
    
    dt = 0.1; %Time step 

%Algorithm
    %Turning circle
    mu = 1/2 * (((x1 - x2)*cos(theta1) + (y1-y2)*sin(theta1)) / ...
                ((y1 - y2)*cos(theta1) - (x1-x2)*sin(theta1))); %ERROR! when 0 causes NaN
            
    x_star = (x1 + x2)/2 + mu*(y1-y2); %x location of centre of turning circle
    y_star = (y1 + y2)/2 + mu*(x2-x1); %y location of centre of turning circle
    r_star = sqrt((x1-x_star)^2 + (y1-y_star)^2); %Radius of turning circle
    
    %Change of heading direction
    dtheta = atan2(y2-y_star, x2-x_star) - atan2(y1-y_star, x1-x_star);
    
    %Noisy control
    v_hat = dtheta/dt * r_star; %Noisy translational velocity
    w_hat = dtheta/dt; %Noisy rotational velocity
    gamma_hat = (theta2-theta1)/dt - w_hat; %Final rotation from noise
    
    %Probabilities
    prob_v = prob(v-v_hat, a(1)*(v^2) + a(2)*(w^2));
    prob_w = prob(w-w_hat, a(3)*(v^2) + a(4)*(w^2));
    prob_gamma = prob(gamma_hat, a(5)*(v^2) + a(6)*(w^2));
    
    probability = prob_v * prob_w * prob_gamma;
end



function [ probDist ] = prob( a, b )
%prob 

%Normal distribution
probDist = 1/sqrt(2*pi*(b^2)) * exp(-1/2 * (a^2)/(b^2));
end