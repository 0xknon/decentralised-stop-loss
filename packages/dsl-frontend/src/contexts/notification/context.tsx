import { FC, useEffect, createContext, useContext, useState, ReactNode, useMemo, useCallback } from 'react';
import * as R from 'ramda';
import { Execution } from '@/interfaces';
import { useRouter } from 'next/router';
import { notification } from 'antd';
import { NotificationInstance } from 'antd/es/notification/interface';

type NotificationState = {
  notification: NotificationInstance
};

const NotificationContext = createContext<NotificationState>({
  notification
});

type NotificationProviderProps = {
  children: ReactNode
}

const NotificationProvider: FC<NotificationProviderProps> = ({ children }) => {
  const [api, contextHolder] = notification.useNotification();

  return (
    <NotificationContext.Provider value={{ notification: api }}>
      {contextHolder}
      {children}
    </NotificationContext.Provider>
  );
};

const useNotification = () => useContext(NotificationContext);

export { NotificationProvider, useNotification };
