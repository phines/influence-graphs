
p = [.25 0 .25 .5];

results = roulette_wheel(p,10000);

hist(results,1:4);
axis([0 4.5 0 6000]);