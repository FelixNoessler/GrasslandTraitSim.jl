import{s as o,l as C}from"./chunks/transform.Deh2Sj5S.js";import{l as L}from"./chunks/linear.BlmCC_Hi.js";import{r as M}from"./chunks/range.OtVwhkKS.js";import{a as F,b as I}from"./chunks/axis.rlX7cRMw.js";import{v as O,c as P,j as a,a as y,b as $,w as D,a6 as J,a5 as b,G as z,B as A,o as v}from"./chunks/framework.DfrZ7YMs.js";import"./chunks/init.BFKUnIhM.js";function U(){const f=o("#grazing_graph"),d={top:20,right:30,bottom:45,left:50},t=+f.attr("width")-d.left-d.right,g=+f.attr("height")-d.top-d.bottom,s=f.append("g").attr("transform",`translate(${d.left},${d.top})`),p=L().range([0,t]).domain([0,5e3]),n=L().range([g,0]).domain([0,150]);s.append("g").attr("class","x-axis").attr("transform",`translate(0, ${g})`).call(F(p)),s.append("g").attr("class","y-axis").call(I(n)),s.append("text").attr("class","x-label").attr("x",t/2).attr("y",g+40).attr("text-anchor","middle").text("Total aboveground biomass accessible to grazers [kg ha⁻¹]"),s.append("text").attr("class","y-label").attr("x",-g/2).attr("y",-40).attr("transform","rotate(-90)").attr("text-anchor","middle").text("Total Grazed [kg ha⁻¹]");function _(r,m,h){return M(0,5e3,10).map(c=>{const u=c*c,x=h*m*r,w=h*m*u/(x*x+u);return{sum_biomass:c,total_grazed:w}})}function B(r,m,h){return M(0,5e3,10).map(c=>{const u=c*c,x=h*r,w=h*m*u/(x*x+u);return{sum_biomass:c,total_grazed:w}})}const G=C().x(r=>p(r.sum_biomass)).y(r=>n(r.total_grazed)),E=C().x(r=>p(r.sum_biomass)).y(r=>n(r.total_grazed));let l=1,i=2,e=22,j=_(l,i,e);const T=s.append("path").datum(j).attr("class","line").attr("fill","none").attr("stroke","steelblue").attr("stroke-width",2).attr("d",G),V=s.append("path").datum(j).attr("class","line").attr("fill","none").attr("stroke","steelblue").attr("stroke-width",2).attr("d",E),S=s.append("line").attr("x1",0).attr("x2",t).attr("y1",n(e*i)).attr("y2",n(e*i)).attr("stroke","black").attr("stroke-dasharray","4,4"),q=s.append("line").attr("x1",0).attr("x2",t).attr("y1",n(e*i/2)).attr("y2",n(e*i/2)).attr("stroke","grey").attr("stroke-dasharray","4,4"),R=s.append("circle").attr("r",5).attr("fill","orange").attr("cx",p(e*i*l)).attr("cy",n(e*i/2)),N=s.append("circle").attr("r",5).attr("fill","red").attr("cx",p(e*l)).attr("cy",n(e*i/2));function k(){l=+o("#η_GRZ").property("value"),i=+o("#LD").property("value"),e=+o("#κ").property("value"),o("#η_GRZ-value").text(l),o("#LD-value").text(i),o("#κ-value").text(e);let r=_(l,i,e),m=B(l,i,e);T.datum(r).transition().duration(500).attr("d",G),V.datum(m).transition().duration(500).attr("d",E),S.transition().duration(500).attr("y1",n(e*i)).attr("y2",n(e*i)),q.transition().duration(500).attr("y1",n(e*i/2)).attr("y2",n(e*i/2)),R.transition().duration(500).attr("cx",p(e*i*l)).attr("cy",n(e*i/2)),N.transition().duration(500).attr("cx",p(e*l)).attr("cy",n(e*i/2))}o("#η_GRZ").on("input",k),o("#LD").on("input",k),o("#κ").on("input",k),k()}const H={class:"jldocstring custom-block",open:""},K={class:"jldocstring custom-block",open:""},Q={class:"MathJax",jax:"SVG",display:"true",style:{direction:"ltr",display:"block","text-align":"center",margin:"1em 0",position:"relative"}},W={style:{overflow:"visible","min-height":"1px","min-width":"1px","vertical-align":"-0.452ex"},xmlns:"http://www.w3.org/2000/svg",width:"638.009ex",height:"2.149ex",role:"img",focusable:"false",viewBox:"0 -750 282000 950","aria-hidden":"true"},st=JSON.parse('{"title":"Mowing and grazing","description":"","frontmatter":{},"headers":[],"relativePath":"model/plant/mowing_grazing.md","filePath":"model/plant/mowing_grazing.md","lastUpdated":null}'),X={name:"model/plant/mowing_grazing.md"},rt=Object.assign(X,{setup(f){return O(()=>{U()}),(d,t)=>{const g=A("Mermaid"),s=A("Badge");return v(),P("div",null,[t[10]||(t[10]=a("h1",{id:"Mowing-and-grazing",tabindex:"-1"},[y("Mowing and grazing "),a("a",{class:"header-anchor",href:"#Mowing-and-grazing","aria-label":'Permalink to "Mowing and grazing {#Mowing-and-grazing}"'},"​")],-1)),(v(),$(J,null,{default:D(()=>[z(g,{id:"mermaid-3",class:"mermaid",graph:"flowchart%20LR%0A%20%20%20%20A%5BMowing%5D%20--%3E%20C%5BBiomass%20removal%20and%20height%20reduction%5D%0A%20%20%20%20B%5BGrazing%5D%20--%3E%20C%20%0A%0Aclick%20A%20%22mowing_grazing%23mowing%22%20%22Go%22%0Aclick%20B%20%22mowing_grazing%23grazing%22%20%22Go%22%0A"})]),fallback:D(()=>t[0]||(t[0]=[y(" Loading... ")])),_:1})),t[11]||(t[11]=b('<h2 id="mowing" tabindex="-1">Mowing <a class="header-anchor" href="#mowing" aria-label="Permalink to &quot;Mowing&quot;">​</a></h2><h3 id="visualization" tabindex="-1">Visualization <a class="header-anchor" href="#visualization" aria-label="Permalink to &quot;Visualization&quot;">​</a></h3><h3 id="api" tabindex="-1">API <a class="header-anchor" href="#api" aria-label="Permalink to &quot;API&quot;">​</a></h3>',3)),a("details",H,[a("summary",null,[t[1]||(t[1]=a("a",{id:"GrasslandTraitSim.mowing!",href:"#GrasslandTraitSim.mowing!"},[a("span",{class:"jlbinding"},"GrasslandTraitSim.mowing!")],-1)),t[2]||(t[2]=y()),z(s,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),t[3]||(t[3]=b(`<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">mowing!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    container,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    mowing_height,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    above_biomass,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actual_height</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Influence of mowing for plant species with different heights</p><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/d889eb2a64cd3a5621e2ea0fe1013b1ae640483c/src/3_biomass/3_management/2_mowing.jl#L1" target="_blank" rel="noreferrer">source</a></p>`,3))]),t[12]||(t[12]=b('<h2 id="grazing" tabindex="-1">Grazing <a class="header-anchor" href="#grazing" aria-label="Permalink to &quot;Grazing&quot;">​</a></h2><h3 id="Visualization-2" tabindex="-1">Visualization <a class="header-anchor" href="#Visualization-2" aria-label="Permalink to &quot;Visualization {#Visualization-2}&quot;">​</a></h3><table><colgroup><col><col width="80px"><col></colgroup><tbody><tr><td>η_GRZ</td><td><span id="η_GRZ-value">2</span></td><td><input type="range" min="0.1" max="20" step="0.1" value="1" id="η_GRZ"></td></tr><tr><td>Livestock Density (LD)</td><td><span id="LD-value">2</span></td><td><input type="range" min="0.1" max="5" step="0.1" value="2" id="LD" class="slider"></td></tr><tr><td>Maximal Consumption (κ)</td><td><span id="κ-value">22</span></td><td><input type="range" min="12" max="25" step="1" value="22" id="κ"></td></tr></tbody></table><p><svg width="600" height="400" id="grazing_graph"></svg></p><h3 id="API-2" tabindex="-1">API <a class="header-anchor" href="#API-2" aria-label="Permalink to &quot;API {#API-2}&quot;">​</a></h3>',5)),a("details",K,[a("summary",null,[t[4]||(t[4]=a("a",{id:"GrasslandTraitSim.grazing!",href:"#GrasslandTraitSim.grazing!"},[a("span",{class:"jlbinding"},"GrasslandTraitSim.grazing!")],-1)),t[5]||(t[5]=y()),z(s,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),t[8]||(t[8]=b('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">grazing!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; container, LD, above_biomass, actual_height)</span></span></code></pre></div>',1)),a("mjx-container",Q,[(v(),P("svg",W,t[6]||(t[6]=[a("g",{stroke:"currentColor",fill:"currentColor","stroke-width":"0",transform:"scale(1,-1)"},[a("g",{"data-mml-node":"math"},[a("g",{"data-mml-node":"merror","data-mjx-error":"'_' allowed only in math mode",title:"'_' allowed only in math mode"},[a("rect",{"data-background":"true",width:"282000",height:"950",y:"-200",style:{fill:"yellow",stroke:"none"}}),a("title",null,"'_' allowed only in math mode"),a("g",{"data-mml-node":"mtext",style:{fill:"red",stroke:"red","font-family":"serif"}},[a("text",{"data-variant":"-explicitFont",transform:"scale(1,-1)","font-size":"884px"},"\\begin{align} \\rho &= \\left(\\frac{LNCM}{LNCM_{cwm]}}\\right) ^ {\\text{β_PAL_lnc}} \\\\ μₘₐₓ &= κ \\cdot \\text{LD} \\\\ h &= \\frac{1}{μₘₐₓ} \\\\ a &= \\frac{1}{\\text{α_GRZ}^2 \\cdot h} \\\\ \\text{totgraz} &= \\frac{a \\cdot (\\sum \\text{biomass})^2} {1 + a\\cdot h\\cdot (\\sum \\text{biomass})^2} \\\\ \\text{share} &= \\frac{ \\rho \\cdot \\text{biomass}} {\\sum \\left[ \\rho \\cdot \\text{biomass} \\right]} \\\\ \\text{graz} &= \\text{share} \\cdot \\text{totgraz} \\end{align}")])])])],-1)]))),t[7]||(t[7]=a("mjx-assistive-mml",{unselectable:"on",display:"block",style:{top:"0px",left:"0px",clip:"rect(1px, 1px, 1px, 1px)","-webkit-touch-callout":"none","-webkit-user-select":"none","-khtml-user-select":"none","-moz-user-select":"none","-ms-user-select":"none","user-select":"none",position:"absolute",padding:"1px 0px 0px 0px",border:"0px",display:"block",overflow:"hidden",width:"100%"}},[a("math",{xmlns:"http://www.w3.org/1998/Math/MathML",display:"block"},[a("merror",{"data-mjx-error":"'_' allowed only in math mode",title:"'_' allowed only in math mode"},[a("mtext",null,"\\begin{align} \\rho &= \\left(\\frac{LNCM}{LNCM_{cwm]}}\\right) ^ {\\text{β_PAL_lnc}} \\\\ μₘₐₓ &= κ \\cdot \\text{LD} \\\\ h &= \\frac{1}{μₘₐₓ} \\\\ a &= \\frac{1}{\\text{α_GRZ}^2 \\cdot h} \\\\ \\text{totgraz} &= \\frac{a \\cdot (\\sum \\text{biomass})^2} {1 + a\\cdot h\\cdot (\\sum \\text{biomass})^2} \\\\ \\text{share} &= \\frac{ \\rho \\cdot \\text{biomass}} {\\sum \\left[ \\rho \\cdot \\text{biomass} \\right]} \\\\ \\text{graz} &= \\text{share} \\cdot \\text{totgraz} \\end{align}")])])],-1))]),t[9]||(t[9]=b('<ul><li><p><code>LD</code> daily livestock density [livestock units ha⁻¹]</p></li><li><p><code>κ</code> daily consumption of one livestock unit [kg], follows [<a href="/GrasslandTraitSim.jl/v0.1.1/references#Gillet2008">5</a>]</p></li><li><p><code>ρ</code> palatability, dependent on nitrogen per leaf mass (LNCM) [-]</p></li><li><p><code>α_GRZ</code> is the half-saturation constant [kg ha⁻¹]</p></li><li><p>equation partly based on [<a href="/GrasslandTraitSim.jl/v0.1.1/references#Moulin2021">6</a>]</p></li></ul><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/d889eb2a64cd3a5621e2ea0fe1013b1ae640483c/src/3_biomass/3_management/1_grazing.jl#L1" target="_blank" rel="noreferrer">source</a></p>',2))])])}}});export{st as __pageData,rt as default};
