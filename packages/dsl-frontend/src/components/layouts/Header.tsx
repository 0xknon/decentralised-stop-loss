import React, { FC, useCallback, useEffect, useState } from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Layout, MenuProps, Button, Modal, Spin, Dropdown, Grid, Menu, Badge } from 'antd';
import { UserOutlined, LogoutOutlined, UpOutlined, SettingOutlined, MenuOutlined, MessageOutlined, ShoppingCartOutlined } from '@ant-design/icons';
import { useRouter } from 'next/router'
import styled from 'styled-components';
import Image from 'next/image';

const HeaderWrapper = styled(Layout.Header)`
  width: 100%;
  /* border-bottom: 1px solid #00000022; */
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: ${props => props.theme.antd.boxShadowTertiary};
`;

const StyledConnectButton = styled(ConnectButton)`
  float: right;
`

const StyledCartButton = styled(ShoppingCartOutlined)`
  font-size: 24px;
  cursor: pointer;
`

type HeaderProps = {
  menuItems?: MenuProps['items']
}

const Header: FC<HeaderProps> = ({ menuItems = [] }) => {
  return (
    <HeaderWrapper>
      <div style={{ display: 'flex', alignItems: 'center' }}>
      </div>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        {/* <PaymasterSettingsButton style={{ marginRight: 16 }} /> */}
        <StyledConnectButton />
      </div>
    </HeaderWrapper >
  );
}

export default Header;
