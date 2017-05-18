This case produced way too many children.

In this version I used roulette wheel sampling, rather than independent random draws. For some reason the roulette wheel approach gives me way too many outages, which doesn't make any sense to me.  Super strange.

Here is a comparison of the real and simulated branching statistics:
---
>> stats_sim.lambda

ans =

  Columns 1 through 12

    0.0016    2.4956    1.2555    0.9074    0.7529    0.6724    0.6323    0.6449    0.5860    0.5218    0.5764    0.4733

  Columns 13 through 21

    0.5513    0.4151    0.2403    0.7568    0.3929    0.9091    0.2000         0         0

>> stats

stats = 

    event_gen_counter_Z: [8383920 13096 14547 8914 3672 3025 2297 1602 695 366 174 90 5 0]
                 lambda: [0.0016 1.1108 0.6128 0.4119 0.8238 0.7593 0.6974 0.4338 0.5266 0.4754 0.5172 0.0556 0 0]
               max_gens: 13
         lambda_overall: 0.0057
---
