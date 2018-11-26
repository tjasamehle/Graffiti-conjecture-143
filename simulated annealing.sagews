︠62bbfc3a-3a09-4dae-a5a3-5913b337ad68︠
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

# # PROTIPRIMER: SIMULATED ANNEALING

import random
import operator

def generateFirstGraph(n):
    sez = []
    while len(sez) < 1:
        osebek = graphs.RandomGNP(n, random.uniform(0, 1))
        if osebek.is_connected():
            if girth(osebek) < oo:
                sez.append(osebek)
    return osebek

def fitness(osebek):
    return tree(osebek) - (girth(osebek) + 1)/second_smallest_degree(osebek)

def poisson(t = 1, lambd = 1/2):
    N = 0
    S = 0
    while S < t:
        N += 1
        S += random.expovariate(lambd)
    return N

def mutation(osebek):
    prob = random.uniform(0, 1)
    plus_povezave = poisson(lambd = 1/2)
    minus_povezave = poisson(lambd = 1/2)
    if prob <= 1/3:
        for k in range(plus_povezave):
            a, b = osebek.random_vertex(), osebek.random_vertex()
            if a != b:
                osebek.add_edge(a, b)
    elif prob > 1/3 and prob <= 2/3:
        for k in range(minus_povezave):
            a, b = osebek.random_vertex(), osebek.random_vertex()
            osebek.delete_edge(a, b)
            if not osebek.is_connected():
                osebek.add_edge(a, b)
            if girth(osebek) == oo:
                    osebek.add_edge(a, b)
    elif prob > 2/3:
        for k in range(plus_povezave):
            a, b = osebek.random_vertex(), osebek.random_vertex()
            if a != b:
                osebek.add_edge(a, b)
        for k in range(minus_povezave):
            a, b = osebek.random_vertex(), osebek.random_vertex()
            osebek.delete_edge(a, b)
            if not osebek.is_connected():
                    osebek.add_edge(a, b)
            if girth(osebek) == oo:
                    osebek.add_edge(a, b)
    return osebek

def cooling_schedule(temperatura):
    ntemperatura = 1 + random.uniform(0,1/2)
    temperatura = temperatura/ntemperatura
    return temperatura

def acceptance_P(E_osebek,E_sosed,T):
    if E_sosed > E_osebek:
        p = e^(-(E_sosed - E_osebek)/T)
    else:
        p = 1
    return p



def hill_climbing(n,maxsteps):
    osebek = generateFirstGraph(n)
    T = 3/2
    k = 0
    while k < maxsteps:
        k = k+1
        sosed = mutation(osebek)
        sosed.remove_loops()
        E_osebek = fitness(osebek)
        E_sosed = fitness(sosed)
        if E_sosed < 0:
            return (sosed, "mozni protiprimer")
        if acceptance_P(E_osebek, E_sosed, T) >= random.uniform(0, 1):
            osebek = sosed
            T = cooling_schedule(T)
    return (osebek, fitness(osebek))









