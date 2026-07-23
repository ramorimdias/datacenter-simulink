# Excel baseline mapping

This document records how the colleague Excel assumptions are represented in
the Simulink and MATLAB TCO model.

## Direct mappings

| Excel assumption | Model parameter |
|---|---|
| IT load, 10 MW | `facility_IT_load_kW = 10000` |
| Design supply-return delta T, 10 C | `design_deltaT_K = 10` |
| Operating hours/year, 8760 | `operating_hours_per_year = 8760` |
| Analysis horizon, 10 years | `analysis_horizon_years = 10` |
| Discount rate, 8% | `discount_rate_annual = 0.08` |
| Electricity price Year 1, 0.13/kWh | `electricity_price_year1_per_kWh = 0.13` |
| Electricity escalation, 3% | `electricity_price_escalation_annual = 0.03` |
| General escalation, 2% | `fluid_general_cost_escalation_annual = 0.02` |
| Loop volume, 4 L/kW | `loop_fluid_volume_factor_L_per_kW = 4` |
| Water-equivalent CDU/pump CAPEX, 150/kW | `baseline_CDU_pump_CAPEX_per_kW_IT = 150` |
| Water-equivalent pump power, 1.2% IT | `baseline_pump_power_fraction_of_IT = 0.012` |
| PG25 pump multiplier, 1.30 | `pumping_power_multiplier_vs_water = 1.30` |
| PG25 equipment CAPEX uplift, 1.08 | `CDU_pump_CAPEX_uplift_vs_water = 1.08` |
| PG25 unit price, 3.20/L | `fluid_unit_price_year1_per_L = 3.20` |
| Annual make-up, 5% | `annual_makeup_loss_fraction = 0.05` |
| Replacement interval, 4 years | `full_replacement_interval_years = 4` |
| Disposal per drain, 8,000 | `disposal_cost_per_full_drain_year1 = 8000` |
| Maintenance, 25,000/year | `annual_maintenance_monitoring_year1 = 25000` |

## Derived baseline checks

At 10 MW:

```text
Total loop volume = 10,000 kW x 4 L/kW = 40,000 L
Water pump power = 10,000 kW x 1.2% = 120 kW
PG25 pump target = 120 kW x 1.30 = 156 kW
Water-equivalent equipment CAPEX = 10,000 kW x 150 = 1,500,000
PG25 equipment CAPEX = 1,500,000 x 1.08 = 1,620,000
Initial fluid fill = 40,000 L x 3.20/L = 128,000
Initial cooling CAPEX including fluid = 1,748,000
Annual make-up volume = 40,000 L x 5% = 2,000 L
```

The clean-fluid hydraulic correlations are calibrated to 156 kW at full load.
The calibration is fixed at zero free-gas content. Aeration therefore increases
pump power instead of being cancelled by recalibration.

## Replacement convention

Full fluid replacement is charged at the end of Years 4, 8, 12, and so on.
For a 10-year horizon, replacement and disposal occur in Years 4 and 8.
Annual make-up and maintenance are also charged in replacement years.

## Escalation and discount convention

- Electricity price escalates by 3% at the start of each operating year.
- Fluid, make-up, maintenance, replacement, and disposal costs escalate by 2%.
- Operating cash flows are treated as end-of-year costs.
- Initial equipment and fluid-fill CAPEX is a Year 0 cost.
- Discounted TCO is the sum of Year 0 CAPEX and discounted annual cash flows.

## TCO boundaries

### Facility TCO

Includes:

- CDU and pump CAPEX uplift
- initial fluid fill
- all facility electricity, including IT power
- make-up fluid
- maintenance and monitoring
- scheduled full replacement
- disposal

### Cooling TCO

Includes the same cooling CAPEX and non-energy OPEX, but only cooling-system
electricity. This is the preferred boundary for comparisons between fluids or
cooling technologies because the IT electricity load is common.

## Excluded until assumptions are supplied

- cooling-tower CAPEX
- building and civil works
- IT equipment CAPEX
- water consumption and water treatment
- taxes and insurance
- financing fees
- residual value
- unplanned downtime and reliability costs
- labor outside the supplied annual maintenance value
