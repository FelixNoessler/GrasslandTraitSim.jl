import{p as V}from"./chunk-44GW5IO5.D0Ji8ZiA.js";import{N as z,_ as p,g as U,s as j,a as Z,b as q,p as H,o as J,l as G,c as K,C as Q,G as X,a2 as Y,d as tt,x as et,E as at}from"../app.Ct90SrKC.js";import{p as rt}from"./radar-VG2SY3DT.DYLUrPKt.js";import"./transform.C3Ugy-Ig.js";import{d as P}from"./arc.D9mKdhkY.js";import{o as nt}from"./ordinal.DqYi6Gfe.js";import{c as x,a as it}from"./line.BOw7RPPN.js";import"./framework.hNK5iCCb.js";import"./theme.BPZAF8ZP.js";import"./baseUniq.D-7s2l5e.js";import"./basePickBy.BfUjrF3u.js";import"./clone.Cin3I1ir.js";import"./init.Dmth1JHB.js";function st(t,a){return a<t?-1:a>t?1:a>=t?0:NaN}function ot(t){return t}function lt(){var t=ot,a=st,m=null,o=x(0),u=x(z),y=x(0);function i(e){var r,l=(e=it(e)).length,g,A,h=0,c=new Array(l),n=new Array(l),v=+o.apply(this,arguments),w=Math.min(z,Math.max(-z,u.apply(this,arguments)-v)),f,T=Math.min(Math.abs(w)/l,y.apply(this,arguments)),$=T*(w<0?-1:1),d;for(r=0;r<l;++r)(d=n[c[r]=r]=+t(e[r],r,e))>0&&(h+=d);for(a!=null?c.sort(function(S,C){return a(n[S],n[C])}):m!=null&&c.sort(function(S,C){return m(e[S],e[C])}),r=0,A=h?(w-l*$)/h:0;r<l;++r,v=f)g=c[r],d=n[g],f=v+(d>0?d*A:0)+$,n[g]={data:e[g],index:r,value:d,startAngle:v,endAngle:f,padAngle:T};return n}return i.value=function(e){return arguments.length?(t=typeof e=="function"?e:x(+e),i):t},i.sortValues=function(e){return arguments.length?(a=e,m=null,i):a},i.sort=function(e){return arguments.length?(m=e,a=null,i):m},i.startAngle=function(e){return arguments.length?(o=typeof e=="function"?e:x(+e),i):o},i.endAngle=function(e){return arguments.length?(u=typeof e=="function"?e:x(+e),i):u},i.padAngle=function(e){return arguments.length?(y=typeof e=="function"?e:x(+e),i):y},i}var ct=at.pie,F={sections:new Map,showData:!1},b=F.sections,N=F.showData,pt=structuredClone(ct),ut=p(()=>structuredClone(pt),"getConfig"),gt=p(()=>{b=new Map,N=F.showData,et()},"clear"),dt=p(({label:t,value:a})=>{b.has(t)||(b.set(t,a),G.debug(`added new section: ${t}, with value: ${a}`))},"addSection"),ft=p(()=>b,"getSections"),mt=p(t=>{N=t},"setShowData"),ht=p(()=>N,"getShowData"),R={getConfig:ut,clear:gt,setDiagramTitle:J,getDiagramTitle:H,setAccTitle:q,getAccTitle:Z,setAccDescription:j,getAccDescription:U,addSection:dt,getSections:ft,setShowData:mt,getShowData:ht},vt=p((t,a)=>{V(t,a),a.setShowData(t.showData),t.sections.map(a.addSection)},"populateDb"),St={parse:p(async t=>{const a=await rt("pie",t);G.debug(a),vt(a,R)},"parse")},xt=p(t=>`
  .pieCircle{
    stroke: ${t.pieStrokeColor};
    stroke-width : ${t.pieStrokeWidth};
    opacity : ${t.pieOpacity};
  }
  .pieOuterCircle{
    stroke: ${t.pieOuterStrokeColor};
    stroke-width: ${t.pieOuterStrokeWidth};
    fill: none;
  }
  .pieTitleText {
    text-anchor: middle;
    font-size: ${t.pieTitleTextSize};
    fill: ${t.pieTitleTextColor};
    font-family: ${t.fontFamily};
  }
  .slice {
    font-family: ${t.fontFamily};
    fill: ${t.pieSectionTextColor};
    font-size:${t.pieSectionTextSize};
    // fill: white;
  }
  .legend text {
    fill: ${t.pieLegendTextColor};
    font-family: ${t.fontFamily};
    font-size: ${t.pieLegendTextSize};
  }
`,"getStyles"),yt=xt,At=p(t=>{const a=[...t.entries()].map(o=>({label:o[0],value:o[1]})).sort((o,u)=>u.value-o.value);return lt().value(o=>o.value)(a)},"createPieArcs"),wt=p((t,a,m,o)=>{G.debug(`rendering pie chart
`+t);const u=o.db,y=K(),i=Q(u.getConfig(),y.pie),e=40,r=18,l=4,g=450,A=g,h=X(a),c=h.append("g");c.attr("transform","translate("+A/2+","+g/2+")");const{themeVariables:n}=y;let[v]=Y(n.pieOuterStrokeWidth);v??(v=2);const w=i.textPosition,f=Math.min(A,g)/2-e,T=P().innerRadius(0).outerRadius(f),$=P().innerRadius(f*w).outerRadius(f*w);c.append("circle").attr("cx",0).attr("cy",0).attr("r",f+v/2).attr("class","pieOuterCircle");const d=u.getSections(),S=At(d),C=[n.pie1,n.pie2,n.pie3,n.pie4,n.pie5,n.pie6,n.pie7,n.pie8,n.pie9,n.pie10,n.pie11,n.pie12],D=nt(C);c.selectAll("mySlices").data(S).enter().append("path").attr("d",T).attr("fill",s=>D(s.data.label)).attr("class","pieCircle");let W=0;d.forEach(s=>{W+=s}),c.selectAll("mySlices").data(S).enter().append("text").text(s=>(s.data.value/W*100).toFixed(0)+"%").attr("transform",s=>"translate("+$.centroid(s)+")").style("text-anchor","middle").attr("class","slice"),c.append("text").text(u.getDiagramTitle()).attr("x",0).attr("y",-400/2).attr("class","pieTitleText");const M=c.selectAll(".legend").data(D.domain()).enter().append("g").attr("class","legend").attr("transform",(s,E)=>{const k=r+l,L=k*D.domain().length/2,_=12*r,B=E*k-L;return"translate("+_+","+B+")"});M.append("rect").attr("width",r).attr("height",r).style("fill",D).style("stroke",D),M.data(S).append("text").attr("x",r+l).attr("y",r-l).text(s=>{const{label:E,value:k}=s.data;return u.getShowData()?`${E} [${k}]`:E});const I=Math.max(...M.selectAll("text").nodes().map(s=>(s==null?void 0:s.getBoundingClientRect().width)??0)),O=A+e+r+l+I;h.attr("viewBox",`0 0 ${O} ${g}`),tt(h,g,O,i.useMaxWidth)},"draw"),Ct={draw:wt},Pt={parser:St,db:R,renderer:Ct,styles:yt};export{Pt as diagram};
