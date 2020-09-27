function uref = trapezoidalVelocityProfile(t, amax, vmax, dist, sgn)
    if dist < (vmax^2)/amax
        tramp = dist/(2*vmax);
        tf = 2*tramp;
    else
        tf = (dist + (vmax^2)/amax)/vmax;
        tramp = min(tf/2, vmax/amax);
    end
    
    if t > tf || t < 0
        vref = 0;
    elseif t<tramp
        vref = amax*t;
    elseif t > tf - tramp
        vref = amax*(tf-t);
    elseif tramp < t && t < tf-tramp
        vref = vmax;
    end
    vref = sgn*vref;
    omref = 0;
    uref = [vref, omref];
end