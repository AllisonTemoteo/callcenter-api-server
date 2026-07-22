enum ConfigKeys {
  npxLastSyncAt('api/npx/lastSyncDateTime'),
  npxMonitoredQueues('api/npx/monitoredQueues');

  final String str;
  const ConfigKeys(this.str);
}
