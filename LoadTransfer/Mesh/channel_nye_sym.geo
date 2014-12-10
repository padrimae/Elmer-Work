// the points
l      = 40;
h      = 40;
coarse = 2;
fine1  = 0.01;
fine2  = 1;
Point(1) = {0, 0, 0, fine1};
Point(2) = {0, 0.5, 0, fine1};
Point(3) = {0.5, 0, 0, fine1};
Point(4) = {40, 0, 0, fine2};
Point(5) = {40, 40, 0, coarse};
Point(6) = {0, 40, 0, coarse};
// the lines confining your domain
Line(1) = {3, 4};
Line(2) = {4, 5};
Line(3) = {5, 6};
Line(4) = {6, 2};
Circle(5) = {3, 1, 2};
// the closed loop of lines defining your surface/domain
Line Loop(6) = {4, -5, 1, 2, 3};
// the domain
Plane Surface(7) = {6};
// Physical entities = body + boundaries
Physical Surface(8) = {7};
Physical Line(9) = {5, 1};
Physical Line(10) = {2};
Physical Line(11) = {3};
Physical Line(12) = {4};
