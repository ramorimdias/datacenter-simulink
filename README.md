# Data-center D2C Simulink model

Reduced-order Simulink model of a direct-to-chip liquid-cooled data center.
The MATLAB builder generates a visually organized model whose top level is
composed of functional black-box subsystems.

## Top-level architecture

```text
Operating Scenario ---> IT Racks ------------------------------+
                                                               |
Fluid Properties ---> Aeration Model ---> Rack CDU/Internal ---+-->
                                         Loop                       Facility
                                                                    PG25 Loop
                                                                        |
                                                                        v
                                                                  Cooling Tower

Electrical loads -> Facility Energy and Cost -> TCO Financial Model
```

Double-click any subsystem in the generated Simulink model to inspect its
internal correlations, live controls, and numeric displays.

## Interactive controls

The generated model contains Dashboard Slider controls inside:

- **Operating Scenario**: IT-load multiplier and ambient wet-bulb temperature.
- **Fluid Properties**: internal and external specific heat, density, dynamic
  viscosity, and thermal conductivity.
- **Aeration Model**: internal and external free-gas volume fractions.

The sliders tune the connected block parameters during a normal-mode
simulation. Rebuilding the model restores the defaults from
`config/default_parameters.m`.

For interactive tuning, run the model from the Simulink editor. A one-hour
representative simulation can finish too quickly for manual tuning, so use
simulation pacing, pause the simulation, or increase `simulation_time_s` when
exploring controls.

The standard Simulink Display blocks inside the subsystems and on the top-level
canvas show actual numeric signal values during the run and retain the final
value when the simulation stops. All principal signals are also exported as
`Timeseries` variables through To Workspace blocks.

## Fluid Properties block

The block outputs clean-liquid properties as explicit signals for both loops:

```text
Cp                 J/kg/K
Density            kg/m3
Dynamic viscosity  Pa.s
Conductivity       W/m/K
```

The dashboard viscosity input is shown in cP for convenience and converted to
Pa.s before leaving the block.

Property effects in the current reduced-order model:

- `Cp x density` controls required volumetric flow for the selected delta T.
- density and viscosity affect the pressure-drop and pump-power correlation.
- internal-loop thermal conductivity modifies the fluid-side fraction of the
  chip-to-coolant thermal resistance.
- external-loop conductivity is exposed for monitoring and future
  heat-exchanger/tower correlations but is not yet used independently.

## Aeration Model block

`air_void_fraction_internal` and `air_void_fraction_external` represent
entrained free-gas volume fraction, not dissolved gas. The block calculates:

- effective volumetric heat capacity;
- effective mixture density;
- pump flow-capacity derating;
- pump-efficiency derating;
- effective chip-to-coolant thermal resistance.

The clean-liquid thermal resistance is split conceptually into a solid-side and
fluid-side fraction. Only the configured fluid-side fraction scales with
conductivity:

```text
Rth_clean = Rth_reference x [(1-f_fluid) + f_fluid x k_reference/k]
Rth_effective = Rth_clean x (1 + C_aeration x alpha)
```

The derating coefficients are calibration parameters, not universal physical
constants. They should later be replaced with measured pump and cold-plate
maps.

## Excel baseline currently implemented

The default configuration reproduces the colleague baseline where an
assumption was supplied:

- 10 MW IT design load
- 10 K supply-return design temperature difference
- 8760 operating hours per year
- 10-year analysis horizon
- no financial discounting in the default case
- 0.13 currency units/kWh in Year 1
- 3% annual electricity-price escalation
- 2% annual fluid and general-cost escalation
- 4 L of loop fluid per kW of IT load, giving 40,000 L
- 150 currency units/kW water-equivalent CDU and pump CAPEX
- 1.2% of IT load as water-equivalent pump power
- PG25 pump-power multiplier of 1.30
- PG25 CDU and pump CAPEX uplift of 1.08
- PG25 density 1015 kg/m3
- PG25 heat capacity 3.98 kJ/kg/K
- PG25 dynamic viscosity 2.50 cP at approximately 30 degC
- PG25 thermal conductivity 0.49 W/m/K
- PG25 price 3.20 currency units/L
- 5% annual make-up rate
- full replacement every four years
- 8,000 currency units per full-drain disposal event
- 25,000 currency units/year maintenance and monitoring

