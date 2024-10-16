import{_ as p,c,j as a,a as t,b as h,w as i,a6 as d,G as e,a5 as g,B as n,o as l}from"./chunks/framework.yAaFKXZY.js";const b=JSON.parse('{"title":"Growth","description":"","frontmatter":{},"headers":[],"relativePath":"model/plant/growth.md","filePath":"model/plant/growth.md","lastUpdated":null}'),m={name:"model/plant/growth.md"},E={class:"jldocstring custom-block",open:""};function k(u,s,f,w,_,y){const o=n("Mermaid"),r=n("Badge");return l(),c("div",null,[s[4]||(s[4]=a("h1",{id:"growth",tabindex:"-1"},[t("Growth "),a("a",{class:"header-anchor",href:"#growth","aria-label":'Permalink to "Growth"'},"​")],-1)),s[5]||(s[5]=a("p",null,"Click on a process to view detailed documentation:",-1)),(l(),h(d,null,{default:i(()=>[e(o,{id:"mermaid-6",class:"mermaid",graph:"flowchart%20LR%0A%20%20%20%20A%5B%5Bpotential%20growth%5D%5D%20%3D%3D%3E%20D(actual%20growth)%0A%20%20%20%20B%5B%5Bcommunity%20adjustment%20by%20environmental%20and%20seasonal%20factors%5D%5D%20%3D%3D%3E%20D%0A%20%20%20%20C%5B%5Bspecies-specific%20adjustment%5D%5D%20%3D%3D%3E%20D%0A%20%20%20%20subgraph%20%22%20%22%0A%20%20%20%20L%5B%E2%86%93%20radiation%5D%20-.-%3E%20B%0A%20%20%20%20M%5B%E2%86%93%20temperature%5D%20-.-%3E%20B%0A%20%20%20%20N%5B%E2%87%85%20seasonal%20factor%5D%20-.-%3E%20B%0A%20%20%20%20end%0A%20%20%20%20subgraph%20%22%20%22%0A%20%20%20%20F%5B%E2%87%85%20light%20competition%5D%20-.-%3E%20C%0A%20%20%20%20H%5B%E2%86%93%20water%20stress%5D%20-.-%3E%20C%0A%20%20%20%20I%5B%E2%86%93%20nutrient%20stress%5D%20-.-%3E%20C%0A%20%20%20%20P%5B%E2%86%93%20investment%20into%20roots%20and%20mycorrhiza%5D%20-.-%3E%20C%0A%20%20%20%20end%0Aclick%20A%20%22growth_potential_growth%22%20%22Go%22%0Aclick%20B%20%22growth_env_factors%22%20%22Go%22%0Aclick%20C%20%22growth_species_specific%22%20%22Go%22%0Aclick%20L%20%22growth_env_factors%23Radiation-influence%22%20%22Go%22%0Aclick%20M%20%22growth_env_factors%23Temperature-influence%22%20%22Go%22%0Aclick%20N%20%22growth_env_factors%23Seasonal-effect%22%20%22Go%22%0Aclick%20F%20%22growth_species_specific%23Light-competition%22%20%22Go%22%0Aclick%20H%20%22growth_species_specific%23Water-stress%22%20%22Go%22%0Aclick%20I%20%22growth_species_specific%23Nutrient-stress%22%20%22Go%22%0Aclick%20P%20%22growth_species_specific%23Cost-for-investment-into-roots-and-mycorrhiza%22%20%22Go%22%0A"})]),fallback:i(()=>s[0]||(s[0]=[t(" Loading... ")])),_:1})),a("details",E,[a("summary",null,[s[1]||(s[1]=a("a",{id:"GrasslandTraitSim.growth!",href:"#GrasslandTraitSim.growth!"},[a("span",{class:"jlbinding"},"GrasslandTraitSim.growth!")],-1)),s[2]||(s[2]=t()),e(r,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),s[3]||(s[3]=g(`<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">growth!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span></span>
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
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Calculates the growth of the plant species.</p><p><strong>The growth of the plants is modelled by...</strong></p><ul><li><p><a href="/FelixNoessler.github.io/GrasslandTraitSim.jl/dev/model/plant/growth_potential_growth#Potential-growth-of-the-community">Potential growth of the community</a></p></li><li><p><a href="/FelixNoessler.github.io/GrasslandTraitSim.jl/dev/model/plant/growth_env_factors#Community-growth-adjustment-by-environmental-and-seasonal-factors">Community growth adjustment by environmental and seasonal factors</a></p></li><li><p><a href="/FelixNoessler.github.io/GrasslandTraitSim.jl/dev/model/plant/growth_species_specific#Species-specific-growth-adjustment">Species-specific growth adjustment</a></p></li></ul><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl" target="_blank" rel="noreferrer">source</a></p>`,5))])])}const B=p(m,[["render",k]]);export{b as __pageData,B as default};
