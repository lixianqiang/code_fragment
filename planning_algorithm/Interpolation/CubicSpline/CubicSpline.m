% Cubic Spline 
% Reference link 
%   https://blog.csdn.net/zb1165048017/article/details/48311603
%   https://zh.wikipedia.org/wiki/%E6%A0%B7%E6%9D%A1%E6%8F%92%E5%80%BC
%   https://blog.csdn.net/AdamShan/article/details/80696881
function CubicSpline()
% x=0:2*pi;
% y=sin(x);
x=[1,2,3,4,5,6,7,8,8.1]';
% y=[4.5,6.5,1.2,3.4,5.6,4.8,8.8,1.2,1.21]';
% dP1=110;
% dPn=116;

y=[[1,4.5];[1,6.5];[1,1.2];[1,3.4];[1,5.6];[1,4.8];[1,8.8];[1,1.2];[1,1.21]];
dP1=[110,90];
dPn=[116,57];

dt=0.01;

[f a b c d]=cubicSpline(x,y,dP1,dPn);

% [f a b c d]=cubicSpline(x,y);
pXY=[];
for i=1:length(x)-1
    px=[x(i):dt:x(i+1)]';
    py=subs(f(i,:),'t',px);
    n=length(px);
    xxx=px(1:n,1);
    yyy=double(py(1:n,:));
    pXY=[pXY; [xxx, yyy]];
end


% plot(x,y(:,2),'b')
% plot(pXY(:,1),pXY(:,3))
% 
% plot(x,y(:,1),'b')
% plot(pXY(:,1),pXY(:,2))
t0 = pXY(:,1)
x0 = pXY(:,2)
y0 = pXY(:,3)
% plot3(x,y(:,1),y(:,2))
plot3(x0,t0,y0)
hold on
end

%This Function include two type of boundary conditions
% Respectively, including condition (a) and (b)
% a) S'(x1)=y1' && S'(xn)=yn'
% b) S''(x1)=y1'' && S''(xn)=yn'' && y1''=yn''=0  
function [func,a,b,c,d] = cubicSpline(x,y,varargin)
if length(x)~=length(y)
    disp('the number of set[x,y] no match,please check it');
    return 
end
n=length(x);
A=zeros(n);
e=zeros(n, size(y,2));
h=zeros(n,1);

for i=2:n
    h(i-1)=x(i)-x(i-1);
end

if ~isempty(varargin) && length(varargin)==2
    % condition a)
    dP1=varargin{1};
    dPn=varargin{2};
    A(1,1:2)=[2,1];
    A(n,n-1:n)=[1,2];
    e(1,:)=6/h(1)*((y(2,:)-y(1,:))/h(1)-dP1);
    e(n,:)=6/h(n-1)*(dPn-(y(n,:)-y(n-1,:))/h(n-1));
else
    % condition b)
    A(1,1)=1;
    A(n,n)=1;
    e(1,:)=zeros(1, size(y,2));
    e(n,:)=zeros(1, size(y,2));
end

for i=2:n-1

    A(i,i-1:i+1) = [h(i-1),2*(h(i-1)+h(i)),h(i)];
    e(i,:) = 6 * ((y(i+1,:)-y(i,:))/h(i) - (y(i,:)-y(i-1,:))/h(i-1));
end

M=A\e;
syms t
for i=1:length(M)-1
    a(i,:)=(x(i+1)-t).^3.*M(i,:)./(6*h(i))
    b(i,:)=(t-x(i)).^3.*M(i+1,:)./(6*h(i))
    c(i,:)=((y(i+1,:)-y(i,:))./h(i)-(M(i+1,:)-M(i,:)).*h(i)/6).*t
    d(i,:)=y(i,:) - M(i,:)*h(i)^2/6 - ((y(i+1,:)-y(i,:))/h(i) - (M(i+1,:)-M(i,:))*h(i)/6)*x(i)
    func(i,:)=a(i,:)+b(i,:)+c(i,:)+d(i,:)
% a(i)=(x(i+1)-t).^3.*M(i)./(6*h(i));
% b(i)=(t-x(i)).^3.*M(i+1)./(6*h(i));
% c(i)=((y(i+1)-y(i))./h(i)-(M(i+1)-M(i)).*h(i)/6).*t;
% d(i)=y(i+1) - M(i+1)*h(i)^2/6 - ((y(i+1)-y(i))/h(i) - (M(i+1)-M(i))*h(i)/6)*x(i+1);
% func(i)=a(i)+b(i)+c(i)+d(i);
end
% func = collect(func);
end