The hydraulic model is calibrated so that internal plus external PG25 pump
power at the 10 MW design point matches:

```text
10,000 kW x 1.2% x 1.30 = 156 kW
```

Cooling-tower performance and power were not included in the supplied Excel
baseline. Tower parameters remain explicit engineering placeholders in
`config/default_parameters.m` and must later be calibrated against equipment
data.

## Current subsystems

- **Operating Scenario**: IT load, ambient wet-bulb temperature, electricity
  price, operating period, and live scenario controls.
- **Fluid Properties**: separate internal/external fluid properties, sliders,
  unit conversion, and live displays.
- **Aeration Model**: free-gas controls, mixture properties, pump derating, and
  thermal-resistance adjustment.
- **IT Racks**: equivalent 48U rack population, IT power, and liquid heat
  capture.
- **Rack CDU and Internal Loop**: internal flow, pressure drop, pump power, CDU
  approach, and chip-temperature estimate using live upstream signals.
- **Facility PG25 Loop**: external flow, pressure drop, pump power, and return
  temperature using live upstream signals.
- **Cooling Tower**: supply temperature, load and flow corrections, fan power,
  spray-pump power, and capacity margin.
- **Facility Energy and Cost**: facility and cooling power, instantaneous and
  period PUE, annual facility energy, and annual cooling energy.
- **TCO Financial Model**: initial cooling CAPEX and nominal TCO,
  electricity cost, and non-energy OPEX over the configured horizon.

## Build the visual model

1. Clone or download this repository.
2. Open MATLAB in the repository root.
3. Edit `config/default_parameters.m`.
4. Run:

```matlab
clear functions
rehash
build_model
```

This creates the model named by the `model` variable, currently:

```text
DataCenter_D2C_Interactive_TCO_v5.slx
```

Run the generated model:

```matlab
simOut = sim('DataCenter_D2C_Interactive_TCO_v5');
```

For live tuning, open the generated model, double-click the required subsystem,
and run from the Simulink editor.

## Run the complete TCO analysis

The recommended reproducible financial workflow is:

```matlab
results = run_analysis;
```

This command:

1. builds the Simulink model;
2. runs the representative simulation with the configured default parameters;
3. annualizes facility and cooling energy using exactly 8760 h/year;
4. calculates annual nominal cash flows;
5. applies electricity and general-cost escalation;
6. schedules make-up, maintenance, full fluid replacement, and disposal;
7. reports configurable milestones such as Year 5 and Year 10;
8. exports CSV and MAT results.

Dashboard changes made manually during a prior interactive run are not treated
as persistent TCO assumptions. To make a case reproducible, write the selected
values into `config/default_parameters.m` before running `run_analysis`.

Generated result files:

```text
results/tco_yearly_cashflow.csv
results/tco_milestones.csv
results/tco_results.mat
```

Key MATLAB outputs:

```matlab
tco_results.tco_summary
tco_results.milestone_summary
tco_yearly_cashflow
tco_milestones
```

## TCO boundaries

Two TCO values are intentionally reported:

- **Facility TCO** includes all facility electricity, including IT energy,
  plus cooling CAPEX and non-energy cooling OPEX.
- **Cooling TCO** includes cooling electricity only, plus cooling CAPEX,
  fluid, maintenance, replacement, and disposal.

The cooling TCO is generally the more useful metric for comparing fluids or
cooling technologies because the IT electricity load is common to all cases.

The current CAPEX boundary includes CDU and pump equipment plus the initial
fluid fill. Tower CAPEX, building CAPEX, IT equipment, financing, taxes, water
consumption, and residual value are not yet included because no assumptions
were supplied for them.

## Model fidelity

This is a broad-scope reduced-order model. The subsystem interfaces are
intended to remain stable while internal correlations are progressively
replaced by Simscape Fluids components, pump maps, heat-exchanger data, and
cooling-tower performance maps.
