import { Layout, Grid, MenuProps, FloatButton } from 'antd';
import { FC, ReactNode, useState } from 'react';
import styled from 'styled-components';

import Header from './Header';

const { Content, Footer } = Layout;

const StyledLayout = styled(Layout)`
  height: 100vh;
  width: 100%;
  overflow: hidden;
`;


const StyledContent = styled(Content)`
  width: 100%;
  overflow: auto;
  /* overflow: hidden;
  height: 100%; */
`;

type BasicLayoutProps = {
  children: ReactNode;
};

const BasicLayout: FC<BasicLayoutProps> = ({ children }) => {
  return (
    <StyledLayout >
      <Header />
      <StyledContent>{children}</StyledContent>
    </StyledLayout>
  );
};

export default BasicLayout;
