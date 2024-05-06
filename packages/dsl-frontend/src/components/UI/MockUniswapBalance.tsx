
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Button, Form, Input, InputNumber, Spin, Typography } from 'antd';

import { useAccount, useBalance, useClient, useReadContract, useSendTransaction, useWalletClient, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import MockERC20_ABI from '@dsl/contracts/abis/MockERC20.json';
import { readContract } from 'viem/actions';
import { constants } from 'http2';
import { formatUnits, parseEther, parseUnits } from 'viem';

const { Title, Text } = Typography

type MockUniswapBalanceProps = {
}

const MockUniswapBalance: FC<MockUniswapBalanceProps> = ({ }) => {
  const { isPending, data } = useReadContract({
    abi: MockERC20_ABI,
    address: addresses.usdc as `0x${string}`,
    functionName: 'balanceOf',
    args: [
      addresses.uniswap as `0x${string}`
    ]
  })


  return (
    <>
      <Title style={{ marginTop: 0, marginBottom: 0 }} level={5}>Mock Uniswap Router</Title>
      <Text type='secondary'>The Mock Uniswap Router. It swaps directly with its assets instead of going through any v3 Pool</Text>
      <div style={{ display: 'flex', flexDirection: 'column', marginTop: 8 }} >
        <Text strong>Address: {addresses.uniswap}</Text>
        <Text strong>Balance: {data ? formatUnits(data as bigint, 6) : 0} USDC {isPending && <Spin />}</Text>
      </div>
    </>
  );
}

export default MockUniswapBalance;

