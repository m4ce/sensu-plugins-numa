# Sensu plugin for monitoring NUMA

A sensu plugin to monitor whether NUMA is supported and enabled.

## Usage

The plugin accepts the following command line options:

```
Usage: check-numa.rb (options)
    -w, --warn                       Warn instead of throwing a critical failure
        --ignore-virtual             Ignore NUMA on virtualized hardware
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
