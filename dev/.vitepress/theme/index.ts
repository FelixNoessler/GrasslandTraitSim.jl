// .vitepress/theme/index.ts
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'

import { enhanceAppWithTabs } from 'vitepress-plugin-tabs/client'
import VersionPicker from "./VersionPicker.vue"
import './style.css'

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
    })
  },
  enhanceApp({ app, router, siteData }) {
    enhanceAppWithTabs(app);
    app.component('VersionPicker', VersionPicker);
  }
} satisfies Theme