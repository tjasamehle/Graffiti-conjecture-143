︠b6674002-5e49-4c4e-a93f-d19b2bb143b3︠
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


#TESTIRANJE DOMNEVE 143 ZA ENOSTAVNEN POVEZAN GRAF Z n-VOZLIŠČI:
def testiranje_hipoteze(n):
    vsi_EPG = list(graphs.nauty_geng(str(n)+ " -c"))
    for i in range(len(vsi_EPG)):
        if girth(vsi_EPG[i])< oo:
            if tree(vsi_EPG[i]) < (girth(vsi_EPG[i]) + 1)/second_smallest_degree(vsi_EPG[i]):
                return "DOMNEVA JE OVRZENA"
    return "DOMNEVA NI OVRZENA"



testiranje_hipoteze(1)
︡33a039ed-5b5d-417e-a9cf-1294b4c430d0︡{"stdout":"'DOMNEVA NI OVRZENA'\n"}︡{"done":true}︡
︠3490b27e-aefb-440d-a9a2-02df8019f515︠
testiranje_hipoteze(2)
︡f1edb701-29f1-4b1d-9a93-29efc987d7b5︡{"stdout":"'DOMNEVA NI OVRZENA'\n"}︡{"done":true}︡
︠439f80bb-5408-408e-9287-13a419de120c︠
testiranje_hipoteze(3)
︡9c42b109-d9a8-465d-b427-d1fe98395353︡{"stdout":"'DOMNEVA NI OVRZENA'"}︡{"stdout":"\n"}︡{"done":true}︡
︠e920b24a-569d-456d-99ef-ceac8bbcaf02︠
testiranje_hipoteze(4)
︡5ac164bf-5f8b-4672-b179-c024f84fcc03︡{"stdout":"'DOMNEVA NI OVRZENA'"}︡{"stdout":"\n"}︡{"done":true}︡
︠1068314b-990e-464c-ae98-669cc3b072da︠
testiranje_hipoteze(5)
︡d10d2649-39f5-41a9-b82f-dbab0dde9c49︡{"stdout":"'DOMNEVA NI OVRZENA'"}︡{"stdout":"\n"}︡{"done":true}︡{"stdout":"\n"}︡{"done":true}︡
︠39c28d31-69cb-4b33-9c55-200ceea4b594︠
testiranje_hipoteze(6)
︡38f617e8-f805-4f48-8585-da1569c6be03︡{"stdout":"'DOMNEVA NI OVRZENA'"}︡{"stdout":"\n"}︡{"done":true}︡
︠1e951289-3560-4614-9906-e39689cf1a64︠
testiranje_hipoteze(7)
︡1a95716e-0577-4239-8d90-fa0c753c335b︡{"stdout":"'DOMNEVA NI OVRZENA'"}︡{"stdout":"\n"}︡{"done":true}︡










