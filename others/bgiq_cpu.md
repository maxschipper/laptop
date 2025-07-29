---
id: bgiq
created_at:
  date: 2025-07-26
  time: 15:28
tags:
  - note
---
# cpu
tlp or auto-cpufreq. For an AMD Ryzen system, auto-cpufreq is often a great choice.
```nix
services.auto-cpufreq.enable = true;
```

# power states
- C0: The active state (CPU is executing instructions).
- C1, C2, C3...: Progressively deeper sleep states. Higher numbers mean more power savings but also a longer latency to return to the C0 state.
- "Deep sleep" generally refers to C-states beyond C1, like C3, C6, C7, etc. These states offer significant power savings by turning off more components of the CPU.

## cpupower command
> This command gives you a table of available C-states, their names, descriptions, and the time spent in each state for each CPU core. This is often the easiest way to get a comprehensive overview.
>
>>`cpupower`
>>`cpupower idle-states`

## turbostat

`turbostat`
`sudo turbostat --quiet --show PkgWatt,CorWatt,GFXWatt,Pkg_J,Cor_J,GFX_J,C1%,C2%`

# powermetrics
- gives a lot of detail about powerconsumption in general
- also cpu state
- but static info

`ls /sys/devices/system/cpu/cpu0/cpuidle/` linux only
