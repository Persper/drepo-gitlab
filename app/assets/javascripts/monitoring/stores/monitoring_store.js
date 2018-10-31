import _ from 'underscore';

function sortMetrics(metrics) {
  return _.chain(metrics)
    .sortBy('title')
    .sortBy('weight')
    .value();
}

function checkQueryEmptyData(query) {
  return {
    ...query,
    result: query.result.filter(timeSeries => {
      const newTimeSeries = timeSeries;
      const hasValue = series => !Number.isNaN(series.value) && series.value != null;
      const hasNonNullValue = timeSeries.values.find(hasValue);

      newTimeSeries.values = hasNonNullValue ? newTimeSeries.values : [];

      return newTimeSeries;
    }),
  };
}

function removeTimeSeriesNoData(queries) {
  const timeSeries = queries.reduce((series, query) => {
    let checkedQuery = checkQueryEmptyData(query);
    checkedQuery = {
      ...checkedQuery,
      result: checkedQuery.result.filter(c => c.values.length > 0),
    };

    return series.concat(checkedQuery);
  }, []);

  return timeSeries;
}

function normalizeMetrics(metrics) {
  return metrics.map(metric => {
    const queries = metric.queries.map(query => ({
      ...query,
      result: query.result.map(result => ({
        ...result,
        values: result.values.map(([timestamp, value]) => ({
          time: new Date(timestamp * 1000),
          value: Number(value),
        })),
      })),
    }));

    return {
      ...metric,
      queries: removeTimeSeriesNoData(queries),
    };
  });
}

export default class MonitoringStore {
  constructor() {
    this.groups = [];
    this.deploymentData = [];
    this.environmentsData = [];
  }

  storeMetrics(groups = []) {
    this.groups = groups.map(group => ({
      ...group,
      metrics: normalizeMetrics(sortMetrics(group.metrics)),
    }));
  }

  storeDeploymentData(deploymentData = []) {
    this.deploymentData = deploymentData;
  }

  storeEnvironmentsData(environmentsData = []) {
    this.environmentsData = environmentsData.filter(
      environment => !!environment.latest.last_deployment,
    );
  }

  getMetricsCount() {
    return this.groups.reduce((count, group) => count + group.metrics.length, 0);
  }
}
