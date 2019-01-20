%Feature-Level Manifold Projections Preserving Global Geometry. Three domains.
function [f1, f2, f3]=  dmapGeneralThree(X1, X2, X3, D1, D2, D3, W12, W13, W23, epsilon)
%X1: P1*M1 matrix, M1 examples in a P1 dimensional space.
%X2: P2*M2 matrix
%X3: P3*M3 matrix
%D1: M1*M1 matrix. distance matrix for each domain.
%D2: M2*M2 matrix
%D3: M3*M3 matrix
%W12: M1*M2 sparse matrix modeling the correspondence of X1 and X2.
%W13: M1*M3 sparse matrix
%W23: M2*M3 sparse matrix
%epsilon: precision. 
%f1, f2 and f3 are resulting mapping functions.

    %dim
    k=1000;
    
    %Compute Re-scalars
    [X1s, X2s]=getCorrespondingPoints(X1, X2, W12);
    tpD1=L2_distance(X1s, X1s, 0);
    tpD2=L2_distance(X2s, X2s, 0);
    scal2= computeRescalar(tpD1, tpD2);
    clear tpD2;
    D2=scal2*D2;
  
    [X1s, X3s]=getCorrespondingPoints(X1, X3, W13);
    tpD3=L2_distance(X3s, X3s, 0);
    scal3= computeRescalar(tpD1, tpD3); 
    clear tpD1 tpD3;
    D3=scal3*D3;

    %Create joint distance matrices.
    D12=getDistanceXY(D1, D2, W12);
    D13=getDistanceXY(D1, D3, W13);
    D23=getDistanceXY(D2, D3, W23);

    D=[D1 D12 D13; D12' D2 D23; D13' D23' D3];
    clear D1 D2 D3 D12 D13 D23;
    save D.mat D;
    
    %get dimensions and #instances.
    p1=size(X1,1);
    p2=size(X2,1);
    p3=size(X3,1);
    m1=size(X1,2);
    m2=size(X2,2);
    m3=size(X3,2);
    
    mn=size(D,1);
    if k>mn
        k=mn;
    end
    
    %Alignment
    H=eye(mn,mn)-1/mn*ones(mn,1)*ones(1,mn);
    B=-0.5*H*(D.*D)*H;
    Z=[X1 zeros(p1,m2) zeros(p1, m3); zeros(p2, m1) X2 zeros(p2, m3); zeros(p3,m1) zeros(p3, m2) X3];
    
    A=Z*B*Z'; %this is Z\tauZ'
    B=Z*Z';
    
    [u, s, v]=svd(full(B));
    s=s.*(s>epsilon);
    newk=nnz(s);

    %compute F^+
    for i=1:size(s,1)
        if s(i,i)>0 
            s(i,i)=1/s(i,i);
        end
    end
    Fplus=u(:,1:newk)*sqrt(s(1:newk, 1:newk));

    clear B u s v;

    %T=Fplus'*G*G'*Fplus;
    T=Fplus'*A*Fplus;
    T=0.5*(T+T');

    if (k>size(T,1)) k=size(T,1);  end
    [ev, ea]=eigs(T, k);
    %[ev, ea]=eig(full(T));
    
    ea=diag(ea);
    [x, index]  =sort(ea, 'descend');
    ea =ea(index);
    ev =Fplus*ev(:,index);
    for i=1:size(ev,2)
        ev(:,i)=ev(:,i)/norm(ev(:,i));
    end
    
    %~~~compute mappings~~~
    k=min(k, size(ev,2));
    f1=ev(1:p1,1:k);
    f2=ev(p1+1:p1+p2, 1:k);
    f3=ev(p1+p2+1:p1+p2+p3, 1:k);
    tau=trace(ev(:,1:k)'*A*ev(:,1:k))/k;

end


%get corresponding pints from the input data sets.  
function [Xs, Ys]= getCorrespondingPoints(X, Y, Wxy)

    m=size(Wxy,1);
    p=size(X,1);
    n=size(Wxy,2);
    q=size(Y,1);
    
    total=nnz(Wxy);
    Xs=sparse(p,total);
    Ys=sparse(q,total);
    
    k=0;
    for i=1:m;
        for j=1:n;
            if (Wxy(i,j)>0)
                k=k+1;
                Xs(:,k)=X(:,i);
                Ys(:,k)=Y(:,j);
            end
        end
    end
end

%Create a joint matrix from two given distance matrix.
function Dxy= getDistanceXY(Dx, Dy, Wxy)
    m=size(Dx,1);
    n=size(Dy,1);
    
    Dxy=inf*ones(m, n);
    for i1=1:m;
        for i2=1:n
            if (Wxy(i1,i2)>0)
                tpD=zeros(m,n);
                for j=1:m;
                    for k=1:n;
                        tpD(j,k)=Dx(j,i1)+Dy(k,i2);
                    end
                end
                Dxy=min(Dxy,tpD);
            end
        end
    end
end
    
    
%Compute rescalar for the smallest distance between two distance matrices.
function scal= computeRescalar(X, Y)
  scal=trace(Y'*X)/trace(Y'*Y);
end    
    
    
    
    
    
        

