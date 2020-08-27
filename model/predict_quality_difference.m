function Q = predict_quality_difference(display_config_a, display_config_b, v, predictable, persistence)
    % predict_quality_difference predicts the quality difference between display_configs A and B in JODs
    % +ve values mean when A is better than B
    % display_config_a should be of type DisplayConfig
    % v is the velocity of the tracked moving object in visual degrees / s
    % predictable is a boolean [0/1] whether the motion is predictable by SPEM
    % [persistence] is the proportionate persistence of the display (1=100%)	
    
    m_tb = 383.5854418393431;
    w_p = 1.47281929556791;
    w_o = 1.47281929556791;
    w_j = 2.21867722216986;
    beta_b = 1.83564239998305;
    
    % default value for predictable is 1
    if ~exist('predictable', 'var') || isempty(predictable)
        predictable = 1;
    end
    
    % default value for persistence is 1 (100%)
    if ~exist('persistence', 'var') || isempty(persistence)
        persistence = 1;
    end
    
    % adding utils folder to path
    addpath(sprintf('%s/utils/', fileparts(mfilename('fullpath'))));
    
    % computing hold-type display blur (EQ8.1)
    sigma_da = persistence * v / display_config_a.refresh_rate / pi;
    sigma_db = persistence * v / display_config_b.refresh_rate / pi;
    
    % computing eye blur (EQ 8.2)
    if predictable
        p = [0.001528, 0.072419];
    else
        p = [0.004517, 0.160428];
    end
    sigma_e = persistence * (p(1) * v + p(2)) / pi; 
    
    % computing spatial blur (EQ9)
    sigma_ra = sqrt(2) * display_config_a.fov / display_config_a.resolution() / pi;
    sigma_rb = sqrt(2) * display_config_b.fov / display_config_b.resolution() / pi;
    
    omegas = [0.25, 0.5, 1, 2, 4, 8, 16, 32, 64];
    csf_modulated = csf_barten_2(omegas, 100) / m_tb;
    
    % aggregate sigmas for motion-parallel blur (EQ 10)
    sigma_pa = sqrt(sigma_e .^ 2 + sigma_ra .^ 2 + sigma_da .^ 2);
    sigma_pb = sqrt(sigma_e .^ 2 + sigma_rb .^ 2 + sigma_db .^ 2);
    
    % aggregate sigmas for motion-orthogonal blur (EQ 11)
    sigma_oa = sigma_ra;
    sigma_ob = sigma_rb;
    
    % add Q components
    Q = w_p * sig_to_Q(sigma_pa, sigma_pb, omegas, csf_modulated, beta_b) + ... % parallel
        w_o * sig_to_Q(sigma_oa, sigma_ob, omegas, csf_modulated, beta_b) + ... % orthogonal
        w_j * model_QJ(display_config_a.refresh_rate, display_config_b.refresh_rate, v,  predictable); % judder
end

function Q = sig_to_Q(sig_a, sig_b, omegas, csf, beta)
    c_a = gaussian(omegas, 0, 1/(2*pi*sig_a), 1);
    c_b = gaussian(omegas, 0, 1/(2*pi*sig_b), 1);
    Q = sum((c_a.* csf) .^ beta) - sum((c_b.* csf) .^ beta);
end

function Q = model_QJ(rr_a, rr_b, v, pred)
    beta = 2.574657335762098;
    E_th_pred = 218.7120058255750;
    E_th_unpred = 165.7790637102406;
    
    rhos = [rr_a / max(v, 0.001); rr_b / max(v, 0.001)];
    ss = [csf_spatiotemp_kelly(1:50, rr_a); csf_spatiotemp_kelly(1:50, rr_b)];
    peak_ss = max(ss, [], 2);
    min_rhos = [find(peak_ss(1) == ss(1,:), 1); find(peak_ss(2) == ss(2,:), 1)]; 
    rhos = max(min_rhos, rhos);
    E = [csf_spatiotemp_kelly(rhos(1), rr_a), ...
        max(csf_spatiotemp_kelly(rhos(2), rr_b))];
    
    if pred == 1
        E = E / E_th_pred;
    else
        E = E / E_th_unpred;
    end
    Q = (E(2)).^beta - (E(1)).^beta;
end

function y = gaussian(x, mu, sigma, A)
%GAUSSIAN gaussian bell curve
    y = A * exp(-1/2 * ((x - mu) / sigma) .^ 2);
end
