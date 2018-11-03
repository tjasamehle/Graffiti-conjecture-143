def girth(G):
    if G.cycle_basis() == []:
        return oo
    else:
        p = MixedIntegerLinearProgram(maximization = False)
        b = p.new_variable(binary = True)
        p.set_objective(sum([b[v] for v in G]))
        p.add_constraint(sum([b[v] for v in G]) >= 1)

        for v in G:
            edges = G.edges_incident(v, labels = False)
            p.add_constraint( sum([b[Set(e)] for e in edges]) == 2*b[v] )

    return p.solve()

def second_smallest_degree(G):
     stopnje = G.degree_sequence()
     stopnje.reverse()
     return stopnje[2]

def tree(G):    #ŠE MANJKA


#TESTIRANJE ZA n=6:
vsi_EPG=list(graphs.nauty_geng("6 -c"))  #<-Tukaj ročno nastavljaš n=1,..,7, pri n = 8 je seznam že predolg

for i in range(len(vsi_EPG)):
    if tree(vsi_EPG[i]) < (girth(vsi_EPG[i]) + 1)/second_smallest_degree(vsi_EPG[i]):
        return "DOMNEVA JE OVRŽENA"
return "DOMNEVA NI OVRŽENA"











