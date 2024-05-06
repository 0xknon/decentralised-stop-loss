
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Badge, Typography } from 'antd';

import { useAccount, useBalance, useReadContract, useSendTransaction, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import BOB_VAULT_ABI from '@dsl/contracts/abis/BobVault.json';
import { ReloadOutlined } from '@ant-design/icons';
import styled from 'styled-components';

const { Text } = Typography

const StyledReloadButton = styled(ReloadOutlined)`
  cursor: pointer;
  margin-left: 16px;
`

type StopLossStatusProps = {
}

const StopLossStatus: FC<StopLossStatusProps> = ({ }) => {
  const { isPending, data, refetch, isRefetching } = useReadContract({
    abi: BOB_VAULT_ABI,
    address: addresses.vault as `0x${string}`,
    functionName: 'shouldStopLoss',
  })


  const handleReload = async () => {
    refetch()
  }

  return (
    <div>
      <Text strong>Status: </Text>
      {isPending && <Badge status="processing" text="Loading..." />}
      {!isPending && !data && <Badge status="success" text="Healthy" />}
      {!isPending && !!data && <Badge status="error" text="Stop Loss NOW!!!" />}
      <StyledReloadButton spin={isRefetching} onClick={handleReload} />
    </div>
  );
}

export default StopLossStatus;

