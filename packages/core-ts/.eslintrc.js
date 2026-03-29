module.exports = {
  root: false,
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: "module",
  },
  ignorePatterns: ["dist/", "node_modules/"],
  rules: {
    "no-restricted-syntax": [
      "error",
      {
        selector: "CallExpression[callee.name='Number']",
        message:
          "Do not use Number() to cast values in core-ts routing interfaces. " +
          "Casting BigInt to Number silently clips values above Number.MAX_SAFE_INTEGER (2^53-1), " +
          "causing routing corruption. Keep values as BigInt throughout."
      },
      {
        selector: "UnaryExpression[operator='+']",
        message:
          "Do not use unary + in core-ts. " +
          "This coerces BigInt to Number with silent precision loss."
      },
      {
        selector: "CallExpression[callee.name='parseFloat']",
        message:
          "Do not use parseFloat() in core-ts routing interfaces. " +
          "This may silently lose precision on large integers."
      }
    ]
  }
};