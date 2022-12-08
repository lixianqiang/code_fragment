function [diff_ang]=angDiff(end_ang,origin_ang)
end_ang=wrapToPi(end_ang);
origin_ang=wrapToPi(origin_ang);

delta_ang=end_ang-origin_ang;
abs_delta_ang=abs(delta_ang);
abs_comple_ang=2*pi-abs_delta_ang;

if abs_delta_ang<=abs_comple_ang
    diff_ang=delta_ang;
else
    diff_ang=-abs_comple_ang*(delta_ang>0)+abs_comple_ang*(delta_ang<0);
end
end

