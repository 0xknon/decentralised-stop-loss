
import React, { FC, useCallback, useEffect, useState } from 'react';
import { Layout, MenuProps, Button, Modal, Spin, Dropdown, Grid, Menu, Badge, Form, InputNumber } from 'antd';

import { useAccount, useBalance, useReadContract, useSendTransaction, useWriteContract } from 'wagmi';
import { addresses } from '@/constants';
import BOB_VAULT_ABI from '@dsl/contracts/abis/BobVault.json';

type VaultDepositFormValues = {
  value: number
}

type StopLossStatusProps = {
}

const StopLossStatus: FC<StopLossStatusProps> = ({ }) => {
  const { isPending, data } = useReadContract({
    abi: BOB_VAULT_ABI,
    address: addresses.vault as `0x${string}`,
    functionName: 'shouldStopLoss'
  })

  return (
    <>
      {isPending && <Badge status="processing" text="Loading..." />}
      {!isPending && data && <Badge status="success" text="Healthy" />}
      {!isPending && !data && <Badge status="error" text="Stop Loss NOW!!!" />}
    </>
  );
}

export default StopLossStatus;

