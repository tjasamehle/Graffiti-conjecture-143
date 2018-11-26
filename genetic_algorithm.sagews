︠89769f2e-f23a-4fe3-995d-d84e2a08371c︠
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


# PROTIPRIMER: GENETIC ALGORITHM

# N(t) ~ Poiss(lambda*t)
# N(1) ~ Poiss(lambda)
# N(t) = sum_{k=0...} Ind_{S_k <= t}
# S_k = sum_{i=0,...,k} T_i; T_i ~ Exp(lambda)
# poissonova porazdelitev iz eksponentne

def poisson(t = 1, lambd = 1/2):
    N = 0
    S = 0
    while S < t:
        N += 1
        S += random.expovariate(lambd)
    return N


# začetna generacija
# n = število vozlišč
# pop_size = velikost vsake populacije

def generateFirstPopulation(pop_size, n):
    populacija = []
    i = 0
    while i < pop_size:
        osebek = graphs.RandomGNP(n, random.uniform(0, 1))
        if osebek.is_connected():
            if girth(G) < oo:
                populacija.append(osebek)
                i += 1
    return populacija


# manjši fitnes = boljši graf
def fitness(G):
    return tree(G) - (girth(G) + 1)/second_smallest_degree(G)


def fitnessPopulation(populacija):
    sez = []
    for osebek in populacija:
        sez.append(fitness(osebek))
    return sez

def sortPopulation(populacija):
    slovar = {}
    i = 0
    for osebek in populacija:
        slovar[i] = fitness(osebek)
        i += 1
    sortirana = sorted(slovar.items(), key = operator.itemgetter(1))
    nova_populacija = []
    for osebek in sortirana:
        nova_populacija.append(populacija[osebek[0]])
    return nova_populacija


# prvih 'best' je del nove populacije, nekaj 'lucky' je tudi del nove populacije
# best + lucky = velikost populacije
def selectPopulation(populacija, best):
    lucky = pop_size - best
    nova_populacija = []
    sortirana = sortPopulation(populacija)
    for k in range(best):
        nova_populacija.append(sortirana[k])
    srecnezi = random.sample(populacija, k = lucky)
    for osebek in srecnezi:
        nova_populacija.append(osebek)
    random.shuffle(nova_populacija)
    return nova_populacija

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
            if girth(G) == oo:
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
            if girth(G) == oo:
                    osebek.add_edge(a, b)
    return osebek

def mutatePopulation(populacija, p = 5/100):
    nova_populacija = []
    for k in range(len(populacija)):
        rnd = random.random()
        if rnd < p:
            nova_populacija.append(mutation(populacija[k]))
        else:
            nova_populacija.append(populacija[k])
    return nova_populacija


# osebka imata samo enega potomca
# n = število vozlišč

def crossover(n, osebek1, osebek2):
    while True:
        subgraf1 = osebek1.random_subgraph(0.5) 
        subgraf2 = osebek2.random_subgraph(0.5)
        if len(subgraf1.vertices()) + len(subgraf2.vertices()) == n and len(subgraf1.vertices()) >= 1 and len(subgraf1.vertices()) < n and subgraf1.is_connected() and subgraf2.is_connected():
            subgraf1.relabel()
            subgraf2.relabel()
            potomec = subgraf1.disjoint_union(subgraf2)
            nove_povezave = poisson(lambd = log(n/2))
            for k in range(nove_povezave):
                a = subgraf1.random_vertex()
                b = subgraf2.random_vertex()
                potomec.add_edge((0, a), (1, b))
            potomec.relabel()
            break
    return potomec


# stara generacija + potomci
# successful have more chance to mate

def offspringPopulation(populacija):
    #utezi = []
    #M = max(fitnessPopulation(populacija))
    nova_populacija = populacija
    stevilo_parjenj = poisson(t = pop_size)
    for k in range(stevilo_parjenj):
        starsa = random.sample(populacija, k = 2)
        nova_populacija.append(crossover(n, starsa[0], starsa[1]))
    return nova_populacija


# n = število vozlišč
# pop_size = velikost populacije
# best = koliko najboljših izberemo za reprodukcijo

def testGA(n, pop_size, best, stevilo_generacij):
    populacija = generateFirstPopulation(pop_size, n)
    populacija = selectPopulation(populacija, best)
    fitnes = fitnessPopulation(populacija)
    fitnes.sort()
    print(fitnes)
    i = 1
    while i <= stevilo_generacij:
        populacija = offspringPopulation(populacija)
        populacija = mutatePopulation(populacija)
        populacija = selectPopulation(populacija, best)
        fitnes = fitnessPopulation(populacija)
        fitnes.sort()
        print(fitnes)
        if min(fitnes) < 0:
            print("DOMNEVA JE OVRZENA")
            show(sortPopulation(populacija)[0])
            resitev = sortPopulation(populacija)[0]
            resitev = resitev.to_dictionary()
            return resitev
        i += 1
    return "DOMNEVA NI OVRZENA"









