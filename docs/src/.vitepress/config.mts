import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import { withMermaid } from "vitepress-plugin-mermaid";

function getBaseRepository(base: string): string {
  if (!base) return '/';
  // I guess if deploy_url is available. From where do I check this ?
  const parts = base.split('/').filter(Boolean);
  return parts.length > 0 ? `/${parts[0]}/` : '/';
}
const baseTemp = {
  base: 'REPLACE_ME_DOCUMENTER_VITEPRESS',// TODO: replace this in makedocs!
}

const navTemp = {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Getting Started', link: '/basics' },
    { text: 'Tutorials',  
      items: [
        { text: 'Prepare input and run simulation', link: '/tutorials/how_to_prepare_input'},
        { text: 'Analyse model output', link: '/tutorials/how_to_analyse_output' },
        { text: 'Turn-off subprocesses', link: '/tutorials/how_to_turnoff_subprocesses' },
      ],
    },
    { text: 'Model description', link: '/model'},
    { text: 'Dashboard', link: '/dashboard' },
    { text: 'References', link: '/references' },
    { text: 'Call from R', link: 'https://felixnoessler.github.io/RGrasslandTraitSim/' },
  ],
}

const nav = [
  ...navTemp.nav,
  {
    component: 'VersionPicker'
  }
]


// https://vitepress.dev/reference/site-config
export default withMermaid(defineConfig({
  appearance: false,
  base: 'REPLACE_ME_DOCUMENTER_VITEPRESS',// TODO: replace this in makedocs!
  title: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  description: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  lastUpdated: true,
  cleanUrls: true,
  outDir: 'REPLACE_ME_DOCUMENTER_VITEPRESS', // This is required for MarkdownVitepress to work correctly...
  head: [
    ['link', { rel: 'icon', href: 'REPLACE_ME_DOCUMENTER_VITEPRESS_FAVICON' }],
    ['script', {src: `${getBaseRepository(baseTemp.base)}versions.js`}],
    ['script', {src: `${baseTemp.base}siteinfo.js`}]
  ],
  ignoreDeadLinks: true,
  
  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    logo: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav,
    sidebar: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
    editLink: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
    socialLinks: [
      { icon: 'github', link: 'REPLACE_ME_DOCUMENTER_VITEPRESS' }
    ],
    footer: {
      message: 'Released under the <a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE">GPL-3.0 license.</a>',
      copyright: `© Copyright  <a href="https://github.com/FelixNoessler/">Felix Nößler</a> 2022 - ${new Date().getUTCFullYear()}.`
    }
  }})
)
