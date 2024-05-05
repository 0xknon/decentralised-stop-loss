import '@rainbow-me/rainbowkit/styles.css';
import type { AppProps } from 'next/app';
import { ConfigProvider } from 'antd';
import { useRouter } from 'next/router';
import { MainLayout } from '@/components/layouts'
import { Providers } from '@/contexts'
// import theme from '@/theme/themeConfig';
import { WagmiProvider, createConfig, http, useClient } from 'wagmi';
import {
  mainnet,
  polygon,
  sepolia,
} from 'wagmi/chains';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RainbowKitProvider, darkTheme, getDefaultConfig } from '@rainbow-me/rainbowkit';
import { useMemo } from 'react';

const queryClient = new QueryClient();

function MyApp({ Component, router, pageProps }: AppProps) {

  // router.query returns undefined parameter on first render in Next.js  
  // https://github.com/vercel/next.js/discussions/11484#discussioncomment-356055
  const { isReady } = useRouter()

  const config = useMemo(() => createConfig({
    chains: [sepolia],
    transports: {
      // [polygon.id]: http(),
      [sepolia.id]: http(),
    },
  }), []);

  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider theme={darkTheme()}>
          <Providers>
            <MainLayout>
              <Component {...pageProps} />
            </MainLayout>
          </Providers>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider >
  );
}

export default MyApp;