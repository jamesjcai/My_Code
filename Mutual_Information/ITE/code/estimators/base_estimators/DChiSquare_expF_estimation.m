function [D] = DChiSquare_expF_estimation(Y1,Y2,co)
%function [D] = DChiSquare_expF_estimation(Y1,Y2,co)
%Estimates the Pearson chi-square divergence (D) of Y1 and Y2 using maximum likelihood estimation (MLE) + analytical formula associated to the chosen exponential family.
%Assumption: 2 x np1 - np2 belongs to the natural space. This holds, for example, if the natural space is affine.
%
%We use the naming convention 'D<name>_estimation' to ease embedding new divergence estimation methods.
%
%INPUT:
%  Y1: Y1(:,t) is the t^th sample from the first distribution.
%  Y2: Y2(:,t) is the t^th sample from the second distribution. Note: the number of samples in Y1 [=size(Y1,2)] and Y2 [=size(Y2,2)] can be different.
%  co: divergence estimator object.
%
%REFERENCE: 
%    Frank Nielsen and Richard Nock. On the chi square and higher-order chi distances for approximating f-divergences. IEEE Signal Processing Letters, 2:10-13, 2014.

%Copyright (C) 2012- Zoltan Szabo ("http://www.gatsby.ucl.ac.uk/~szabo/", "zoltan (dot) szabo (at) gatsby (dot) ucl (dot) ac (dot) uk")
%
%This file is part of the ITE (Information Theoretical Estimators) toolbox.
%
%ITE is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
%This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with ITE. If not, see <http://www.gnu.org/licenses/>.

%co.mult:OK. The information theoretical quantity of interest can be (and is!) estimated exactly [co.mult=1]; the computational complexity of the estimation is essentially the same as that of the 'up to multiplicative constant' case [co.mult=0]. In other words, the estimation is carried out 'exactly' (instead of up to 'proportionality').

%verification:
    if size(Y1,1) ~= size(Y2,1)
        error('The dimension of the samples in Y1 and Y2 must be equal.');
    end
    
%MLE:
  np1 = expF_MLE(Y1,co.distr);
  np2 = expF_MLE(Y2,co.distr);
  
D = expF_Dtemp4(co.distr,np1,np2,2,-1) - 1; %assumption: 2 * np1 - np2 belongs to the natural space. This holds, e.g., if the natural space is affine.
    

