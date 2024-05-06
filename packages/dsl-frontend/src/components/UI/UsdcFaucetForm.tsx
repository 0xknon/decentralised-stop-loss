
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Button, Form, Input, InputNumber, Typography } from 'antd';

import { useAccount, useBalance, useClient, useReadContract, useSendTransaction, useWalletClient, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import MockERC20_ABI from '@dsl/contracts/abis/MockERC20.json';
import { readContract } from 'viem/actions';
import { constants } from 'http2';
import { parseEther, parseUnits } from 'viem';

const { Title, Text } = Typography

type UsdcFaucetFormValues = {
  to: string
  amount: number
}

type UsdcFaucetFormProps = {
}

const UsdcFaucetForm: FC<UsdcFaucetFormProps> = ({ }) => {
  const { isPending, writeContract, error } = useWriteContract()
  const client = useClient()

  const handleSetRoundData = useCallback(async ({ to, amount }: UsdcFaucetFormValues) => {
    if (!client) {
      return
    }

    writeContract({
      abi: MockERC20_ABI,
      address: addresses.usdc as `0x${string}`,
      functionName: 'mint',
      args: [
        to,
        parseUnits(amount.toString(), 6)
      ]
    })
  }, [client, writeContract])

  return (
    <>
      <Title style={{ marginTop: 0, marginBottom: 0 }} level={5}>Mock USDC Faucet</Title>
      <Text type='secondary'>You may need to fund the Mock Uniswap Router</Text>
      <Form<UsdcFaucetFormValues> style={{ marginTop: 8 }} requiredMark={false} layout='vertical' onFinish={handleSetRoundData} >
        <Form.Item label="To" name="to" rules={[{ required: true }]} >
          <Input />
        </Form.Item>
        <Form.Item label="Amount" name="amount" rules={[{ required: true }]} >
          <InputNumber style={{ width: '100%' }} addonAfter="USDC" />
        </Form.Item>
        <Form.Item>
          <Button type='primary' htmlType='submit' >Mint</Button>
        </Form.Item>
      </Form>
    </>
  );
}

export default UsdcFaucetForm;

