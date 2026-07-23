# Hierarchical model architecture

## Why subsystems

Simulink subsystems provide the visual black-box architecture required for a
facility model. Each subsystem has explicit inputs and outputs, while the
internal block diagram contains the detailed correlations. This allows one
organ to be replaced without redesigning the complete model.

## Main subsystem contracts

### IT Racks

Inputs:
- load fraction

Outputs:
- IT electrical power, kW
- heat transferred to liquid, kW

### Rack CDU and Internal Loop

Inputs:
- rack heat, kW
- external-loop supply temperature, °C

Outputs:
- heat transferred to external loop, kW
- internal delivered flow, m³/h
- internal pump power, kW
- internal return temperature, °C
- estimated chip temperature, °C

### Facility PG25 Loop

Inputs:
- CDU heat, kW
- tower supply temperature, °C

Outputs:
- tower heat load, kW
- external delivered flow, m³/h
- external pump power, kW
- external return temperature, °C
- external-loop temperature rise, K

### Cooling Tower

Inputs:
- heat load, kW
- external flow, m³/h
- external-loop temperature rise, K
- ambient wet-bulb temperature, °C

Outputs:
- tower supply temperature, °C
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
- facility power, kW
- instantaneous PUE
- simulated facility energy, kWh
- projected 24/7 energy, kWh
- projected electricity cost
- average monthly cost
- period PUE

## Next fidelity increments

1. Replace pressure-drop scaling with individual pipes, valves, manifolds,
   cold plates and heat-exchanger pressure losses.
2. Replace the pump equations with manufacturer pump curves and gas-handling
   maps.
3. Split the total chip-to-coolant resistance into package, TIM, plate and
   convection terms.
4. Replace the tower correlation with tabulated performance versus wet bulb,
   water flow, fan speed and heat load.
5. Add multiple racks and facility-loop branch balancing.
6. Add transient thermal masses and closed-loop temperature control.
