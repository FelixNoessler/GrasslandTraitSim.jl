import{_ as e,l as o,G as i,j as n,H as p}from"../app.D-rBrFHn.js";import{p as g}from"./gitGraph-YCYPL57B.6kU-jn9e.js";import"./framework.DfrZ7YMs.js";import"./transform.Deh2Sj5S.js";import"./theme.bZF-iaOw.js";import"./baseUniq.o84pONAN.js";import"./basePickBy.3wFo-tZD.js";import"./clone.DCe1Z-Wh.js";var m={parse:e(async r=>{const a=await g("info",r);o.debug(a)},"parse")},v={version:p},d=e(()=>v.version,"getVersion"),c={getVersion:d},l=e((r,a,s)=>{o.debug(`rendering info diagram
`+r);const t=i(a);n(t,100,400,!0),t.append("g").append("text").attr("x",100).attr("y",40).attr("class","version").attr("font-size",32).style("text-anchor","middle").text(`v${s}`)},"draw"),f={draw:l},E={parser:m,db:c,renderer:f};export{E as diagram};