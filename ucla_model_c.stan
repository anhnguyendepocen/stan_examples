  data {
    int<lower=1> N;
    real alcuse[N];   //outcome
    real age_14[N];   //predictor
    int<lower=0> coa[N];
    int<lower=1> J;   //number of subjects
    int<lower=1, upper=J> id[N];  //subject id
    vector[2] mu_prior; //vector of zeros passed in from R
  }
  parameters {
    vector[4] b;      // intercept and slope
    vector[2] u[J];   // random intercept and slope
    real<lower = 0> sig_e;  // residual variance 
    vector<lower=0>[2] sig_u;   // cluster variances for intercept and slope
    corr_matrix[2] Omega;     // correlation matrix for random intercepts and slopes
  }
  model {
    matrix[2,2] L_beta;
    real mu[N];
    L_beta <- cholesky_decompose(Omega);
    for (k1 in 1:2) {
      for (k2 in 1:k1) {
        L_beta[k1,k2] <- sig_u[k1] * L_beta[k1,k2];
      }
    }
    for (j in 1:J) {
      u[j] ~ multi_normal_cholesky(mu_prior, L_beta);
    }
    for (i in 1:N) {
      mu[i] <- b[1] + b[2]*age_14[i] + b[3]*coa[i] + 
              b[4]*coa[i]*age_14[i] + u[id[i], 1] + u[id[i], 2]*age_14[i];
    }
    alcuse ~ normal(mu,sig_e);    // likelhood
    b ~ normal(0,5);
    sig_e ~ cauchy(0,2);
    sig_u ~ cauchy(0,2);
    Omega ~ lkj_corr(2.0);
  }
   generated quantities {
    matrix[2,2] Sigma;
    Sigma <- diag_matrix(sig_u) * Omega * diag_matrix(sig_u);
  }

  
  