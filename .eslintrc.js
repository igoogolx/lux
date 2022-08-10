module.exports = {
  extends: ["airbnb-typescript-prettier"],
  rules: {
    "import/prefer-default-export": "off",
    "no-console": "off",
    "prettier/prettier": [
      "error",
      {
        endOfLine: "auto",
      },
    ],
  },
};
