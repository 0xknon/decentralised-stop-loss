'use client'
import { FC, ReactNode, useEffect, useState } from 'react';
import { CustomThemeProvider } from './theme';
import { NotificationProvider } from './notification';

type ProvidersProps = {
  children: ReactNode
}
export const Providers: FC<ProvidersProps> = ({ children }) => {

  return (
    <CustomThemeProvider>
      <NotificationProvider>
        {children}
      </NotificationProvider>
    </CustomThemeProvider>
  )
};
