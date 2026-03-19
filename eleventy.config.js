const yaml = require("yaml");

module.exports = function (eleventyConfig) {
  eleventyConfig.addDataExtension("yml,yaml", (contents) =>
    yaml.parse(contents)
  );

  eleventyConfig.addPassthroughCopy("src/css");
  eleventyConfig.addPassthroughCopy("src/js");

  return {
    dir: {
      input: "src",
      output: "_site",
    },
  };
};
