from pylab import polyfit

xs = [math.log(x) for x in range(1,lim+1)]

lmc = [math.log(y[1]) for y in mc]
        m, b = polyfit(xs,lmc,1)
        