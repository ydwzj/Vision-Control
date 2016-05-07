g=9.8; R=287.053;
k3 = 3.8e-07; T=300; period = 0.060;
k1 = 0.14*0.45; %0.0947
k2 = 2e-6;
a=3; b=2.5; c=0.01;
tThreshold = 1050;
hArray = zeros(10, 1); Xh = ones(10, 2);
hLog = zeros(10, 1); wLog = zeros(10, 1); wOutLog = zeros(10, 1); 
adjustLog = zeros(10000,4); adjustN = 1;
log = zeros(100000,6); logN = 1;
if 0 == exist('k','var') % make sure it execute only once 
	s = serial('COM8', 'BaudRate', 115200, 'DataBits', 8, 'Terminator','CR/LF', 'InputBufferSize', 1024);
	fopen(s);
end
k=0;
while 1
	[inString count msg] = fgetl(s);
    if 0 == strcmp(msg, '') || count < 14 % communication error
        k = k+ 1;
        continue;
    end
    disp(inString);
	[inData count] = sscanf(inString, '%d %d %d %d %d');
    if count ~= 5 % content error
        k = k+ 1;
        continue;
    end
    t=inData(1,1); w1=inData(2,1); w2=inData(3, 1);
	h=inData(4, 1); checkSum=inData(5, 1);
    if checkSum ~= (t + w1 + w2 + h)
        k = k+1;
        continue;
    end
    if t < tThreshold
        u = 1000;
        fprintf(s, [' %d %d \r\n'], [u, u], 'sync' );
        k = k+ 1;
        continue;
    end
	h0 = (t-1000)/1000*1.5;
	wMeasure = double((w1+w2)/2);
	h = double(h)/1000;
	hArray(mod(k,10)+1, 1) = h;
	Xh(mod(k,10)+1, 1) = double(k)*period;
	if k < 10
        k = k+1;
		continue;
    end
	v=(Xh'*Xh)^(-1)* Xh'*hArray; %velocity
	disp(v(1,1));
	w=((g+a*(h0-h)-b*v(1,1))/k3*exp(g*h/(R*T)))^0.5;
	u=(k1*w+k2*exp(-1*g*h/(R*T))*w^2) + c*( w - wMeasure ) + 1050;
    disp(w); disp(u);
    if u > 2000
        u = 2000;
    end
    u = double(int32(u));
    disp(u);
	fprintf(s, [' %d %d \r\n'], [u, u], 'sync' );
	log(logN, 1) = k; log(logN, 2) = wMeasure; log(logN, 3) = h; log(logN, 4) = t; log(logN, 5) = w; log(logN, 6) = u; logN = logN + 1;
	%parameter adjustment
	if k >= 100
		hLog( mod(k, 10)+1, 1) = h;
        wOutLog( mod(k, 10)+1, 1) = w;
		wLog( mod(k, 10)+1, 1) = wMeasure;
		if k>= 200 && mod(k,10) == 0 && t>tThreshold 
			errorW = mean(wOutLog) - mean(wLog);
            k1 = k1*(1 + errorW/200000);
            k2 = k2*(1 + errorW/200000);
            adjustLog(adjustN, 1) = k;
            adjustLog(adjustN, 2) = k1;
            adjustLog(adjustN, 3) = k2;
            adjustN = adjustN + 1;
            if abs(errorW) < 50
                errorH = h0 - mean(hLog);
                k3 = k3 *(1 - errorH/100 );
                disp(k3);
                adjustLog(adjustN, 4) = k3;
                adjustN = adjustN + 1;                
            end
        end
    end
    k = k+1;
end
