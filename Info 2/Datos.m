%% No me juzgen no sé algebra tampoco
syms s F Fo cs cp R x1 x
eqn1=R*s*(x1-x)+(1/cs)*x1==Fo;
eqn2=R*s*(x-x1)+(1/cp)*x==F-Fo;
sol=solve([eqn1,eqn2],[x,x1]);
xsol=sol.x
%% Variables normales
R=0.5;
cs=0.2;
cp=2;

%% Condiciones iniciales de pruebas
t=0.1:0.1:20;
F=(0<t)*1;
Fo=(0<t)*1;
simin=[t.' F.' Fo.'];
%% Simular con circuito electrico
out=simular(R,cs,cp,max(t));
%% comparar datos
a=[R cs cp];
b=[0.2 0.5 1.2];
[out,out2]=comparedata(a,b,10);


%% Funciones 
function out=simular(R,cs,cp,time)
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(1)
bode(out.bodegraf.values)
grid on
figure(2)
x=out.simout.signals.values(:,2);
y=out.simout.time;
subplot(2,1,1)
plot(y,x)
title("Respuesta x circuito electrico")
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
subplot(2,1,2)
x2=out.simout.signals.values(:,1);
plot(y,x2)
title("Respuesta x función de transferencia")
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
end
function [out,out2] =comparedata(a,b,time)
sub1="R: "+num2str(a(1))+" cs: "+num2str(a(2))+" cp: "+num2str(a(3));
sub2="R: "+num2str(b(1))+" cs: "+num2str(b(2))+" cp: "+num2str(b(3));
R=a(1);
cs=a(2);
cp=a(3);
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(1)
bode(out.bodegraf.values)
title(["Diagrama de Bode paciente 1",sub1])
grid on
R=b(1);
cs=b(2);
cp=b(3);
out2=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(2)
bode(out2.bodegraf.values)
title(["Diagrama de Bode paciente 2",sub2])
grid on
x=out.simout.signals.values(:,1);
y=out.simout.time;
figure(3)
subplot(2,1,1)
plot(y,x)
title("Respuesta x paciente")
subtitle(sub1)
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
subplot(2,1,2)
x2=out2.simout.signals.values(:,1);
plot(y,x2)
title("Respuesta x paciente")
subtitle(sub2)
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
end

