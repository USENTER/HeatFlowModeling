# Heat Flow Modeling

### Overview ###
Initially created for a class, Nanomanufacturing for Sustainability, to analyze the heat dissipation properties of a film of material. I built on the code to allow for simulating multiple materials in parallel. The parallelization is achieved through MATLAB's Parallel Computing Toolbox. 


The code itself numerically solves a system of differential equations to calculate the temperature a film of material will settle at given a set of conditions like solar irradiance, the material's properties, the ambient temperature, etc. It also creates graphs to help visualize the effect of I_ES(solar irradiance) on the cooling effects. An example graph is available.


### Explanation ###
Below is a picture of the equations used.

<img width="696" height="321" alt="image" src="https://github.com/user-attachments/assets/24528561-5b37-4ec7-9de8-38089072971f" />

The first three equations define methods of energy flow into the material: solar radiation, conduction and convection, and atmospheric radiation(i.e. the energy flow from the ambient air). The fourth equation defines the heat radiated out by the material. To solve for the stable temperature, the code numerically solves for the point where the energy flow out equals the energy flow in, allowing us to guage how cool the material can stay.


### Running the Code and Performance Analysis###

You can run this in MATLAB after adding the Parallel Compute Toolbox add-on. `heatFlowModeling.m` runs both serial and parallel versions of the code to compare the two. The Parallel and Serial files have been configured with 10 random materials, but you can manipulate the variables yourself to work with specific numbers materials and properties. Note that under a certain number of materials, the serial version outperforms because the overhead for parallel threads is too high. 

A basic test with 4 arbitrary materials shows that the overhead of parallelization outweighs the gains(this is on first startup, so overhead for starting pool itself is included):

```
Elapsed time (serial):   494.232 seconds
Elapsed time (parallel): 784.340 seconds
```

If the pool of workers already exists:

```
Elapsed time (serial):   533.974 seconds
Elapsed time (parallel): 609.408 seconds
```

With 10 materials, and the pool already existing: 
```
Elapsed time (serial):   1173.839 seconds
Elapsed time (parallel): 914.769 seconds
```

So depending on the number of materials you want to simulate, you may want to choose the serial version over the parallel version.
