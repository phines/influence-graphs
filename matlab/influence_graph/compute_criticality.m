function [delta_a_sum,delta_a] = compute_criticality(H0,H1,p0,perturbation_size,method,subset)
% usage: [delta_a_sum,delta_a] = compute_criticality(H0,H1,p0,perturbation_size,method,subset)

% Initialize the outputs
n = size(H0,1);
delta_a     = cell(n,1);
delta_a_sum = zeros(n,1);
if nargin<5
    method = 'rows';
end

% pre-compute some things
I = speye(n);
%invIH1 = inv(IH1);
if nargin<6 || isempty(subset)
    subset = (1:n);
end
if islogical(subset)
    subset = find(subset);
end

if isempty(H1) 
    % if we don't need H0/H1, then do this the simpler way
    %H1 = H0;
    H = H0;
    A = sparse(I - H);
    for i = subset
        ei = zeros(n,1);
        ei(i) = 1;
        if strcmp(method,'rows')
            delta = H(i,:)*perturbation_size;
            u = ei;
            v = delta';
            uvT = sparse(i,1:n,delta,n,n);
        else % columns method
            delta = H(:,i)*perturbation_size;
            u = delta;
            v = ei;
            uvT = sparse(1:n,i,delta,n,n);
        end
        num = (A \ (uvT / A));
        den = (1 + v'*(A\u));
        delta_a{i} = p0' * num / den;
        delta_a_sum(i) = sum(delta_a{i});
    end
else
    % otherwise:
    IH1 = sparse(I - H1);
    invIH1 = inv(IH1);
    for i = subset
        ei = zeros(n,1);
        ei(i) = 1;
        if strcmp(method,'rows')
            delta_0 = H0(i,:)*perturbation_size;
            delta_1 = H1(i,:)*perturbation_size;
            ei_delta_0 = sparse(i,1:n,delta_0,n,n);%sparse(ei*delta_0);
            ei_delta_1 = sparse(i,1:n,delta_1,n,n);%sparse(ei*delta_1);
            delta_a{i} = p0'*ei_delta_0*invIH1 + ...
                p0'*(H0-ei_delta_0)*...
                invIH1*ei_delta_1*invIH1/(1+delta_1*invIH1*ei); %#ok<*MINV>
        else % Column-based method
            delta_0 = sparse(H0(:,i)*perturbation_size);
            delta_1 = sparse(H1(:,i)*perturbation_size);
            delta_0_eit = sparse(1:n,i,delta_0,n,n);
            delta_1_eit = sparse(1:n,i,delta_1,n,n);
            delta_a{i} = p0'*delta_0_eit*invIH1 + ...
                p0'*(H0-delta_0_eit)*...
                invIH1*delta_1_eit*invIH1/(1+ei'*invIH1*delta_1); %#ok<*MINV>
        end
        delta_a_sum(i) = sum(delta_a{i});
        %fprintf('%4d: %10e\n',i,delta_a_sum(i));
    end
end

%{
% debug stuff
i = 5;
ei = zeros(n,1);
ei(i) = 1;
delta_0 = H0(i,:)*perturbation_size;
delta_1 = H1(i,:)*perturbation_size;
H0p = H0 - ei * delta_0;
H1p = H1 - ei * delta_1;
a  = p0' + (p0'*H0 )*inv(I-H1 ); %#ok<*MINV>
ap = p0' + (p0'*H0p)*inv(I-H1p);
delta_a_= ap - a
%delta_a__ = (p0'*H0p)*inv(I-H1p) - p0'*H0*inv(I-H1 )
%delta_a__ = -p0'*H0*num/den - p0'*ei*delta_0*inv(I-H1p); % check
%delta_a__ = p0'*H0*inv(I-H1p) - p0'*H0*inv(I-H1) - p0'*ei*delta_0*inv(I-H1p); % check
%SM = inv(I-H1) - inv(I-H1)*ei*delta_1*inv(I-H1)/(1+delta_1*inv(I-H1)*ei);
%delta_a__ = p0'*H0*SM - p0'*H0*inv(I-H1) - p0'*ei*delta_0*SM;% check
invIH1 = inv(I-H1);
delta_a__  = -p0'*ei*delta_0*invIH1 - ...
             p0'*(H0-ei*delta_0)*...
             invIH1*ei*delta_1*invIH1/(1+delta_1*invIH1*ei);
err = delta_a_ - delta_a__
%delta_a__ = p0'*(H0 - ei*delta_0)*inv(IH1p) - p0'*H0*inv(IH1)
%delta_a_sum(i)
%}

