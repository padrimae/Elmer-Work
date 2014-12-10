Point(1) = {0, 0, 0,  .1};
Point(2) = {0, 10, 0, 1.0};
Line(1) = {1, 2};
Extrude {10, 0, 0} {
  Line{1}; Layers{100}; Recombine;
}
Physical Surface(1) = {5};
Physical Line(1) = {3};
Physical Line(2) = {2};
Physical Line(3) = {4};
Physical Line(4) = {1};