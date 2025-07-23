# Heat Flow Modeling

### Overview ###
Initially created for a class, Nanomanufacturing for Sustainability, to analyze the heat dissipation properties of a film of material. I built on the code to allow for simulating multiple materials in parallel. The parallelization is achieved through MATLAB's Parallel Computing Toolbox. 

The code itself numerically solves a system of differential equations to calculate the temperature a film of material will settle at given a set of conditions like solar irradiance, the material's properties, the ambient temperature, etc.  

Below is a picture of the equations used.

<img width="696" height="321" alt="image" src="https://github.com/user-attachments/assets/24528561-5b37-4ec7-9de8-38089072971f" />

### Explanation ###
The first three equations define methods of energy flow into the material: solar radiation, conduction and convection, and atmospheric radiation(i.e. the energy flow from the ambient air). The fourth equation defines the heat radiated out by the material. To solve for the stable temperature, the code numerically solves for the point where the energy flow out equals the energy flow in, allowing us to guage how cool the material can stay.

