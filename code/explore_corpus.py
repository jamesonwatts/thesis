import pickle
with open('resources/btxt1991.pkl', 'r') as f:
    txt = pickle.load(f)



#txt.dispersion_plot(["commercialize","biotech","pharmaceutical"])

#txt.similar("venture")

#txt.collocations(num=75,window_size=20)

txt.concordance("commercialize", width=200)