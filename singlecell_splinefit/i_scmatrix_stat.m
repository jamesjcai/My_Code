function [lgu,dropr,lgcv,glist]=i_scmatrix_stat(X,glist)

dropr=1-sum(X>0,2)./size(X,2);
u=mean(X,2);
cv=std(X,0,2)./u;
lgu=log10(u);
lgcv=log10(cv);

i=isnan(lgu) | isinf(lgu) | isnan(lgcv) | isinf(lgcv);
lgu(i)=[];
lgcv(i)=[];
dropr(i)=[];
glist(i)=[];

[xyz,i]=sortrows([lgu dropr lgcv],[1 2 3],'descend');
lgu=xyz(:,1);
dropr=xyz(:,2);
lgcv=xyz(:,3);
glist=glist(i);






    
    
    
    
    
    