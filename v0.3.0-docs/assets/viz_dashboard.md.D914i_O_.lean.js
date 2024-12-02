import{_ as i,c as a,a5 as t,o as e}from"./chunks/framework.jro5Z6fk.js";const l="/GrasslandTraitSim.jl/v0.3.0-docs/assets/dashboard.D_wpJOIs.png",g=JSON.parse('{"title":"Dashboard","description":"","frontmatter":{},"headers":[],"relativePath":"viz/dashboard.md","filePath":"viz/dashboard.md","lastUpdated":null}'),n={name:"viz/dashboard.md"};function p(h,s,r,o,d,k){return e(),a("div",null,s[0]||(s[0]=[t(`<h1 id="dashboard" tabindex="-1">Dashboard <a class="header-anchor" href="#dashboard" aria-label="Permalink to &quot;Dashboard&quot;">​</a></h1><p>The dashboard can be used to graphically check the calibration results. It shows the simulated total biomass, soil water content and the simulated community weighted mean traits for all grassland plots of the Biodiversity Exploratories.</p><p><code>GLMakie.jl</code> is used instead of <code>CairoMakie.jl</code> to take advantage of interactive features and must be loaded explicitly. What can be done:</p><ul><li><p>see simulation results for different grassland plots of the Biodiversity Exploratories with the <code>plotID</code></p></li><li><p>sample parameter values from the prior and in the future also from the posterior</p></li><li><p>manually change each parameter value, set Parameter to &quot;fixed (see right)&quot;</p></li><li><p>disable individual model components</p></li><li><p>view different abiotic inputs (e.g. precipitation, air temperature)</p></li><li><p>see the log likelihood for the simulated community weighted traits and the cut aboveground biomass, it is compared to measured data from the Biodiversity Exploratories</p></li><li><p>calculate the gradient of each parameter with respect to the log likelihood</p></li><li><p>show the timing of the grazing and mowing in the biomass plot</p></li><li><p>change the time step of the simulation: 1, 7, or 14 days</p></li><li><p>in all plots it is possible to zoom</p></li></ul><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> GrasslandTraitSim </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">as</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> GLMakie</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">GLMakie</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">activate!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">dashboard</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># note: if you want to switch back to CairoMakie</span></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># using CairoMakie; CairoMakie.activate!()</span></span></code></pre></div><details><summary>Code for generating static image for documentation</summary><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> GrasslandTraitSim </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">as</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span></span>
<span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">using</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> GLMakie</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">GLMakie</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">activate!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">()</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">dashboard</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; variable_p </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">load_optim_result</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(), path </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;dashboard.png&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div></details><p><img src="`+l+'" alt=""></p>',7)]))}const E=i(n,[["render",p]]);export{g as __pageData,E as default};
