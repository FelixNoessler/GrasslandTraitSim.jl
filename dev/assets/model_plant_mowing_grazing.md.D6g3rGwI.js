import{s as o,l as G}from"./chunks/transform.CTqtca1M.js";import{l as E}from"./chunks/linear.W-vK1XZq.js";import{r as j}from"./chunks/range.OtVwhkKS.js";import{a as V,b as q}from"./chunks/axis.rlX7cRMw.js";import{v as O,c as L,a5 as f,j as e,a as C,G as M,B as $,o as T}from"./chunks/framework.DUg_Vbhg.js";import"./chunks/init.Dmth1JHB.js";function A(){const b=o("#grazing_graph"),d={top:20,right:30,bottom:45,left:50},t=+b.attr("width")-d.left-d.right,p=+b.attr("height")-d.top-d.bottom,r=b.append("g").attr("transform",`translate(${d.left},${d.top})`),g=E().range([0,t]).domain([0,5e3]),n=E().range([p,0]).domain([0,150]);r.append("g").attr("class","x-axis").attr("transform",`translate(0, ${p})`).call(V(g)),r.append("g").attr("class","y-axis").call(q(n)),r.append("text").attr("class","x-label").attr("x",t/2).attr("y",p+40).attr("text-anchor","middle").text("Total aboveground biomass accessible to grazers [kg ha⁻¹]"),r.append("text").attr("class","y-label").attr("x",-p/2).attr("y",-40).attr("transform","rotate(-90)").attr("text-anchor","middle").text("Total Grazed [kg ha⁻¹]");function w(s,m,h){return j(0,5e3,10).map(c=>{const u=c*c,x=h*m*s,k=h*m*u/(x*x+u);return{sum_biomass:c,total_grazed:k}})}function D(s,m,h){return j(0,5e3,10).map(c=>{const u=c*c,x=h*s,k=h*m*u/(x*x+u);return{sum_biomass:c,total_grazed:k}})}const v=G().x(s=>g(s.sum_biomass)).y(s=>n(s.total_grazed)),_=G().x(s=>g(s.sum_biomass)).y(s=>n(s.total_grazed));let l=1,i=2,a=22,z=w(l,i,a);const S=r.append("path").datum(z).attr("class","line").attr("fill","none").attr("stroke","steelblue").attr("stroke-width",2).attr("d",v),N=r.append("path").datum(z).attr("class","line").attr("fill","none").attr("stroke","steelblue").attr("stroke-width",2).attr("d",_),R=r.append("line").attr("x1",0).attr("x2",t).attr("y1",n(a*i)).attr("y2",n(a*i)).attr("stroke","black").attr("stroke-dasharray","4,4"),Z=r.append("line").attr("x1",0).attr("x2",t).attr("y1",n(a*i/2)).attr("y2",n(a*i/2)).attr("stroke","grey").attr("stroke-dasharray","4,4"),B=r.append("circle").attr("r",5).attr("fill","orange").attr("cx",g(a*i*l)).attr("cy",n(a*i/2)),F=r.append("circle").attr("r",5).attr("fill","red").attr("cx",g(a*l)).attr("cy",n(a*i/2));function y(){l=+o("#η_GRZ").property("value"),i=+o("#LD").property("value"),a=+o("#κ").property("value"),o("#η_GRZ-value").text(l),o("#LD-value").text(i),o("#κ-value").text(a);let s=w(l,i,a),m=D(l,i,a);S.datum(s).transition().duration(500).attr("d",v),N.datum(m).transition().duration(500).attr("d",_),R.transition().duration(500).attr("y1",n(a*i)).attr("y2",n(a*i)),Z.transition().duration(500).attr("y1",n(a*i/2)).attr("y2",n(a*i/2)),B.transition().duration(500).attr("cx",g(a*i*l)).attr("cy",n(a*i/2)),F.transition().duration(500).attr("cx",g(a*l)).attr("cy",n(a*i/2))}o("#η_GRZ").on("input",y),o("#LD").on("input",y),o("#κ").on("input",y),y()}const J={class:"jldocstring custom-block",open:""},I={class:"jldocstring custom-block",open:""},U={class:"MathJax",jax:"SVG",display:"true",style:{direction:"ltr",display:"block","text-align":"center",margin:"1em 0",position:"relative"}},H={style:{overflow:"visible","min-height":"1px","min-width":"1px","vertical-align":"-0.452ex"},xmlns:"http://www.w3.org/2000/svg",width:"638.009ex",height:"2.149ex",role:"img",focusable:"false",viewBox:"0 -750 282000 950","aria-hidden":"true"},et=JSON.parse('{"title":"Mowing and grazing","description":"","frontmatter":{},"headers":[],"relativePath":"model/plant/mowing_grazing.md","filePath":"model/plant/mowing_grazing.md","lastUpdated":null}'),K={name:"model/plant/mowing_grazing.md"},it=Object.assign(K,{setup(b){return O(()=>{A()}),(d,t)=>{const p=$("Badge");return T(),L("div",null,[t[9]||(t[9]=f('<h1 id="Mowing-and-grazing" tabindex="-1">Mowing and grazing <a class="header-anchor" href="#Mowing-and-grazing" aria-label="Permalink to &quot;Mowing and grazing {#Mowing-and-grazing}&quot;">​</a></h1><p>Biomass is removed by...</p><ul><li><p>🚜 <a href="/GrasslandTraitSim.jl/dev/model/plant/mowing_grazing#Mowing">mowing</a></p></li><li><p>🐄 <a href="/GrasslandTraitSim.jl/dev/model/plant/mowing_grazing#Grazing">grazing</a></p></li></ul><hr><h2 id="mowing" tabindex="-1">Mowing <a class="header-anchor" href="#mowing" aria-label="Permalink to &quot;Mowing&quot;">​</a></h2>',5)),e("details",J,[e("summary",null,[t[0]||(t[0]=e("a",{id:"GrasslandTraitSim.mowing!",href:"#GrasslandTraitSim.mowing!"},[e("span",{class:"jlbinding"},"GrasslandTraitSim.mowing!")],-1)),t[1]||(t[1]=C()),M(p,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),t[2]||(t[2]=f(`<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">mowing!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    container,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    mowing_height,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    above_biomass,</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actual_height</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><p>Influence of mowing for plant species with different heights</p><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/ceb98f2812fddc888e34bf2922af2b8e94ad1283/src/3_biomass/3_management/2_mowing.jl#L1" target="_blank" rel="noreferrer">source</a></p>`,3))]),t[10]||(t[10]=f('<hr><h2 id="grazing" tabindex="-1">Grazing <a class="header-anchor" href="#grazing" aria-label="Permalink to &quot;Grazing&quot;">​</a></h2><table><colgroup><col><col width="80px"><col></colgroup><tbody><tr><td>η_GRZ</td><td><span id="η_GRZ-value">2</span></td><td><input type="range" min="0.1" max="20" step="0.1" value="1" id="η_GRZ"></td></tr><tr><td>Livestock Density (LD)</td><td><span id="LD-value">2</span></td><td><input type="range" min="0.1" max="5" step="0.1" value="2" id="LD" class="slider"></td></tr><tr><td>Maximal Consumption (κ)</td><td><span id="κ-value">22</span></td><td><input type="range" min="12" max="25" step="1" value="22" id="κ"></td></tr></tbody></table><p><svg width="600" height="400" id="grazing_graph"></svg></p>',4)),e("details",I,[e("summary",null,[t[3]||(t[3]=e("a",{id:"GrasslandTraitSim.grazing!",href:"#GrasslandTraitSim.grazing!"},[e("span",{class:"jlbinding"},"GrasslandTraitSim.grazing!")],-1)),t[4]||(t[4]=C()),M(p,{type:"info",class:"jlObjectType jlFunction",text:"Function"})]),t[7]||(t[7]=f('<div class="language-julia vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">julia</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">grazing!</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(; container, LD, above_biomass, actual_height)</span></span></code></pre></div>',1)),e("mjx-container",U,[(T(),L("svg",H,t[5]||(t[5]=[e("g",{stroke:"currentColor",fill:"currentColor","stroke-width":"0",transform:"scale(1,-1)"},[e("g",{"data-mml-node":"math"},[e("g",{"data-mml-node":"merror","data-mjx-error":"'_' allowed only in math mode",title:"'_' allowed only in math mode"},[e("rect",{"data-background":"true",width:"282000",height:"950",y:"-200",style:{fill:"yellow",stroke:"none"}}),e("title",null,"'_' allowed only in math mode"),e("g",{"data-mml-node":"mtext",style:{fill:"red",stroke:"red","font-family":"serif"}},[e("text",{"data-variant":"-explicitFont",transform:"scale(1,-1)","font-size":"884px"},"\\begin{align} \\rho &= \\left(\\frac{LNCM}{LNCM_{cwm]}}\\right) ^ {\\text{β_PAL_lnc}} \\\\ μₘₐₓ &= κ \\cdot \\text{LD} \\\\ h &= \\frac{1}{μₘₐₓ} \\\\ a &= \\frac{1}{\\text{α_GRZ}^2 \\cdot h} \\\\ \\text{totgraz} &= \\frac{a \\cdot (\\sum \\text{biomass})^2} {1 + a\\cdot h\\cdot (\\sum \\text{biomass})^2} \\\\ \\text{share} &= \\frac{ \\rho \\cdot \\text{biomass}} {\\sum \\left[ \\rho \\cdot \\text{biomass} \\right]} \\\\ \\text{graz} &= \\text{share} \\cdot \\text{totgraz} \\end{align}")])])])],-1)]))),t[6]||(t[6]=e("mjx-assistive-mml",{unselectable:"on",display:"block",style:{top:"0px",left:"0px",clip:"rect(1px, 1px, 1px, 1px)","-webkit-touch-callout":"none","-webkit-user-select":"none","-khtml-user-select":"none","-moz-user-select":"none","-ms-user-select":"none","user-select":"none",position:"absolute",padding:"1px 0px 0px 0px",border:"0px",display:"block",overflow:"hidden",width:"100%"}},[e("math",{xmlns:"http://www.w3.org/1998/Math/MathML",display:"block"},[e("merror",{"data-mjx-error":"'_' allowed only in math mode",title:"'_' allowed only in math mode"},[e("mtext",null,"\\begin{align} \\rho &= \\left(\\frac{LNCM}{LNCM_{cwm]}}\\right) ^ {\\text{β_PAL_lnc}} \\\\ μₘₐₓ &= κ \\cdot \\text{LD} \\\\ h &= \\frac{1}{μₘₐₓ} \\\\ a &= \\frac{1}{\\text{α_GRZ}^2 \\cdot h} \\\\ \\text{totgraz} &= \\frac{a \\cdot (\\sum \\text{biomass})^2} {1 + a\\cdot h\\cdot (\\sum \\text{biomass})^2} \\\\ \\text{share} &= \\frac{ \\rho \\cdot \\text{biomass}} {\\sum \\left[ \\rho \\cdot \\text{biomass} \\right]} \\\\ \\text{graz} &= \\text{share} \\cdot \\text{totgraz} \\end{align}")])])],-1))]),t[8]||(t[8]=f('<ul><li><p><code>LD</code> daily livestock density [livestock units ha⁻¹]</p></li><li><p><code>κ</code> daily consumption of one livestock unit [kg], follows [<a href="/GrasslandTraitSim.jl/dev/references#Gillet2008">5</a>]</p></li><li><p><code>ρ</code> palatability, dependent on nitrogen per leaf mass (LNCM) [-]</p></li><li><p><code>α_GRZ</code> is the half-saturation constant [kg ha⁻¹]</p></li><li><p>equation partly based on [<a href="/GrasslandTraitSim.jl/dev/references#Moulin2021">6</a>]</p></li></ul><p><a href="https://github.com/FelixNoessler/GrasslandTraitSim.jl/blob/ceb98f2812fddc888e34bf2922af2b8e94ad1283/src/3_biomass/3_management/1_grazing.jl#L1" target="_blank" rel="noreferrer">source</a></p>',2))])])}}});export{et as __pageData,it as default};
