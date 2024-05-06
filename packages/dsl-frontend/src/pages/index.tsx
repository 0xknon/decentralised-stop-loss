import { deploy } from "@/utils";
import { Typography, Card, Col, Collapse, Form, Input, Menu, MenuProps, Row, Spin, Modal, Button, Table, TableProps, Tooltip, Badge, Divider } from "antd";
import { useCallback, useMemo, useState } from "react";
import styled from "styled-components";
import { useAccount, useBalance, useReadContract, useWalletClient, useWriteContract } from "wagmi";
import { addresses } from "@/constants";
import { formatEther, formatUnits, parseEther } from "viem";
import VaultDepositButton from "@/components/UI/VaultDepositButton";
import StopLossStatus from "@/components/UI/StopLossStatus";
import ChainlinkOracleForm from "@/components/UI/ChainlinkOracleForm";
import UsdcFaucetForm from "@/components/UI/UsdcFaucetForm";
import MockUniswapBalance from "@/components/UI/MockUniswapBalance";
import PriceChart from "@/components/UI/PriceChart";
import StopLossButton from "@/components/UI/StopLossButton";
import MockERC20_ABI from '@dsl/contracts/abis/MockERC20.json';

const { Title, Text } = Typography

const VaultCard = styled(Card)`
  .ant-card-body {
    /* display: flex;
    justify-content: space-between; */
  }
`

const PageWrapper = styled.div`
  padding: 16px;
  width: 100%;
  max-width: 1280px;
  margin: 0 auto;
`

export default function Home() {
  const { data: balance } = useBalance({ address: addresses.vault as `0x${string}` })
  const { isPending, data, refetch } = useReadContract({
    abi: MockERC20_ABI,
    address: addresses.usdc as `0x${string}`,
    functionName: 'balanceOf',
    args: [
      addresses.vault as `0x${string}`
    ]
  })

  return (
    <PageWrapper>
      <Row gutter={[12, 12]}>
        <Col span={14}>
          <VaultCard title="Bob Vault" extra={<VaultDepositButton />}>
            <div style={{ width: '100%', height: 300 }}>
              <PriceChart />
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ display: 'flex', flexDirection: 'column' }}>
                <Text strong>Vault Balance: </Text>
                <Text >{formatEther(balance?.value || BigInt(0))} {balance?.symbol}</Text>
                <Text >{formatUnits(data as bigint || BigInt(0), 6)} USDC</Text>
                <StopLossStatus />
              </div>
              <StopLossButton />
            </div>
          </VaultCard>
        </Col>
        <Col span={10}>
          <Card title="Mock Resources">
            <ChainlinkOracleForm />
            <Divider />
            <UsdcFaucetForm />
            <Divider />
            <MockUniswapBalance />
          </Card>
        </Col>
      </Row>
    </PageWrapper>
  );
}