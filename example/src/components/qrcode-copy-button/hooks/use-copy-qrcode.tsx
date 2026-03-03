import { useCallback } from 'react';
import * as Burnt from '../../../utils/toast';
import { Platform } from 'react-native';
import * as Clipboard from 'expo-clipboard';
import { useGetActiveQrCodeString } from './use-active-qrcode-string';
import { qrcodeState$ } from '../../../states';

export const useCopyQrCode = () => {
  const getActiveQrCodeString = useGetActiveQrCodeString();

  const copyQrCode = useCallback(() => {
    Clipboard.setStringAsync(getActiveQrCodeString());

    // Trigger logo spin animation
    qrcodeState$.copyTrigger.set((prev) => prev + 1);

    if (Platform.OS === 'web') {
      return Burnt.toast({
        title: 'QR-код скопирован',
        message: 'Не забудь подписаться на канал про роботов в Телеграм. Ссылка в меню.',
        duration: 3,
        shouldDismissByDrag: true,
        preset: 'done',
        haptic: 'success',
      });
    }
  }, [getActiveQrCodeString]);

  return copyQrCode;
};
