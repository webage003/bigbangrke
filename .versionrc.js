const standardVersionUpdaterYaml = require.resolve("standard-version-updater-yaml");
const gitrepositoryUpdaterYaml = require("./scripts/js/gitrepository-updater-yaml.js");

module.exports = {
  bumpFiles: [
    {
      filename: "chart/Chart.yaml",
      updater: standardVersionUpdaterYaml
    },
    {
      filename: "base/gitrepository.yaml",
      updater: gitrepositoryUpdaterYaml
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