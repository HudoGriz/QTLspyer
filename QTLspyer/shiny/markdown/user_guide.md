Here is a basic step-by-step guide on how to get **QTL** data.
A detailed description of each step can be found in the windows below.

1. Provide the **input data**.
2. (Optional) Only run **FastQC** to get quality reports. 
3. Run the **Germline short variant discovery** pipeline.
4. Import the data and filter it.
5. Analyse the filtered data.
6. Observe the results and repeat the filtering with different settings if needed.
7. Save the plots and tables.

#### Advanced use cases
That being said, the ability to toggle tools on and off and switching between two workflows allows for great freedom in designing the analysis.   
An example of this is running each tool individually. This is achieved by gradually moving the marking down in **Pipeline steps**. That way each output can be observed and decisions on further tool settings can be made.  
Another example could be running the pipeline without base recalibration if the appropriate `.vcf` for our studied organism is missing. Later on, we can run the pipeline with base recalibration by providing the created `.vcf` as a reference. We can also use a reference `.vcf` file that does not fit perfectly for the first run and iterate from the base recalibration step until convergence.  
The same freedom goes for QTL from variants. We can save `.table` files and import them without the need of running the whole pipeline again. Different annotation files can be combined for gene viewing.
The possibilities this tool presents in the analysis design are vast.
