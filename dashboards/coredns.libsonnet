local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;

{
  _config+:: {
    corednsSelector: 'k8s_app="kube-dns"',
  },

  grafanaDashboards+:: {
    'coredns.json':
      local upCount =
        singlestat.new(
          'Up',
          datasource='$datasource',
          span=2,
          valueName='min',
        )
        .addTarget(prometheus.target('sum(up{%(corednsSelector)s})' % $._config));

      local rpcRate =
        graphPanel.new(
          'RPC Rate',
          datasource='$datasource',
          span=5,
          format='ops',
        )
        .addTarget(prometheus.target('sum(rate(coredns_dns_response_rcode_count_total{%(corednsSelector)s,instance=~"$instance"}[5m])) by (rcode)' % $._config, legendFormat='{{rcode}}'));

      local requestDuration =
        graphPanel.new(
          'Request duration 99th quantile',
          datasource='$datasource',
          span=5,
          format='s',
          legend_show=true,
          legend_values=true,
          legend_current=true,
          legend_alignAsTable=true,
          legend_rightSide=true,
        )
        .addTarget(prometheus.target('histogram_quantile(0.99, sum(rate(coredns_dns_request_duration_seconds_bucket{%(corednsSelector)s,instance=~"$instance"}[5m])) by (server, zone, le))' % $._config, legendFormat='{{server}} {{zone}}'));


      local memory =
        graphPanel.new(
          'Memory',
          datasource='$datasource',
          span=4,
          format='bytes',
        )
        .addTarget(prometheus.target('process_resident_memory_bytes{%(corednsSelector)s,instance=~"$instance"}' % $._config, legendFormat='{{instance}}'));

      local cpu =
        graphPanel.new(
          'CPU usage',
          datasource='$datasource',
          span=4,
          format='short',
          min=0,
        )
        .addTarget(prometheus.target('rate(process_cpu_seconds_total{%(corednsSelector)s,instance=~"$instance"}[5m])' % $._config, legendFormat='{{instance}}'));

      local goroutines =
        graphPanel.new(
          'Goroutines',
          datasource='$datasource',
          span=4,
          format='short',
        )
        .addTarget(prometheus.target('go_goroutines{%(corednsSelector)s,instance=~"$instance"}' % $._config, legendFormat='{{instance}}'));


      dashboard.new(
        '%(dashboardNamePrefix)sCoreDNS' % $._config.grafana,
        time_from='now-1h',
        uid=($._config.grafanaDashboardIDs['coredns.json']),
        tags=($._config.grafana.dashboardTags),
      ).addTemplate(
        {
          current: {
            text: 'default',
            value: 'default',
          },
          hide: 0,
          label: null,
          name: 'datasource',
          options: [],
          query: 'prometheus',
          refresh: 1,
          regex: '',
          type: 'datasource',
        },
      ).addTemplate(
        template.new(
          'instance',
          '$datasource',
          'label_values(coredns_dns_request_count_total{%(corednsSelector)s}, instance)' % $._config,
          refresh='time',
          includeAll=true,
          sort=1,
        )
      ).addRow(
        row.new()
        .addPanel(upCount)
        .addPanel(rpcRate)
        .addPanel(requestDuration)
      ).addRow(
        row.new()
        .addPanel(memory)
        .addPanel(cpu)
        .addPanel(goroutines)
      ) + { refresh: $._config.grafana.refresh },
  },
}
