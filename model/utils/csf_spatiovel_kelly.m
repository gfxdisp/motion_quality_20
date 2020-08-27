function S = csf_spatiovel_kelly( rho, vel )
% rho - spatial frequency in cpd
% vel - retinal velocity in deg / sec
% This function is likely to be inaccurate for vel=0

s1 = 6.1;
s2 = 7.3;
p1 = 45.9;

   % Fit based on the paper:
   % [1] J. Laird, M. Rosen, J. Pelz, E. Montag, and S. Daly, "Spatio-velocity CSF as a function of retinal velocity using unstabilized stimuli", 2006, vol. 6057, p. 605705.
   
   c0 = 1.0;
   c1 = 1.0;
   c2 = 1.0;

   vel_clamped = max( vel, 0.01 ); % Added to avoid NaN for vel=0
   
   k = s1 + s2 * abs(log10(vel_clamped/3)).^3;
   rho_max = p1 ./ (vel_clamped+2);
   
   S = k .* vel_clamped .* rho.^2 .* exp( -2*rho./rho_max );
   

end
