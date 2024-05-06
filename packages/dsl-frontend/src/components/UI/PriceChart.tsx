
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Layout, MenuProps, Button, Modal, Spin, Dropdown, Grid, Menu, Badge, Form, InputNumber, Typography } from 'antd';

import { addresses } from '@/constants';
import dayjs from 'dayjs';
import AGGREGATOR_ABI from '@dsl/contracts/abis/MockChainlinkAggregator.json';
import { useQuery } from '@tanstack/react-query';
import { useClient } from 'wagmi';
import { readContract } from 'viem/actions';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { formatUnits } from 'viem';
import { ReloadOutlined } from '@ant-design/icons';
import styled from 'styled-components';


const { Title, Text } = Typography

const StyledReloadButton = styled(ReloadOutlined)`
  cursor: pointer;
  margin-left: 8px;
`

type PriceChartProps = {
}

const PriceChart: FC<PriceChartProps> = ({ }) => {
  const client = useClient()
  const { data, refetch, isRefetching } = useQuery({
    queryKey: [client],
    queryFn: async () => {
      if (!client) {
        return []
      }

      const _data = []

      const round = await readContract(client, {
        abi: AGGREGATOR_ABI,
        address: addresses.aggregator as `0x${string}`,
        functionName: 'latestRoundData',
      }) as bigint[]

      let currentRoundUpdatedAt = Number(round[3] as bigint) * 1000

      _data.push({
        name: dayjs(currentRoundUpdatedAt).format('DD/MM/YYYY HH:mm'),
        price: formatUnits(round[1], 8)
      })

      let nextRoundId = Number(round[0]) - 1
      do {
        const round = await readContract(client, {
          abi: AGGREGATOR_ABI,
          address: addresses.aggregator as `0x${string}`,
          functionName: 'getRoundData',
          args: [nextRoundId]
        }) as bigint[]

        currentRoundUpdatedAt = Number(round[3] as bigint) * 1000

        _data.push({
          name: dayjs(currentRoundUpdatedAt).format('DD/MM/YYYY HH:mm'),
          price: formatUnits(round[1], 8)
        })

        nextRoundId = Number(round[0]) - 1
      } while (nextRoundId != 0 && currentRoundUpdatedAt >= new Date().getTime() - 1800000)

      return _data.reverse()
    },
  })

  console.log(data)

  return (
    <>
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <Title style={{ marginTop: 0, marginBottom: 0 }} level={5}>ETH/USD</Title>
        <StyledReloadButton spin={isRefetching} onClick={() => refetch()} />
      </div>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart
          width={500}
          height={300}
          data={data}
          margin={{
            top: 5,
            right: 30,
            left: 5,
            bottom: 5,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis padding={{ left: 64, right: 64 }} dataKey="name" />
          <YAxis padding={{ top: 24 }} />
          <Tooltip />
          <Legend />
          <Line type="monotone" dataKey="price" stroke="#82ca9d" activeDot={{ r: 4 }} />
        </LineChart>
      </ResponsiveContainer>
    </>
  );
}

export default PriceChart;

