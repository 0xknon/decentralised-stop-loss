
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Button, Form, InputNumber, Typography } from 'antd';

import { useAccount, useBalance, useClient, useReadContract, useSendTransaction, useWalletClient, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import AGGREGATOR_ABI from '@dsl/contracts/abis/MockChainlinkAggregator.json';
import { readContract } from 'viem/actions';
import { constants } from 'http2';
import { parseEther, parseUnits } from 'viem';

const { Title } = Typography

type ChainlinkOracleFormValues = {
  answer: number
}

type ChainlinkOracleFormProps = {
}

const ChainlinkOracleForm: FC<ChainlinkOracleFormProps> = ({ }) => {
  const { isPending, writeContract, error } = useWriteContract()
  const client = useClient()

  const handleSetRoundData = useCallback(async ({ answer }: ChainlinkOracleFormValues) => {
    if (!client) {
      return
    }

    const roundId = await readContract(client, {
      abi: AGGREGATOR_ABI,
      address: addresses.aggregator as `0x${string}`,
      functionName: 'latestRound',
    }) as bigint

    const ts = Math.floor(new Date().getTime() / 1000)

    writeContract({
      abi: AGGREGATOR_ABI,
      address: addresses.aggregator as `0x${string}`,
      functionName: 'setRoundData',
      args: [
        roundId + BigInt(1),
        [parseUnits(answer.toString(), 6), ts, ts]
      ]
    })
  }, [client, writeContract])

  return (
    <>
      <Title style={{ marginTop: 0 }} level={5}>Chainlink Price Oracle</Title>
      <Form<ChainlinkOracleFormValues> requiredMark={false} layout='vertical' onFinish={handleSetRoundData} >
        <Form.Item label="Price" name="answer" rules={[{ required: true }]} >
          <InputNumber style={{ width: '100%' }} addonAfter="USD" />
        </Form.Item>
        <Form.Item>
          <Button type='primary' htmlType='submit' >Set Price</Button>
        </Form.Item>
      </Form>
    </>
  );
}

export default ChainlinkOracleForm;

