import React, { FC, useCallback, useEffect, useState } from 'react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Layout, MenuProps, Button, Modal, Spin, Dropdown, Grid, Menu, Badge, Form, InputNumber } from 'antd';
import { UserOutlined, LogoutOutlined, UpOutlined, SettingOutlined, MenuOutlined, MessageOutlined, ShoppingCartOutlined } from '@ant-design/icons';
import { useRouter } from 'next/router'
import styled from 'styled-components';
import Image from 'next/image';
import { useAccount, useBalance, useSendTransaction, useWriteContract } from 'wagmi';
import { erc20Abi, parseEther } from 'viem';
import { addresses } from '@/constants';

type VaultDepositFormValues = {
  value: number
}

type VaultDepositButtonProps = {
}

const VaultDepositButton: FC<VaultDepositButtonProps> = ({ }) => {
  const [open, setOpen] = useState(false)
  const { address } = useAccount()
  const { isPending, sendTransaction } = useSendTransaction()

  const handleDeposit = useCallback(({ value }: VaultDepositFormValues) => {
    if (!address) {
      return
    }
    sendTransaction({
      to: addresses.vault as `0x${string}`,
      value: parseEther(value.toString())
    })
  }, [address, sendTransaction])

  return (
    <>
      <Button onClick={() => setOpen(true)}>Deposit</Button>
      <Modal title="Deposit fund to the vault" open={open} onCancel={() => setOpen(false)} footer={null} >
        <Form<VaultDepositFormValues> requiredMark={false} layout="vertical" onFinish={handleDeposit}>
          <Form.Item label="Value" name="value" rules={[{ required: true }]} >
            <InputNumber style={{ width: '100%' }} addonAfter="ETH" />
          </Form.Item>
          <Form.Item>
            <Button htmlType='submit' type='primary'>Deposit</Button>
          </Form.Item>
        </Form>
      </Modal>
    </>
  );
}

export default VaultDepositButton;

