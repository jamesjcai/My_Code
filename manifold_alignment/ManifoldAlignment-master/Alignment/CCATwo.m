%CCA: two domains
function [cca1, cca2]=  CCATwo(X1, X2, W1, W2, W12, epsilon, mu)
%X1: P1*M1 matrix, M1 examples in a P1 dimensional space.
%X2: P2*M2 matrix
%W1: M1*M1 matrix. weight matrix for each domain.
%W2: M2*M2 matrix
%W12: M1*M2 sparse matrix modeling the correspondence of X1 and X2.
%epsilon: precision. 
%\mu: NOT USED
    
    %~~~Default Parameters~~~
    m=200;    %max dimensionality of the new space.
    
    n1=size(W1,1); 
    n2=size(W2,1);
    
    W=[sparse(n1,n1) W12; W12' sparse(n2,n2)]; 
    W=sparse(W);
    clear W1 W2 W12;
    
    D=sum(W);
    D=sqrt(D);
    N=size(W,1);
    D21=sparse(N,N);
    I=sparse(N,N);
    for i=1:max(size(D,1), size(D,2));
        I(i,i)=1;
    	if D(i)==0
    		D21(i,i)=1;
        else
            D21(i,i)=1/D(i);
    	end
    end
   
    W=sparse((D21))*W*sparse((D21));

    %~~~size of X and Y~~~
    P1=size(X1,1); M1=size(X1,2);  
    P2=size(X2,1); M2=size(X2,2);  


    %create W, D, L, Z
    Z=[X1 zeros(P1,M2); zeros(P2, M1) X2];
    Z=sparse(Z);

    %Create T, Tplus (T^+)
%    [u, s, v]=svd(full(Z*Z'));

    [u, s, v]=svds(full(Z*Z'),m);

    F=u*sqrt(s);
    Fplus=pinv(F);
    
    clear u s v;
    save data.mat;
    
    T=Fplus*Z*(I-W)*Z'*Fplus'; 

 
    %~~~eigen decomposition~~~
    T=0.5*(T+T');
    
    [ev, ea]=eigs(full(T),m,'SM');
    
    clear T Z F;

    %sorting ea by ascending order
    ea=diag(ea);
    [x, index]  =sort(ea);
    ea =ea(index); ev=ev(:,index);
    ev =Fplus'*ev;
    for i=1:size(ev,2)
        ev(:,i)=ev(:,i)/norm(ev(:,i));
    end

    %some eigenvalues might be close to 0, and should be filted out
    for i=1:size(ea);
        if ea(i)>epsilon 
            break;
        end
    end
    start=i;

    %~~~compute mappings~~~
    if m>size(ev,2)-start+1 m=size(ev,2)-start+1; end
    cca1=ev(1:P1,start:m+start-1);
    cca2=ev(P1+1:P1+P2, start:m+start-1);
end


