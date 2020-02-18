{
  _config+:: {
    corednsSelector: error 'must provide selector for coredns',
    corednsForwardLatencyCriticalSeconds: 4,
  },
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'coredns_forward',
        rules: [
          {
            alert: 'CoreDNSForwardLatencyHigh',
            expr: |||
              histogram_quantile(0.99, sum(rate(coredns_forward_request_duration_seconds_bucket{%(corednsSelector)s}[5m])) without(instance, %(podLabel)s)) > %(corednsForwardLatencyCriticalSeconds)s
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'CoreDNS has 99th percentile latency of {{ $value }} seconds forwarding requests to {{ $labels.to }}.',
            },
          },
          {
            alert: 'CoreDNSForwardErrorsHigh',
            expr: |||
              sum(rate(coredns_forward_response_rcode_count_total{%(corednsSelector)s,rcode="SERVFAIL"}[5m]))
                /
              sum(rate(coredns_forward_response_rcode_count_total{%(corednsSelector)s}[5m])) > 0.03
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'CoreDNS is returning SERVFAIL for {{ $value | humanizePercentage }} of forward requests to {{ $labels.to }}.',
            },
          },
          {
            alert: 'CoreDNSForwardErrorsHigh',
            expr: |||
              sum(rate(coredns_dns_response_rcode_count_total{%(corednsSelector)s,rcode="SERVFAIL"}[5m]))
                /
              sum(rate(coredns_dns_response_rcode_count_total{%(corednsSelector)s}[5m])) > 0.01
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'CoreDNS is returning SERVFAIL for {{ $value | humanizePercentage }} of forward requests to {{ $labels.to }}.',
            },
          },
        ],
      },
    ],
  },
}
