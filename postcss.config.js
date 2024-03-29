const environment = {
  plugins: [
    require("postcss-import"),
    require("autoprefixer"),
    require("tailwindcss"),
    require("postcss-flexbugs-fixes"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009",
      },
      stage: 3,
    }),
  ],
};

if (process.env.RAILS_ENV === "production") {
  environment.plugins.push(
    require("@fullhuman/postcss-purgecss")({
      content: [
        "./app/**/*.html.erb",
        "./app/helpers/**/*.rb",
        "./app/frontend/**/*.js",
        "./app/frontend/**/*.ts",
      ],
      defaultExtractor: (content) => content.match(/[A-Za-z0-9-_:/]+/g) || [],
    })
  );
}

module.exports = environment;
