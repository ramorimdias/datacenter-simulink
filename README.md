# Data-center D2C Simulink model

Reduced-order Simulink model of a direct-to-chip liquid-cooled data center.
The MATLAB builder generates a visually organized model whose top level is
composed of functional black-box subsystems.

## Top-level architecture

```text
Operating Scenario
        |
        v
     IT Racks
        |
        v
Rack CDU + Internal Loop
        |
        v
 Facility PG25 Loop
        |
        v
   Cooling Tower

All electrical loads feed Facility Energy and Cost.
The cooling-tower supply temperature feeds both liquid loops.
```

Double-click any subsystem in the generated Simulink model to inspect its
internal correlations.

## Current subsystems

- **Operating Scenario**: IT load profile, ambient wet-bulb temperature,
  electricity price and operating months.
- **IT Racks**: rack count, 48U rack load and liquid heat-capture fraction.
- **Rack CDU and Internal Loop**: internal flow, aeration derating, pressure
  drop, pump power, CDU approach and chip-temperature estimate.
- **Facility PG25 Loop**: external flow, pressure drop, pump power and return
  temperature.
- **Cooling Tower**: supply temperature, load and flow corrections, fan power,
  spray-pump power and capacity margin.
- **Facility Energy and Cost**: facility power, instantaneous and period PUE,
  simulated energy, projected 24/7 energy and electricity cost.

## Run

1. Clone or download this repository.
2. Open MATLAB in the repository root.
3. Edit `config/default_parameters.m`.
4. Run:

```matlab
build_model
```

This creates:

```text
DataCenter_D2C_Hierarchical_v3.slx
```

Run the generated model:

```matlab
simOut = sim('DataCenter_D2C_Hierarchical_v3');
```

Inspect the final results:

```matlab
P_facility_kW.Data(end)
PUE_period.Data(end)
E_projected_kWh.Data(end)
projected_cost.Data(end)
average_monthly_cost.Data(end)
```

## Cost projection

The simulation profile is treated as a representative repeated profile.
The model calculates:

```text
Projected operating hours = months × 365.25/12 × 24
Projected energy = simulated energy × projected hours / simulation hours
Projected cost = projected energy × electricity price per kWh
```

The cost output uses the same currency unit used for
`electricity_price_per_kWh`.

## Aeration model

`air_void_fraction_internal` and `air_void_fraction_external` represent
entrained free-gas volume fraction, not dissolved gas. Aeration currently:

- lowers effective volumetric heat capacity;
- increases the delivered flow required for the same heat and temperature rise;
- derates pump flow capacity;
- derates pump efficiency;
- increases the effective chip-to-coolant thermal resistance.

The derating coefficients are calibration parameters and should later be
replaced with measured pump and cold-plate data.

## Model fidelity

This is a broad-scope reduced-order model. The subsystem interfaces are
intended to remain stable while internal correlations are progressively
replaced by Simscape Fluids components, pump maps, heat-exchanger data and
cooling-tower performance maps.
