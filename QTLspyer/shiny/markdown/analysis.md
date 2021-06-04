The analysis is based on the `QTLseqr` library for R.

The low and high **bulk size** should be entered. The bigger the bulk size, the lower the probability of false discovery.

The analysis consists of G' ([Magwene et al., 2011](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1002255))
and ∆SNP-index ([Takagi et al., 2013](https://onlinelibrary.wiley.com/doi/full/10.1111/tpj.12105)).

For **∆SNP-index**, the following steps are performed:

1. First, the number of SNPs within the sliding window is counted.  
2. A tricube-smoothed ∆(SNP-index) is calculated within the set window size.  
3. The minimum read depth at each position is calculated, and the tricube-smoothed depth is calculated for the window.  
4. The simulation is performed for data derived read depths  
5. Confidence intervals are matched with the relevant window depth at each SNP  

For **G’**, the following steps are performed:

1. First, the number of SNPs within the sliding window is counted.  
2. A tricube-smoothed ∆(SNP-index) is calculated within the set window size.
3. Genome-wide G statistics are calculated   
4. G’ - A tricube-smoothed G statistic is predicted.  
5. P-values are estimated.  
6. Negative Log10- and Benjamini-Hochberg adjusted p-values are calculated.

For a detailed description please refer to the QTLseqr [vignette](https://github.com/bmansfeld/QTLseqr).



After the significance is estimated, seven plots are plotted and three data tables are generated.

1. **Raw SNP Index** - Here the raw SNP index values of both bulks are plotted in relation to genome position.  
2. **Raw ∆SNP Index** - Here the raw SNP index difference from both bulks is plotted in relation to genome position.  
3. **Processed SNP density** - Here the number of SNP located inside the moving window is plotted in relation to genome position.  
4. **Processed ∆SNP density** - Here the delta SNP index is calculated for each moving window separately. A Nadaraya-Watson smoothing kernel is utilized to produce tricube-smoothed statistics for analysis. These smoothed statistics function as a weighted moving average across neighboring SNPs that accounts for linkage disequilibrium.  
5. **G' distribution** - Here _G'_ values are plotted cumulatively. Because p-values are estimated from the null distribution of _G'_, an important check is to see if the null distribution of _G'_ values is close to log normally distributed. This plot can inform us of which filtering method (Hampel or DeltaSNP) estimates a more accurate null distribution.  
6. **G' statistics** - Here _G'_ values are plotted in accordance with genome position. The confidence interval threshold is plotted. If the values are far from significance, the threshold will not be present. 
7. **P value** - Here the _-log<sub>10</sub>P-val_ is plotted in relation to the genome position. Additionally, the confidence interval threshold is plotted. If the values are far from significance, the threshold will not be present. 


The plots are interactive and can be controlled and downloaded using tools from the toolbar in the top right corner.  
