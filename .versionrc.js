const standardVersionUpdaterYaml = require.resolve("standard-version-updater-yaml");

module.exports = {
  bumpFiles: [
    {
      filename: "chart/Chart.yaml",
      updater: standardVersionUpdaterYaml
    },
    {
      filename: "package.json",
      type: "json"
    },
    {
      filename: "package-lock.json",
      type: "json"
    },
  ]
};