The analysis is done based on the `QTLseqr` library for R.

The low and high **bulk size** should be entered. The bigger the bulk size the lower the probability of false discovery.

The analysis consist of G' ([Magwene et al., 2011](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1002255))
and ∆SNP-index ([Takagi et al., 2013](https://onlinelibrary.wiley.com/doi/full/10.1111/tpj.12105)).

When the analysis is run the following steps are performed:

1. First the number of SNPs within the sliding window are counted.  
2. A tricube-smoothed ∆(SNP-index) is calculated within the set window size.  
3. The minimum read depth at each position is calculated and the tricube-smoothed depth is calculated
for the window.  
4. The simulation is performed for data derived read depths (can be set by the user): Alternate allele
frequency is calculated per bulk based on the population type and size (F2 or RIL) ∆(SNP-index) is
simulated over several replications (default = 10000) for each bulk. The quantiles from the simulations
are used to estimate the confidence intervals. Say for example the 99th quantile of 10000 ∆(SNP-index)
simulations represent the 99% confidence interval for the true data.  
5. Confidence intervals are matched with the relevant window depth at each SNP  


After the statistic is computed seven plots are plotted and data tables are generated.

1. **Raw SNP Index** - Here the raw SNP index values of both bulks are plotted in relation to genome position.  
2. **Raw ∆SNP Index** - Here the raw SNP index difference from both bulks is plotted in relation to genome position.  
3. **Processed SNP density** - Here the number of SNP located inside the moving window is plotted in relation to genome position.  
4. **Processed ∆SNP density** - Here the delta SNP index is calculated for each moving window separately. Additional a Nadaraya-Watson smoothing kernel is utilized to produce tricube-smoothed statistics for analysis. These smoothed statistics function as a weighted moving average across neighboring SNPs that accounts for linkage disequilibrium.  
5. **P value** - Here the _-log<sub>10</sub>Pval_ is plotted in relation to the genome position. Additionally the confidence interval threshold is plotted. If the values are not close to significance the threshold will not be plotted.  
6. **G' distribution** - Here _G'_ values are plotted cumulative. Due to the fact that p-values are estimated from the null distribution of _G'_, an important check is to see if the null distribution of _G'_ values is close to log normally distributed. Plot can inform us of which filtering method (Hampel or DeltaSNP) estimates a more accurate null distribution.  
7. **G' statistics** - Here _G'_ values are plotted in accordance with genome position. Additionally the confidence interval threshold is plotted. If the values are not close to significance the threshold will not be plotted.  
