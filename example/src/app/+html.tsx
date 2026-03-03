import { ScrollViewStyleReset } from 'expo-router/html';
import React from 'react';

const SITE_URL = 'https://qr.sargeras.ru';
const TITLE = 'Генератор QR-кодов — qrobotics';
const DESCRIPTION =
  'Создайте красивый QR-код за секунды: градиенты, формы, логотип в центре. Бесплатный генератор для ссылки на канал в Telegram и не только.';
const KEYWORDS =
  'QR код, генератор QR, создать QR код, QR код бесплатно, QR для телеграм, канал телеграм, qrobotics, блип робот';
// Код верификации Яндекса: получить в https://webmaster.yandex.ru/ — добавить в контент
const YANDEX_VERIFICATION = '';
const YANDEX_METRIKA_ID = 107090978;

// This file is web-only and used to configure the root HTML for every
// web page during static rendering.
// The contents of this function only run in Node.js environments and
// do not have access to the DOM or browser APIs.
export default function Root({ children }: { children: React.ReactNode }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebSite',
        '@id': `${SITE_URL}/#website`,
        url: SITE_URL,
        name: TITLE,
        description: DESCRIPTION,
        inLanguage: ['ru', 'en'],
        potentialAction: {
          '@type': 'SearchAction',
          target: { '@type': 'EntryPoint', url: SITE_URL },
          'query-input': 'required name=search_term_string',
        },
      },
      {
        '@type': 'Organization',
        name: 'qrobotics',
        url: SITE_URL,
        description: DESCRIPTION,
      },
    ],
  };

  return (
    <html lang="ru">
      <head>
        <title>{TITLE}</title>
        <meta charSet="utf-8" />
        <meta httpEquiv="X-UA-Compatible" content="IE=edge" />
        <meta
          name="viewport"
          content="width=device-width, initial-scale=1, shrink-to-fit=no"
        />

        {/* SEO — базовое */}
        <meta name="description" content={DESCRIPTION} />
        <meta name="keywords" content={KEYWORDS} />
        <link rel="canonical" href={SITE_URL} />

        {/* Индексация: разрешаем всем поисковикам */}
        <meta name="robots" content="index, follow" />
        <meta name="yandex" content="index, follow" />
        <meta name="googlebot" content="index, follow" />

        {/* Яндекс.Вебмастер: верификация (подставить код из панели) */}
        {YANDEX_VERIFICATION ? (
          <meta name="yandex-verification" content={YANDEX_VERIFICATION} />
        ) : null}

        {/* Доп. мета для РФ/СНГ */}
        <meta name="author" content="qrobotics" />
        <meta name="geo.region" content="RU" />
        <meta name="language" content="Russian" />

        {/* Open Graph — для соцсетей и превью в поиске */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content={SITE_URL} />
        <meta property="og:title" content={TITLE} />
        <meta property="og:description" content={DESCRIPTION} />
        <meta property="og:image" content={`${SITE_URL}/og-image.png`} />
        <meta property="og:image:width" content="1200" />
        <meta property="og:image:height" content="630" />
        <meta property="og:locale" content="ru_RU" />
        <meta property="og:locale:alternate" content="en_US" />
        <meta property="og:site_name" content="qrobotics" />

        {/* Twitter Card */}
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:title" content={TITLE} />
        <meta name="twitter:description" content={DESCRIPTION} />
        <meta name="twitter:image" content={`${SITE_URL}/og-image.png`} />

        {/* Schema.org / JSON-LD — для Яндекса и Google (сниппеты, карточки) */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />

        {/* Yandex.Metrika counter */}
        <script
          type="text/javascript"
          dangerouslySetInnerHTML={{
            __html: `
(function(m,e,t,r,i,k,a){
  m[i]=m[i]||function(){(m[i].a=m[i].a||[]).push(arguments)};
  m[i].l=1*new Date();
  for (var j = 0; j < document.scripts.length; j++) { if (document.scripts[j].src === r) { return; } }
  k=e.createElement(t),a=e.getElementsByTagName(t)[0],k.async=1,k.src=r,a.parentNode.insertBefore(k,a);
})(window, document, 'script', 'https://mc.yandex.ru/metrika/tag.js?id=${YANDEX_METRIKA_ID}', 'ym');
ym(${YANDEX_METRIKA_ID}, 'init', { ssr: true, webvisor: true, clickmap: true, referrer: document.referrer, url: location.href, accurateTrackBounce: true, trackLinks: true });
            `.trim(),
          }}
        />
        {/* /Yandex.Metrika counter */}

        {/*
          Disable body scrolling on web. This makes ScrollView components work closer to how they do on native.
          However, body scrolling is often nice to have for mobile web. If you want to enable it, remove this line.
        */}
        <ScrollViewStyleReset />

        {/* Using raw CSS styles as an escape-hatch to ensure the background color never flickers in dark-mode. */}
        <style dangerouslySetInnerHTML={{ __html: responsiveBackground }} />
      </head>
      <body>
        <noscript>
          <div>
            <img
              src={`https://mc.yandex.ru/watch/${YANDEX_METRIKA_ID}`}
              style={{ position: 'absolute', left: -9999 }}
              alt=""
            />
          </div>
        </noscript>
        {children}
      </body>
    </html>
  );
}

const responsiveBackground = `
:root {
  color-scheme: dark;
}
html, body {
  background-color: #000000;
  margin: 0;
  padding: 0;
  overflow: hidden;
}
#root {
  background-color: #000000;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: auto;
}
/* Fallback background that covers entire canvas */
html::before {
  content: '';
  position: fixed;
  top: -9999px;
  left: -9999px;
  right: -9999px;
  bottom: -9999px;
  background-color: #000000;
  z-index: -1;
}
`;
