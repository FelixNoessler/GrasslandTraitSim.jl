import{_ as a,j as g,l as m}from"../app.BikqH_jL.js";import{s as n}from"./transform.CTqtca1M.js";var b=a((t,e)=>{let o;return e==="sandbox"&&(o=n("#i"+t)),(e==="sandbox"?n(o.nodes()[0].contentDocument.body):n("body")).select(`[id="${t}"]`)},"getDiagramElement"),B=a((t,e,o,i)=>{t.attr("class",o);const{width:r,height:s,x:h,y:x}=d(t,e);g(t,s,r,i);const c=l(h,x,r,s,e);t.attr("viewBox",c),m.debug(`viewBox configured: ${c} with padding: ${e}`)},"setupViewPortForSVG"),d=a((t,e)=>{var i;const o=((i=t.node())==null?void 0:i.getBBox())||{width:0,height:0,x:0,y:0};return{width:o.width+e*2,height:o.height+e*2,x:o.x,y:o.y}},"calculateDimensionsWithPadding"),l=a((t,e,o,i,r)=>`${t-r} ${e-r} ${o} ${i}`,"createViewBox");export{b as g,B as s};
