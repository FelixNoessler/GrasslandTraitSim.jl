import{_ as a,c as i,a5 as n,o as t}from"./chunks/framework.DUg_Vbhg.js";const g=JSON.parse('{"title":"Getting started","description":"","frontmatter":{},"headers":[],"relativePath":"basics.md","filePath":"basics.md","lastUpdated":null}'),l={name:"basics.md"};function p(e,s,h,r,k,d){return t(),i("div",null,s[0]||(s[0]=[n(`<h1 id="Getting-started" tabindex="-1">Getting started <a class="header-anchor" href="#Getting-started" aria-label="Permalink to &quot;Getting started {#Getting-started}&quot;">​</a></h1><p><code>GrasslandTraitSim.jl</code> is a Julia package for simulating plant dynamics in managed grasslands.</p><p>Author: <a href="https://github.com/FelixNoessler/" target="_blank" rel="noreferrer">Felix Nößler</a><br></p><p>Licence: <a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/master/LICENSE" target="_blank" rel="noreferrer">GPL-3.0</a></p><h2 id="installation" tabindex="-1">Installation <a class="header-anchor" href="#installation" aria-label="Permalink to &quot;Installation&quot;">​</a></h2><ol><li><p><a href="https://julialang.org/downloads/" target="_blank" rel="noreferrer">Download Julia</a>.</p></li><li><p>Launch Julia and type</p></li></ol><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> Pkg</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Pkg</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">add</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(url</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;">&quot;https://github.com/felixnoessler/GrasslandTraitSim.jl&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h2 id="Run-simulations" tabindex="-1">Run simulations <a class="header-anchor" href="#Run-simulations" aria-label="Permalink to &quot;Run simulations {#Run-simulations}&quot;">​</a></h2><p>For more details, see the tutorials on <a href="/GrasslandTraitSim.jl/dev/tutorials/how_to_prepare_input#How-to-prepare-the-input-data-to-start-a-simulation">preparing inputs</a> and <a href="/GrasslandTraitSim.jl/dev/tutorials/how_to_analyse_output#How-to-analyse-the-model-output">analysing outputs</a>.</p><div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">import</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> GrasslandTraitSim </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">as</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">trait_input </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">input_traits</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">();</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">nspecies </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;"> length</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(trait_input</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">amc)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">input_obj </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">validation_input</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; plotID </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> &quot;HEG01&quot;</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, nspecies);</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">p </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">SimulationParameter</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">();</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sol </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">=</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> sim</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">solve_prob</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; input_obj, p, trait_input);</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sol</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">output</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">.</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">biomass</span></span></code></pre></div><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>╭──────────────────────────────────────────────────────────────────────────────╮</span></span>
<span class="line"><span>│ 5844×1×1×71 DimArray{Unitful.Quantity{Float64, 𝐌 𝐋^-2, Unitful.FreeUnits{(ha^-1, kg), 𝐌 𝐋^-2, nothing}},4} state_biomass │</span></span>
<span class="line"><span>├──────────────────────────────────────────────────────────────────────── dims ┤</span></span>
<span class="line"><span>  ↓ time    Sampled{Dates.Date} Dates.Date(&quot;2006-01-01&quot;):Dates.Day(1):Dates.Date(&quot;2021-12-31&quot;) ForwardOrdered Regular Points,</span></span>
<span class="line"><span>  → x       Sampled{Int64} 1:1 ForwardOrdered Regular Points,</span></span>
<span class="line"><span>  ↗ y       Sampled{Int64} 1:1 ForwardOrdered Regular Points,</span></span>
<span class="line"><span>  ⬔ species Sampled{Int64} 1:71 ForwardOrdered Regular Points</span></span>
<span class="line"><span>└──────────────────────────────────────────────────────────────────────────────┘</span></span>
<span class="line"><span>[:, :, 1, 1]</span></span>
<span class="line"><span> ↓ →                                 1</span></span>
<span class="line"><span>  2006-01-01  70.4225 kg ha^-1</span></span>
<span class="line"><span>  2006-01-02  70.4203 kg ha^-1</span></span>
<span class="line"><span>  2006-01-03  70.4181 kg ha^-1</span></span>
<span class="line"><span> ⋮                    </span></span>
<span class="line"><span>  2021-12-28  91.1422 kg ha^-1</span></span>
<span class="line"><span>  2021-12-29  91.1337 kg ha^-1</span></span>
<span class="line"><span>  2021-12-30  91.1253 kg ha^-1</span></span>
<span class="line"><span>  2021-12-31  91.1174 kg ha^-1</span></span></code></pre></div>`,11)]))}const E=a(l,[["render",p]]);export{g as __pageData,E as default};
