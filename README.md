simmer.json
================

> This is an experimental package. The R and JSON syntax can still change significantly.

This package allows to read in a JSON object and translate it into a simmer environment. See below for an example definition:

``` r
library(simmer.json)

my_JSON<-'{
  "env": {
    "resources": {
      "nurse": {
        "capacity": 1
      }
    },
    "generators": {
      "patients": {
        "trajectory": "t1",
        "dist": "%at(0,0,0)%"
      }
    }
  },
  "trajectories": {
    "t1": [
      {
        "activity": "seize",
        "resource": "nurse"
      },
      {
        "activity": "timeout",
        "task": "%3%"
      },
      {
        "activity": "release",
        "resource": "nurse"
      }
    ]
  }
}
'
```

You can translate this into simmer using:

``` r
library(simmer.json)
env<-
  deserialise(my_JSON)

env
```

    ## simmer environment: anonymous | now: 0 | next: 0
    ## { Resource: nurse | monitored: 1 | server status: 0(1) | queue status: 0(Inf) }
    ## { Generator: patients | monitored: 1 | n_generated: 1 }

And run the environment:

``` r
env %>%
  run()
```

    ## simmer environment: anonymous | now: 9 | next: 
    ## { Resource: nurse | monitored: 1 | server status: 0(1) | queue status: 0(Inf) }
    ## { Generator: patients | monitored: 1 | n_generated: 3 }
