// the points
x=20;
Point(1) = {0, 0, 0, 1};
Point(2) = {0.5, 0, 0, 0.05};
Point(3) = {-0.5, 0, 0, 0.05};
Point(4) = {x/2, 0, 0, 0.5};
Point(5) = {-x/2, 0, 0, 0.5};
Point(6) = {-x/2, 10, 0, 1};
Point(7) = {x/2, 10, 0, 1};
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
