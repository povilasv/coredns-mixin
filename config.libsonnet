{
  _config+:: {
    // Dashboard configurations
    enableMultiCluster: false,
    corednsSelector: if self.enableMultiCluster then 'job=~"kube-dns", cluster=~"$cluster"' else 'job=~"kube-dns"',
    multiclusterSelector: 'job=~"kube-dns"',
    instanceLabel: 'pod',

    grafanaDashboardIDs+: {
      'coredns.json': 'thael1rie7ohG6OY3eMeisahtee2iGoo1gooGhuu',
    },

    pluginNameLabel: 'name',
    kubernetesPlugin: false,
    grafana+: {
      dashboardNamePrefix: '',
      dashboardTags: ['coredns-mixin'],

      // The default refresh time for all dashboards, default to 10s
      refresh: '10s',
    },

    // Alert configurations
    corednsSelectorAlerts: 'job=~"kube-dns"'
  },
}
