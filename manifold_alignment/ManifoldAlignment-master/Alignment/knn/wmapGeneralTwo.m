%Feature-level Manifold Projections. Two domains.
function [map1, map2]=  wmapGeneralTwo(X1, X2, N1, N2, W12, epsilon, mu)
%X1: P1*M1 matrix, M1 examples in a P1 dimensional space.
%X2: P2*M2 matrix
%N1: M1*k matrix. k nearest neighbours for each example.
%N2: M2*k matrix
%W12: M1*M2 sparse matrix modeling the correspondence of X1 and X2.
%epsilon: precision. 
%\mu: used to balance two goals: matching corresponding pairs and preserving manifold topology.    
 
 
    %~~~Default Parameters~~~
    m=2000;    %max dimensionality of the new space.

    %construct weight matrix for each domain
    n1=size(N1,1); 
    n2=size(N2,1);
    K=min (size(N1,2), size(N2,2));
    
    W1=sparse(n1,n1); 
    W2=sparse(n2,n2);
    for i=1:n1; 
        for j=1:K;
            W1(i,N1(i,j))=1;
        end
    end
    for i=1:n2; 
        for j=1:K;
            W2(i,N2(i,j))=1;
        end
    end
    W1=0.5*(W1+W1');
    W2=0.5*(W2+W2');

    
    sum1=sum(sum(W1))+sum(sum(W2));
    sum2=2*(sum(sum(W12)));
    mu=mu*sum1/sum2;
    
    W=[W1 mu*W12; mu*W12' W2]; 
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
    [u, s, v]=svd(full(Z*Z'));
    F=u*sqrt(s);
    Fplus=pinv(F);
    
    clear u s v;
    save data.mat;
    
    T=Fplus*Z*(I-W)*Z'*Fplus'; 

 
    %~~~eigen decomposition~~~
    T=0.5*(T+T');
    [ev, ea]=eig(full(T));
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
    map1=ev(1:P1,start:m+start-1);
    map2=ev(P1+1:P1+P2, start:m+start-1);
end


