# Data-center direct-to-chip Simulink model

Reduced-order Simulink model generator for a 48U direct-to-chip rack with:

- 1 kW/U rack load, 48 kW maximum
- internal cold-plate liquid loop
- one CDU/heat exchanger per rack
- external PG25 loop
- closed-circuit heat-rejection unit
- internal and external pump power
- cooling-tower fan and spray-pump power
- facility power, energy, and PUE
- entrained-air effects on required flow, pump capacity, pump efficiency, and cold-plate thermal resistance

## Files

```text
build_model.m                         Repository entry point
config/default_parameters.m          Main user-editable parameters
src/build_datacenter_D2C_v2.m        Current model generator
src/build_datacenter_D2C_v1.m        Previous baseline
 docs/aeration_model.md               Aeration assumptions and equations
```

## Build the model

Open MATLAB with this repository as the current folder and run:

```matlab
build_model
```

The script creates:

```text
DataCenter_D2C_Rack_v2.slx
```

Run the generated model with:

```matlab
simOut = sim('DataCenter_D2C_Rack_v2');
```

## Main parameters

Edit `config/default_parameters.m`.

Fluid baseline:

```matlab
nu_external_cSt = 1.95;
rho_external_kg_m3 = 1000;
cp_external_J_kgK = 3980;
k_external_W_mK = 0.49;
```

Aeration:

```matlab
air_void_fraction_internal = 0.02;
air_void_fraction_external = 0.00;
```

Cold-plate resistance:

```matlab
Rth_chip_to_coolant_K_W = 0.020;
```

The resistance is the clean-liquid total chip-to-bulk-coolant resistance for one equivalent cooling path. The aeration model calculates an effective resistance using the configured sensitivity coefficient.

## Important limitations

The current model is a facility-level reduced-order model. It does not yet include:

- physical pump curves
- pipe and fitting geometry
- transient fluid volumes
- detailed heat-exchanger effectiveness
- ambient wet-bulb performance
- water consumption
- air-separator dynamics
- experimentally validated aeration correlations

The aeration derating coefficients are explicit calibration parameters, not universal constants.

## Versioning approach

Treat the MATLAB generator and parameter file as the source of truth. Generated `.slx` models may also be committed after validation, but structural changes should be made in code so they remain reproducible.
