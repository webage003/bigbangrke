const yaml = require("yaml");

module.exports.readVersion = contents => yaml.parse(contents, "utf8").version;

module.exports.readVersion = (contents) => {
  const yamlFile = yaml.parse(contents, "utf8");
  return yamlFile.spec.ref.tag;
};

module.exports.writeVersion = (contents, version) => {
  const yamlFile = yaml.parse(contents, "utf8");
  yamlFile.spec.ref.tag = version;
  return yaml.stringify(yamlFile, "utf8");
};