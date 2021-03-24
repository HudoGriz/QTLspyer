Here is a basic step-by-step guide on how to obtain **QTL** data.
In detail description of each step can be found in the windows bellow.

1.  Provide the **input data**.
2.  (Optional) Only run **FastQC** to obtain quality reports. 
3.  Run the **Germline short variant discovery** pipeline.
4.  Import the data and filter it.
5.  Analyse the filtered data.
6.  Observe the results and repeat the filtering with different settings if needed.
7.  Save the plots and tables.

#### Advanced use cases
That being said, the ability of toggling tools on and of and switching between two workflows allows for great freedom in designing the analysis.   
§ An example of this is running each tool individually. This is achieved by gradually mowing the marking down in **Pipeline steps**. That way each output can be observed and base our decision on further tool settings.  
Another example could be in running the pipeline without base recalibration if we are missing the appropriate `.vcf` for our studied organism. Later on we can run the pipeline with base recalibration by providing the previously obtained `.vcf` as reference. We can also use a reference `.vcf` file that does not fit perfectly for the first run and iterate from the base recalibration step until convergence.  
The same freedom goes for QTL from variants. We can save `.table` files and import them without the need of running the whole pipeline again. Different annotation files can be combined for gene viewing.
All in all the possibilities this tool presents in the analysis design are vast.
