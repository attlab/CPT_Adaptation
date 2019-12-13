function EEGout = my_fxcomb(EEGin,f,basewidth,topwidth,filt_type,rectif,smooth,resamp);
%EEGout = my_fxcomb(EEGin,f,basewidth,topwidth,filt_type,rectif,smooth,resamp);
%Filter on EEGlab dataset (EEGin) via frequency domain trapazoidal comb
%function.
%centrefreqlims = centre points of comb teeth,
%base width = width of trapazoidal comb teeth at the base
%top width = width of trapazoidal comb teeth at the top
%filt_type = bandpass [1] knotch [0];
%rectif = rectify [1] no [0]
%smooth = smooth with boxcar of width in ms [value] no [0]
%resamp = resample [value] no [0]

%Error message
if size(EEGin.data,3)>1;
    error('WHY ARE YOU FILTERING DISCONTINUOUS DATA YOU FOOL?!');
end

%Available frequencies
hz = linspace(0,EEGin.srate,size(EEGin.data,2));

%Reshape centrefreqs if needed
if size(f,2)>1;
    f = f';
end

%Calcaulate the nyquist and prepare a matrix of inflection points for the
%filter
nyq = EEGin.srate/2;
inpoints = [f - basewidth/2 f - topwidth/2 f + topwidth/2 f + basewidth/2];

%Draw a bandpass filter
fx = zeros(size(hz));
for teeth = 1:size(inpoints,1);
    fx(hz>=inpoints(teeth,1) & hz<=inpoints(teeth,2)) = linspace(0,1,sum(hz>=inpoints(teeth,1) & hz<=inpoints(teeth,2)));
    fx(hz>=inpoints(teeth,3) & hz<=inpoints(teeth,4)) = linspace(1,0,sum(hz>=inpoints(teeth,3) & hz<=inpoints(teeth,4)));
    fx(hz>inpoints(teeth,2) & hz<inpoints(teeth,3))  = 1;
end;
fx = fx+fliplr(fx);

%Flip the comb if a knotch is specified
if filt_type==0;
    fx = (1-fx);
end

%Filter the data and rectify if specified
EEGout = EEGin;
if rectif ==1;
    EEGout.data = abs(real(ifft(bsxfun(@times,fft(EEGin.data,[],2),fx),[],2)));
else
    EEGout.data = real(ifft(bsxfun(@times,fft(EEGin.data,[],2),fx),[],2));
end

%Smooth the data, if specified
if smooth>0;
    box_ms = smooth;
    box_dp = (EEGout.srate*box_ms)/1000;
    l = ceil(box_dp/2);
    w = 2*l + 1;
    [c,d] = size(EEGout.data);
    paddata = single([zeros(c,l) EEGout.data zeros(c,l)]);
    for wp = 0:w-1;
        if wp ==0;
            smoothdata = paddata(:,1+wp:d+wp);
        else
            smoothdata = smoothdata+paddata(:,1+wp:d+wp);
        end
    end;
    EEGout.data = reshape(smoothdata./w,EEGout.nbchan,[],EEGout.trials);
end

%Resample the data, if specified
if resamp>0;
    EEGout = pop_resample(EEGout,resamp);
end

end
