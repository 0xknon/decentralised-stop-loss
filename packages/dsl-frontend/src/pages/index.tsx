import { deploy } from "@/utils";
import { Typography, Card, Col, Collapse, Form, Input, Menu, MenuProps, Row, Spin, Modal, Button, Table, TableProps, Tooltip, Badge } from "antd";
import { useCallback, useMemo, useState } from "react";
import styled from "styled-components";
import { useAccount, useBalance, useWalletClient, useWriteContract } from "wagmi";
import { addresses } from "@/constants";
import { formatEther, parseEther } from "viem";
import VaultDepositButton from "@/components/UI/VaultDepositButton";
import StopLossStatus from "@/components/UI/StopLossStatus";
import ChainlinkOracleForm from "@/components/UI/ChainlinkOracleForm";

const { Text } = Typography

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
  const { } = useAccount()
  const { isPending, writeContract } = useWriteContract()
  const { data: balance } = useBalance({ address: addresses.vault as `0x${string}` })
  console.log(balance)
  const handleDeploy = useCallback(() => {
    // client.depl
  }, [])
  return (
    <PageWrapper>
      <Row gutter={[12, 12]}>
        <Col span={12}>
          <VaultCard title="Bob Vault" extra={<VaultDepositButton />}>
            <div>
              <Text strong>Balance: {formatEther(balance?.value || BigInt(0))} {balance?.symbol}</Text>
            </div>
            <div>
              <StopLossStatus />
            </div>
          </VaultCard>
        </Col>
        <Col span={12}>
          <Card title="Mock Resources">
            <ChainlinkOracleForm />
          </Card>
        </Col>
      </Row>
    </PageWrapper>
  );
}