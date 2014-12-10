// the points
r      = 1;
l      = 60;
h      = 60;
coarse1= 3;
coarse2= 3;
fine1  = 0.05;
Point(1) = { 0, 0, 0, fine1};
Point(2) = { r, 0, 0, fine1};
Point(3) = {-r, 0, 0, fine1};
Point(4) = { l, 0, 0, coarse1};
Point(5) = {-l, 0, 0, coarse1};
Point(6) = {-l, h, 0, coarse2};
Point(7) = { l, h, 0, coarse2};
// the lines confining your domain
Line(1) = {5, 3};
Line(2) = {2, 4};
Line(3) = {4, 7};
Line(4) = {7, 6};
Line(5) = {6, 5};
Circle(6) = {2, 1, 3};
// the closed loop of lines defining your surface/domain
Line Loop(7) = {2, 3, 4, 5, 1, -6};
// the domain
Plane Surface(8) = {7};
// Physical entities = body + boundaries
Physical Surface(9) = {8};
Physical Line(10) = {1, 6, 2};
Physical Line(11) = {3};
Physical Line(12) = {4};
Physical Line(13) = {5};
