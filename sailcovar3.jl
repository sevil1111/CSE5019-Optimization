using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, Inc[1:4] >= 0)
@variable(m, Dec[1:4] >= 0)  
@variable(m, hInc[1:4] >= 0)
@variable(m, hDec[1:4] >= 0)  

@constraint(m, hInc[4]>=10)
@constraint(m, hDec[4]<=0) 
@constraint(m, x[1]+y[1]-50== Inc[1]+Dec[1])
@constraint(m, flow1[i in 2:4], x[i]+y[i]-(x[i-1]+y[i-1])==Inc[i]+Dec[i])     # conservation of boats
@constraint(m, 10+x[1]+y[1]-40== hInc[1]-hDec[1])
@constraint(m, flow2[i in 2:4], hInc[i-1]-hDec[i-1]+x[i]+y[i]-d[i]==hInc[i]+hDec[i])     # conservation of boats

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hInc)+400*sum(Inc)+500*sum(Dec)+100*sum(hDec))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))

@printf("Objective cost: %f\n", objective_value(m))