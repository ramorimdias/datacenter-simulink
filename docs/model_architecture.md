# Hierarchical model architecture

## Why subsystems

Simulink subsystems provide the visual black-box architecture required for a
facility model. Each subsystem has explicit inputs and outputs, while the
internal block diagram contains the detailed correlations. This allows one
organ to be replaced without redesigning the complete model.

The model now separates **clean-liquid properties** from **aeration effects**.
Both are explicit upstream blocks, so their output signals are visible and can
be consumed by several physical organs.

## Main subsystem contracts

### Operating Scenario

Outputs:

- IT load fraction
- ambient wet-bulb temperature, degC
- flat electricity price per kWh
- operating months

Interactive controls:

- IT-load multiplier
- ambient wet-bulb temperature

### Fluid Properties

Outputs for both internal and external loops:

- specific heat, J/kg/K
- density, kg/m3
- dynamic viscosity, Pa.s
- thermal conductivity, W/m/K

The properties originate from tunable Constant blocks. Dashboard Sliders can
change their values during a normal-mode simulation. The dashboard viscosity
value is entered in cP and converted to Pa.s before leaving the subsystem.

### Aeration Model

Inputs:

- internal specific heat, density, and conductivity
- external specific heat and density

Tunable parameters:

- internal free-gas volume fraction
- external free-gas volume fraction

Outputs:

- internal and external free-gas fractions
- effective volumetric heat capacities, J/m3/K
- effective mixture densities, kg/m3
- internal and external pump flow-capacity factors
- internal and external pump-efficiency factors
- effective chip-to-coolant thermal resistance, K/W

The block distinguishes free gas from dissolved gas. Its empirical derating
coefficients are calibration inputs.

### IT Racks

Inputs:

- load fraction

Outputs:

- IT electrical power, kW
- heat transferred to liquid, kW

### Rack CDU and Internal Loop

Inputs:

- rack heat, kW
- external-loop supply temperature, degC
- effective internal volumetric heat capacity, J/m3/K
- effective internal density, kg/m3
- internal dynamic viscosity, Pa.s
- pump flow-capacity factor
- pump-efficiency factor
- effective chip-to-coolant thermal resistance, K/W

Outputs:

- heat transferred to external loop, kW
- internal delivered flow, m3/h
- internal pump power, kW
- internal return temperature, degC
- estimated chip temperature, degC

### Facility PG25 Loop

Inputs:

- CDU heat, kW
- tower supply temperature, degC
- effective external volumetric heat capacity, J/m3/K
- effective external density, kg/m3
- external dynamic viscosity, Pa.s
- pump flow-capacity factor
- pump-efficiency factor

Outputs:

- tower heat load, kW
- external delivered flow, m3/h
- external pump power, kW
- external return temperature, degC
- external-loop temperature rise, K

### Cooling Tower

Inputs:

- heat load, kW
- external flow, m3/h
- external-loop temperature rise, K
- ambient wet-bulb temperature, degC

Outputs:

- tower supply temperature, degC
- total tower electrical power, kW
- fan power, kW
- spray-pump power, kW
- capacity margin, kW

### Facility Energy and Cost

Inputs:

- IT power, kW
- internal pump power, kW
- external pump power, kW
- tower power, kW
- electricity price per kWh
- operating months

Outputs:

- facility and cooling power, kW
- instantaneous and period PUE
- simulated facility energy, kWh
- projected and annualized energy, kWh
- flat-price projected electricity cost

### TCO Financial Model

Inputs:

- annual facility energy, kWh
- annual cooling energy, kWh

Outputs:

- initial cooling CAPEX
- nominal and discounted facility TCO
- nominal and discounted cooling TCO
- discounted facility and cooling electricity costs
- discounted non-energy OPEX

## Interactive operation

Dashboard Sliders change tunable block parameters during normal-mode
simulation. Standard Simulink Display blocks are connected to the main signals
inside each subsystem and at the top level, so they show numeric values during
the run and retain the final values after the simulation stops.

For reproducible TCO cases, save selected values in
`config/default_parameters.m` and run `run_analysis`. Manual dashboard changes
are intended for exploration and are reset when the model is rebuilt.

## Next fidelity increments

1. Replace pressure-drop scaling with individual pipes, valves, manifolds,
   cold plates, and heat-exchanger pressure losses.
2. Replace the pump equations with manufacturer pump curves and gas-handling
   maps.
3. Split the total chip-to-coolant resistance into package, TIM, plate, and
   convection terms using measured or CFD-derived coefficients.
4. Replace the tower correlation with tabulated performance versus wet bulb,
   fluid flow, fan speed, and heat load.
5. Add multiple rack branches and facility-loop balancing.
6. Add transient fluid volumes, thermal masses, and closed-loop temperature
   control.
