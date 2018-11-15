# Graffiti-conjecture-143 ALGORITEM

POMOŽNE FUNKCIJE:

```
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
            p.add_constraint(sum([b[Set(e)] for e in edges]) == 2*b[v] )

    return p.solve()

def second_smallest_degree(G):
     stopnje = G.degree_sequence()
     return stopnje[-2]

def tree(G):
    drevesa = set()
    def tree_backtrack(T, S, X):
        velikost = len(T)
        for v in S:
            TT = T + Set([v])
            if TT in drevesa:
                continue
            drevesa.add(TT)
            N = Set(G[v])
            SS = (S ^^ N) - TT - X
            XX = X + (S & N)
            velikost = max(velikost, tree_backtrack(TT, SS, XX))
        return velikost
    return max(tree_backtrack(Set([u]), Set(G[u]), Set()) for u in G)
```

TESTIRANJE DOMNEVE 143 ZA ENOSTAVEN POVEZAN GRAF Z n-VOZLIŠČI:

```
def testiranje_hipoteze(n):
    vsi_EPG = list(graphs.nauty_geng(str(n)+ " -c"))
    for i in range(len(vsi_EPG)):
        if girth(vsi_EPG[i])< oo:
            if tree(vsi_EPG[i]) < (girth(vsi_EPG[i]) + 1)/second_smallest_degree(vsi_EPG[i]):
                return "DOMNEVA JE OVRZENA"
    return "DOMNEVA NI OVRZENA"
```
