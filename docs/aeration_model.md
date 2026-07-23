# Entrained-air model

## Definition

`air_void_fraction_internal` and `air_void_fraction_external` represent the volumetric fraction of entrained free gas in the flowing mixture.

- `0.00` means no entrained free gas.
- `0.02` means 2 vol.% free gas.
- The model is not intended for dissolved gas below the bubble-release threshold.

## Thermal transport

The effective volumetric heat capacity is calculated as:

```text
(rho cp)_mix = (1-alpha) rho_liquid cp_liquid
             + alpha rho_air cp_air
```

Required delivered mixture flow is then:

```text
Vdot = Q / ((rho cp)_mix DeltaT)
```

Because air has very low volumetric heat capacity relative to the liquid, increasing `alpha` increases the required delivered volume flow.

## Pump capacity

The current broad-scope model uses an empirical capacity factor:

```text
capacity_factor = max(minimum_factor, 1 - C_flow alpha)
```

The pump-equivalent flow used for hydraulic power is:

```text
Vdot_pump_equivalent = Vdot_delivered / capacity_factor
```

This represents the additional pump duty required to maintain the demanded delivered flow when free gas reduces pump capacity.

## Pump efficiency

The effective pump efficiency is:

```text
eta_effective = eta_clean max(minimum_fraction, 1 - C_eta alpha)
```

The coefficients are calibration parameters. They must ultimately be fitted to pump test data, supplier maps, or facility measurements.

## Thermal resistance

The cold-plate path uses:

```text
Rth_effective = Rth_clean (1 + C_Rth alpha)
```

This is an empirical first-order representation of reduced wetted area, gas blanketing, maldistribution, and degraded convective transfer. It is not a universal correlation.

## Next fidelity step

Replace the empirical relationships with measured maps or lookup tables:

- pump head correction versus gas fraction and flow
- pump efficiency versus gas fraction and flow
- cold-plate thermal resistance versus gas fraction and flow
- separator or degassing dynamics
- time-dependent gas ingestion and release
