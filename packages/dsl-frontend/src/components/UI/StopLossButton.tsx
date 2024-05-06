
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Badge, Button, Typography } from 'antd';

import { useAccount, useBalance, useReadContract, useSendTransaction, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import BOB_VAULT_ABI from '@dsl/contracts/abis/BobVault.json';
import { ReloadOutlined } from '@ant-design/icons';
import styled from 'styled-components';

type StopLossButtonProps = {
}

const StopLossButton: FC<StopLossButtonProps> = ({ }) => {
  const { writeContract, error } = useWriteContract()


  const handleStopLoss = () => {
    writeContract({
      abi: BOB_VAULT_ABI,
      address: addresses.vault as `0x${string}`,
      functionName: 'stopLoss',
      args: []
    })
  }

  return (
    <Button type='primary' onClick={handleStopLoss}>STOP LOSS</Button>
  );
}

export default StopLossButton;

