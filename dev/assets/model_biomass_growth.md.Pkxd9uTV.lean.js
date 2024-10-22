import{_ as p,c,j as a,a as i,b as h,w as t,a6 as d,G as e,a5 as E,B as n,o as l}from"./chunks/framework.DUg_Vbhg.js";const B=JSON.parse('{"title":"Growth","description":"","frontmatter":{},"headers":[],"relativePath":"model/biomass/growth.md","filePath":"model/biomass/growth.md","lastUpdated":null}'),k={name:"model/biomass/growth.md"},g={class:"jldocstring custom-block",open:""};function m(u,s,f,w,_,b){const o=n("Mermaid"),r=n("Badge");return l(),c("div",null,[s[4]||(s[4]=a("h1",{id:"growth",tabindex:"-1"},[i("Growth "),a("a",{class:"header-anchor",href:"#growth","aria-label":'Permalink to "Growth"'},"​")],-1)),s[5]||(s[5]=a("p",null,"Click on a process to view detailed documentation:",-1)),(l(),h(d,null,{default:t(()=>[e(o,{id:"mermaid-6",class:"mermaid",graph:"flowchart%20LR%0A%20%20%20%20A%5B%5Bpotential%20growth%5D%5D%20%3D%3D%3E%20D(actual%20growth)%0A%20%20%20%20B%5B%5Bcommunity%20adjustment%20by%20environmental%20and%20seasonal%20factors%5D%5D%20%3D%3D%3E%20D%0A%20%20%20%20C%5B%5Bspecies-specific%20adjustment%5D%5D%20%3D%3D%3E%20D%0A%20%20%20%20subgraph%20%22%20%22%0A%20%20%20%20L%5B%E2%86%93%20radiation%5D%20-.-%3E%20B%0A%20%20%20%20M%5B%E2%86%93%20temperature%5D%20-.-%3E%20B%0A%20%20%20%20N%5B%E2%87%85%20seasonal%20factor%5D%20-.-%3E%20B%0A%20%20%20%20end%0A%20%20%20%20subgraph%20%22%20%22%0A%20%20%20%20F%5B%E2%87%85%20light%20competition%5D%20-.-%3E%20C%0A%20%20%20%20H%5B%E2%86%93%20water%20stress%5D%20-.-%3E%20C%0A%20%20%20%20I%5B%E2%86%93%20nutrient%20stress%5D%20-.-%3E%20C%0A%20%20%20%20P%5B%E2%86%93%20investment%20into%20roots%20and%20mycorrhiza%5D%20-.-%3E%20C%0A%20%20%20%20end%0Aclick%20A%20%22growth_potential_growth%22%20%22Go%22%0Aclick%20B%20%22growth_env_factors%22%20%22Go%22%0Aclick%20C%20%22growth_species_specific%22%20%22Go%22%0Aclick%20L%20%22growth_env_factors%23Radiation-influence%22%20%22Go%22%0Aclick%20M%20%22growth_env_factors%23Temperature-influence%22%20%22Go%22%0Aclick%20N%20%22growth_env_factors%23Seasonal-effect%22%20%22Go%22%0Aclick%20F%20%22growth_species_specific_light%22%20%22Go%22%0Aclick%20H%20%22growth_species_specific_water%22%20%22Go%22%0Aclick%20I%20%22growth_species_specific_nutrients%22%20%22Go%22%0Aclick%20P%20%22growth_species_specific_roots%22%20%22Go%22%0A"})]),fallback:t(()=>s[0]||(s[0]=[i(" Loading... ")])),_:1})),s[6]||(s[6]=a("h2",{id:"api",tabindex:"-1"},[i("API "),a("a",{class:"header-anchor",href:"#api","aria-label":'Permalink to "API"'},"​")],-1)),a("details",g,[a("summary",null,[s[1]||(s[1]=a("a",{id:"GrasslandTraitSim.growth!",href:"#GrasslandTraitSim.growth!"},[a("span",{class:"jlbinding"},"GrasslandTraitSim.growth!")],-1)),s[2]||(s[2]=i()),e(r,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),s[3]||(s[3]=E(`<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">growth!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    t,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    container,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    above_biomass,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    total_biomass,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actual_height,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    W,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    nutrients,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WHC,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PWP</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Calculates the growth of the plant species.</p><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/85fff8454eed5840396a57a6e6b9032b57db5f7c/src/3_biomass/1_growth/1_growth.jl#L8" target="_blank" rel="noreferrer">source</a></p>`,3))])])}const D=p(k,[["render",m]]);export{B as __pageData,D as default};
