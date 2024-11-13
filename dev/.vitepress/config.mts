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
  base: '/GrasslandTraitSim.jl/dev/',// TODO: replace this in makedocs!
}

const navTemp = {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Getting Started', link: '/basics' },
    { text: 'Tutorials',  
      items: [
        { text: 'Prepare input and run simulation', link: '/tutorials/how_to_prepare_input'},
        { text: 'Analyse model output', link: '/tutorials/how_to_analyse_output' },
        { text: 'Heterogenous site or management conditions', link: '/tutorials/how_to_heterogeneous_site_management' },
      ],
    },
    { text: 'Model description', link: '/model'},
    { text: 'Visualization',
      items: [
        { text: 'Dashboard', link: '/viz/dashboard'},
        { text: 'Visualize model components', link: '/viz/variables' },
        { text: 'Varying the time step', link: '/viz/time_step' },
      ],
    },
    
    { text: 'References', link: '/references' },
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
  base: '/GrasslandTraitSim.jl/dev/',// TODO: replace this in makedocs!
  title: 'GrasslandTraitSim.jl',
  description: 'Documentation for GrasslandTraitSim.jl',
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../final_site', // This is required for MarkdownVitepress to work correctly...
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
    
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Getting Started', link: '/basics' },
{ text: 'Tutorials', collapsed: false, items: [
{ text: 'Prepare input and run simulation', link: '/tutorials/how_to_prepare_input' },
{ text: 'Analyse model output', link: '/tutorials/how_to_analyse_output' },
{ text: 'Heterogenous site or management conditions', link: '/tutorials/how_to_heterogeneous_site_management' },
{ text: 'Turn-off subprocesses', link: '/tutorials/how_to_turnoff_subprocesses' }]
 },
{ text: 'Model description', collapsed: false, items: [
{ text: 'Overview', link: '/model/index' },
{ text: 'Model inputs', link: '/model/inputs' },
{ text: 'Parameter', link: '/model/parameter' },
{ text: 'Plant biomass dynamics', collapsed: false, items: [
{ text: 'Overview', link: '/model/biomass/index' },
{ text: 'Growth: overview', link: '/model/biomass/growth' },
{ text: 'Growth: potential growth', link: '/model/biomass/growth_potential_growth' },
{ text: 'Growth: community adjustment', link: '/model/biomass/growth_env_factors' },
{ text: 'Growth: species-specific adjustment', link: '/model/biomass/growth_species_specific' },
{ text: '- for light', link: '/model/biomass/growth_species_specific_light' },
{ text: '- for soil water', link: '/model/biomass/growth_species_specific_water' },
{ text: '- for nutrients', link: '/model/biomass/growth_species_specific_nutrients' },
{ text: '- for investment into roots', link: '/model/biomass/growth_species_specific_roots' },
{ text: 'Senescence', link: '/model/biomass/senescence' },
{ text: 'Mowing and grazing', link: '/model/biomass/mowing_grazing' }]
 },
{ text: 'Plant height dynamics', link: '/model/height/index' },
{ text: 'Soil water dynamics', link: '/model/water/index' }]
 },
{ text: 'Visualization', collapsed: false, items: [
{ text: 'Dashboard', link: '/viz/dashboard' },
{ text: 'Visualize model components', link: '/viz/variables' },
{ text: 'Varying the time step', link: '/viz/time_step' }]
 },
{ text: 'References', link: '/references' }
]
,
    editLink: { pattern: "https://github.com/FelixNoessler/GrasslandTraitSim.jl/edit/master/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/FelixNoessler/GrasslandTraitSim.jl' }
    ],
    footer: {
      message: 'Released under the <a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE">GPL-3.0 license.</a>',
      copyright: `© Copyright  <a href="https://github.com/FelixNoessler/">Felix Nößler</a> 2022 - ${new Date().getUTCFullYear()}.`
    }
  }})
)
