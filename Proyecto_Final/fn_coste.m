function J=fn_coste(theta)
    global u2 y2 t2
    %Recordar cambiar la ecuación
    num=[1 -49.07 theta(1) theta(2)];
    den=[1 2280741.89 theta(3) theta(4)];%Se especifica la forma de la ecuacion a buscar
    Hs=tf(num,den); %Se crea la funcion de transferencia
    ypred=lsim(Hs,u2,t2);
    e=y2-ypred;
    J=sum(e.^2);
end

