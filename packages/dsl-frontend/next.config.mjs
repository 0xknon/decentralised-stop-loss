/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  output: 'export',
  // basePath: basePath || '',
  compiler: {
    // Enables the styled-components SWC transform
    styledComponents: true
  },
  transpilePackages: [
    "antd",
    "rc-util",
    "@babel/runtime",
    "@ant-design/icons",
    "@ant-design/icons-svg",
    "rc-pagination",
    "rc-picker",
    "rc-tree",
    "rc-table",
  ],
};

export default nextConfig;
