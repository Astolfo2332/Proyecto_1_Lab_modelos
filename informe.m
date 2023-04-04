clc;clear all;close all;
load 'DataE1.mat'
%pasar todo a vectores fila
t=t';
U1=U1';Y1=Y1';Y2=Y2';
%%
%graficar los datos Validación

figure(1)
subplot(211)
plot(t,U1)
title('Entrada evaluación')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('U1')
%salida
subplot(212)
plot(t,Y1)
title('Salida evalución')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('Y1')

%graficar los datos evaluación
figure(2)
subplot(211)
plot(t,U2)
title('Entrada validación')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('U2')

%salida
subplot(212)
plot(t,Y2)
title('Salida evalución')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('Y2')

%% Procesamiento de la señal
%duplico en vector t para poder filtrar las dos señales por separado
t1=t;
t2=t;
Pos_ini=find(t1>=3.168);
t1=t1(Pos_ini)-t1(Pos_ini(1)); %para que el tiempo comience en cero
U1=U1(Pos_ini);
Y1=Y1(Pos_ini);
figure(3)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación recortada','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida evaluación recortada','Tiempo (s)','Amplitud')
legend('Y1')

%Ahora para validación
t2=t2(Pos_ini)-t2(Pos_ini(1)); %para que el tiempo comience en cero
U2=U2(Pos_ini);
Y2=Y2(Pos_ini);
figure(4)
subplot(211)
graficar(t2,U2,'Señal entrada validación recortada','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación recortada','Tiempo (s)','Amplitud')
legend('Y2')

%% Eliminar el offset

pos_off=find(t1<=9.18);
U1_=U1-ones(size(U1,1),1)*mean(U1(pos_off));
Y1_=Y1-ones(size(U1,1),1)*mean(Y1(pos_off));
%validación
U2_=U2-ones(size(U2,1),1)*mean(U2); %NO  se donde comienza a ser constante entonces solo con el promedio de si misma
Y2_=Y2-ones(size(U2,1),1)*mean(Y2);
figure(5)
subplot(211)
graficar(t1,U1_,'Señal entrada evaluación sin offset','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1_,'Señal salida evaluación sin offseet','Tiempo (s)','Amplitud')
legend('Y1')

figure(6)
subplot(211)
graficar(t2,U2_,'Señal entrada validación sin offset','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2_,'Señal salida validación sin offset','Tiempo (s)','Amplitud')
legend('Y2')
%% periodo

%no hay de donde recortar
%% Análisis de frecuencia

ts=min(diff(t));

fs=1/ts;

fsn=100;
fsn1=50;
fsn2=10;

n=round(fs/fsn1); %sujeto a modificaciones

t1=downsample(t1,n);
t2=downsample(t2,n);
U1=downsample(U1_,n);
U2=downsample(U2_,n);
Y1=downsample(Y1_,n);
Y2=downsample(Y2_,n);

figure(7)
subplot(211)
graficar(t1,U1,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y1')

figure(8)
subplot(211)
graficar(t2,U2,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y2')
%% Parametricas 
U1=U1';Y1=Y1';Y2=Y2';U2=U2'; % Se arreglan los vectores
%Se crea el iddata
data_1=iddata(Y1,U1,ts);
data_2=iddata(Y2,U2,ts);
% Busqueda del retardo
nk=delayest(data_1)
nk2=delayest(data_2)
%% Busqueda del modelo
%Empezamos por ARX
NN=struc(1:5,1:5,1:5);
%Estimando el modelo
v=arxstruc(data_1,data_2,NN);
%Para error y orden a partir de los coeficientes
[orden_arx,vmod]=selstruc(v,"AIC");
%Ya conociendo los coeficientes se construye el modelo
M_ARX=arx(data_1,orden_arx);
present(M_ARX)
%%
%Comparamos el modelo con los datos reales
figure()
compare(data_2,M_ARX)
figure()
compare(data_1,M_ARX)
%% Error de las salidas
[salida_arx,fit_arx0,x_arx]=compare(data_2,M_ARX);
e_arx=errorr(salida_arx.y,data_2.y) %Se compara el error con el modelo encontrado
%% Comparando la entrada con el modelo


%%
N=length(U1);
i=2;
AIC_armax=[];
v_armax=[];
for na=1:5
    for nb=1:5
        for nc=1:5
            for nk=1:5
            datos=[na,nb,nc,nk];
            M_armax=armax(data_1,datos);
            fit=M_armax.Report.Fit.FitPercent;
            MSE=M_armax.Report.Fit.MSE;
            datosARMAX(:,i)=[na,nb,nc,nk,fit,MSE];
            [yse_armax,fit_e_armax,x0e_armax]=compare(data_2,M_armax);
            Error=errorr(yse_armax.y,data_2.y);
            v_armax=[v_armax,[Error;na;nb;nc;nk]];
            %AIC
            d=sum(datos);
            vmin=aic_(Error,d,N);
            AIC_armax=[AIC_armax,[vmin;na;nb;nc;nk]];
            i=i+1;
            end
        end
    end
end
%% minimo AIC
b=minaic(AIC_armax);
M_armax=armax(data_1,b(1,2:5));
present(M_armax)
%% Validaciones
figure()
compare(data_1,M_armax)
figure()
compare(data_2,M_armax)
%% OE
%% OE
v_oe=[];
AIC_oe=[];
for i=1:5
    for j=1:5
        for k=1:5
            M_oe=oe(data_1,[i,j,k]);
            [yse_oe,fit_e_oe,x0e_oe]=compare(data_2,M_oe);
            Error=errorr(yse_oe.y,data_2.y);
            v_oe=[v_oe,[Error;i;j;k]];
            d=sum(datos);
            vmin=aic_(Error,d,N);
            AIC_oe=[AIC_oe,[vmin;i;j;k]];
        end
    end
end
%% minimo AIC
b=minaic(AIC_oe);
M_or=oe(data_1,b(1,2:4));
present(M_oe)
%% Validaciones
figure()
compare(data_1,M_oe)
figure()
compare(data_2,M_oe)
%% funciones
function b=minaic(datos)
    minaic_=find(min(datos(1,:))==datos(1,:));
    b=datos(:,minaic_);
    b=b';
end