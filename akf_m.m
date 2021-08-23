%*****************************************************************
% Kalman�˲�
function [xe, v,  K,Pv]=akf_m(d,x,A,H,G,P,Q ,R)
% d     �۲�����
% x     ��ֵ
% A H G ϵͳ����
% P     ��ֵ�ķ���
% Q R   ����Э�������
% flag  1 ƽ��  0 ֻ����Kalman�˲�   ȱʡֵ��Ϊ1

m=length(x);

if( nargin < 9)  %����ƽ��
    flag=1;
end
if( nargin < 10)  %����ƽ��
    B=zeros(size(x,1),size(x,1));
    u=zeros(size(x,1),size(d,2));
end

nn=size(d,1);


x0=x;
%normal kalman filtering
for k=1:size(d,2)

    %Time update
    %predict state
    x=A*x+B*u(:,k);
    %predict covariance
    P=A*P*A'+G*Q*G';
    xminus(:,k)=x;
    Pminus(:,:,k)=P;   
    %compute Kalman gain
    Pv=H*P*H'+R;
    K=P*H'/(H*P*H'+R);
    %  P3=P;
    %update state 
    v(:,k)=d(:,k)-H*x;   %��Ϣ%
    vv=v(:,k);
    md(k)=vv'*Pv*vv;
    
    K=P*H'/(H*P*H'+R);
    x=x+K*(d(:,k)-H*x);
      
    %update covariance
    %P=(eye(m)-K*H)*P;
    P=(eye(m)-K*H)*P*(eye(m)-K*H)'+K*R*K';

    Pplus(:,:,k)=P;
    xplus(:,k)=x;

    xe(:,k)=x;
end

x=x0;
% compute �������
xalpha=(median(abs(v))/0.6745*3)^2;

%akf
for k=1:size(d,2)

    %Time update
    %predict state
    x=A*x+B*u(:,k);
    
    lamda=1;
    pv=lamda*H*A*P*A'*H'+H*G*Q*G'*H'+R;
    v(:,k)=d(:,k)-H*x;   %��Ϣ%
    vv=v(:,k);
    md(k)=vv'*inv(Pv)*vv;%
    %��������
    nt=0;
    P0=P;
    P=A*P*A'+G*Q*G';
    if k==2937
        k
    end
    % �ο�An adaptive fading Kalman filter based on Mahalanobis distance
    while md(k)>xalpha&&nt<200
        gamma=md(k);
        
        p_minus=lamda*P;
%         lamda1=lamda+(gamma-xalpha)/(vv'*inv(pv)*(H*p_minus*H')*inv(pv)*vv);
        lamda1=lamda+(gamma-xalpha)/(vv'*inv(pv)*(H*P*H')*inv(pv)*vv);
        lamda=lamda1;
        pv=H*p_minus*H'+R;
        md(k)=vv'*inv(pv)*vv;
        nt=nt+1;
    end
    P=P0;

    %predict covariance
    P=lamda*A*P*A'+G*Q*G';

    %compute Kalman gain
    K=P*H'/(H*P*H'+R);

    x=x+K*(d(:,k)-H*x);
      
    %update covariance
    P=(eye(m)-K*H)*P*(eye(m)-K*H)'+K*R*K';

    xe(:,k)=x;
end






end
% %********************************************
% function [M,Pyk]=MSHjuli(y,y1)
% 
% %���Ͼ�����Ϊ�б���
% %yΪ�۲�����y1Ϊ��Ϣ��
% %PykΪ������Ϣ�ĸ����ܶȺ�����
% %Pyk1Ϊ����Э�������
% Pyk=(exp(-1/2*(y-y1)'*inv(Pyk1)*(y-y1)))/sqrt((2*pi)^2*abs(Pyk1));
% 
% M=(y-y1)'*inv(Pyk1)*(y-y1);%���ÿ��y��y1�����Ͼ���
% end
% 
% %********************************************
% function [  ]=KaFjianyan(y)
% %�����������Ϊ������
% %���²��ֽ������ֵδ֪ʱ,����ļ�������е��ұ߼���
% n=length(y(:)); %��������n
% alf=0.05;        %���ɶ�
% c=32.9;         %�ӷֲ��������ֵ
% d=8.91;         %�ӷֲ������Ҷ�ֵ
% 
% y1=means(y);
% 
% for i=1:n-10
% x(i,:)=y(i:i+9);
% 
% x1(i)=means(x(i,:));  
% end
% for i=1:n-1
%     b(i)=(y(i)-y1)^2+(y(i+1)-y1)^2;
% end
% for t=1:10
%     e(i)=(x(i)-x1(i))^2+(x(i+1)-x1(i))^2;
% end
% 
%     rmsv=sqrt(b(end)/n-1);   %���������
%     
%     KF=sqrt(b(end))/rmsv;  %�����ֲ�ͳ����
%    if (c<KF&&KF<d)
%        [xe v s P3 K PP]=kalmansmoother(d,x,A,H,G,P,Q,R,flag,B,u)
%    else 
%    end
% end
%   function [chi2 ]=KaFjianyan1(y)
% Alf=0.05;       %��������95%
% n=length(y(:)); %��������n
% df=n-1;         %���ɶ�df
% y1=means(y);
% for i=1:n-1
%     b(i)=(y(i)-y1)^2+(y(i+1)-y1)^2;
% end
%  rmsv=b(end)/n-1;   %���������
%  
% Py(i)=pdf(norm,y(i),yi,rmsv); %��y�ĵ�i�����ĸ����ܶȺ�����
% chi2=chi2inv(df,Py);  %���ÿ����ֲ����������������ұ߽�
% end
% %*********************************************
% %t������м���
% function [h,sig,ci3]=Tjianyan(Y)
% Alf=0.05;  %������ˮƽ
% u=mean(Y); %���ֵ
% [h, sig, ci3]=ttest(Y, u, Alf, tail);%�Ԧ̽���T����
% %h=1,������ˮƽ�¾ܾ�ԭ���裻h=0,������ˮƽ�½���ԭ���裻
% % sig ��ʾ�� X �ľ�ֵ���� u ��ԭ�����½ϴ����ͳ�������½ϴ�ĸ���ֵ 
% %ci3��ʾ����һ�����Ŷ�Ϊ 100(1-Alf)���ľ�ֵ����������
% %tail=0, ��ʾ�������:�̡�m (Ĭ�� , ˫�߼��� );
% %tail=1, ��ʾ�������: ��>m(�ұ߼��� );
% %tail=-1, ��ʾ������� :��<m(��߼��� ).
% end
% %*********************************************
% %ţ�ٵ�����
% 
% %*******************************************
