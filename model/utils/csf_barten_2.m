function S = csf_barten_2( u, L, stim_size )
% CSF model from:
%
% Barten, P. G. J. (2004). Formula for the contrast sensitivity of the human eye. 
% In Proc. SPIE 5294, Image Quality and System Performance (pp. 231–238). doi:10.1117/12.537476
%
% u - frequency in cyc per deg
% L - background (adaptation) luminance
% stim_size - angual area of the stimulus in deg^2

    if( exist( 'stim_size', 'var' ) )
        X_0 = stim_size;
    else
        X_0 = 10;
    end

    S = 5200*exp( -0.0016 * u.^2 .* (1+100./L).^0.08 ) ./ sqrt( (1+144./X_0.^2 + 0.64*u.^2) .* ( (63./L.^0.83)+1./(1-exp( -0.02*u.^2)) ) );

end

