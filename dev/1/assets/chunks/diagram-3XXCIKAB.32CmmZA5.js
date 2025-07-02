import{p as y}from"./chunk-44GW5IO5.eXKZ1gSM.js";import{_ as l,s as B,g as S,p as z,o as E,a as F,b as P,C as m,G as W,d as D,x as T,D as _,E as A,l as x}from"../app.Be8t4nc_.js";import{p as N}from"./radar-VG2SY3DT.D-Oaa9H5.js";import"./framework.hNK5iCCb.js";import"./transform.C3Ugy-Ig.js";import"./line.BOw7RPPN.js";import"./theme.DsOMHzhB.js";import"./baseUniq.CpSWDmfm.js";import"./basePickBy.CK1dqoHP.js";import"./clone.D1D8eURu.js";var w={packet:[]},v=structuredClone(w),L=A.packet,Y=l(()=>{const t=m({...L,..._().packet});return t.showBits&&(t.paddingY+=10),t},"getConfig"),G=l(()=>v.packet,"getPacket"),I=l(t=>{t.length>0&&v.packet.push(t)},"pushWord"),M=l(()=>{T(),v=structuredClone(w)},"clear"),u={pushWord:I,getPacket:G,getConfig:Y,clear:M,setAccTitle:P,getAccTitle:F,setDiagramTitle:E,getDiagramTitle:z,getAccDescription:S,setAccDescription:B},O=1e4,H=l(t=>{y(t,u);let e=-1,o=[],s=1;const{bitsPerRow:i}=u.getConfig();for(let{start:a,end:r,bits:c,label:f}of t.blocks){if(a!==void 0&&r!==void 0&&r<a)throw new Error(`Packet block ${a} - ${r} is invalid. End must be greater than start.`);if(a??(a=e+1),a!==e+1)throw new Error(`Packet block ${a} - ${r??a} is not contiguous. It should start from ${e+1}.`);if(c===0)throw new Error(`Packet block ${a} is invalid. Cannot have a zero bit field.`);for(r??(r=a+(c??1)-1),c??(c=r-a+1),e=r,x.debug(`Packet block ${a} - ${e} with label ${f}`);o.length<=i+1&&u.getPacket().length<O;){const[d,p]=K({start:a,end:r,bits:c,label:f},s,i);if(o.push(d),d.end+1===s*i&&(u.pushWord(o),o=[],s++),!p)break;({start:a,end:r,bits:c,label:f}=p)}}u.pushWord(o)},"populate"),K=l((t,e,o)=>{if(t.start===void 0)throw new Error("start should have been set during first phase");if(t.end===void 0)throw new Error("end should have been set during first phase");if(t.start>t.end)throw new Error(`Block start ${t.start} is greater than block end ${t.end}.`);if(t.end+1<=e*o)return[t,void 0];const s=e*o-1,i=e*o;return[{start:t.start,end:s,label:t.label,bits:s-t.start},{start:i,end:t.end,label:t.label,bits:t.end-i}]},"getNextFittingBlock"),R={parse:l(async t=>{const e=await N("packet",t);x.debug(e),H(e)},"parse")},U=l((t,e,o,s)=>{const i=s.db,a=i.getConfig(),{rowHeight:r,paddingY:c,bitWidth:f,bitsPerRow:d}=a,p=i.getPacket(),n=i.getDiagramTitle(),k=r+c,g=k*(p.length+1)-(n?0:r),b=f*d+2,h=W(e);h.attr("viewbox",`0 0 ${b} ${g}`),D(h,g,b,a.useMaxWidth);for(const[C,$]of p.entries())X(h,$,C,a);h.append("text").text(n).attr("x",b/2).attr("y",g-k/2).attr("dominant-baseline","middle").attr("text-anchor","middle").attr("class","packetTitle")},"draw"),X=l((t,e,o,{rowHeight:s,paddingX:i,paddingY:a,bitWidth:r,bitsPerRow:c,showBits:f})=>{const d=t.append("g"),p=o*(s+a)+a;for(const n of e){const k=n.start%c*r+1,g=(n.end-n.start+1)*r-i;if(d.append("rect").attr("x",k).attr("y",p).attr("width",g).attr("height",s).attr("class","packetBlock"),d.append("text").attr("x",k+g/2).attr("y",p+s/2).attr("class","packetLabel").attr("dominant-baseline","middle").attr("text-anchor","middle").text(n.label),!f)continue;const b=n.end===n.start,h=p-2;d.append("text").attr("x",k+(b?g/2:0)).attr("y",h).attr("class","packetByte start").attr("dominant-baseline","auto").attr("text-anchor",b?"middle":"start").text(n.start),b||d.append("text").attr("x",k+g).attr("y",h).attr("class","packetByte end").attr("dominant-baseline","auto").attr("text-anchor","end").text(n.end)}},"drawWord"),j={draw:U},q={byteFontSize:"10px",startByteColor:"black",endByteColor:"black",labelColor:"black",labelFontSize:"12px",titleColor:"black",titleFontSize:"14px",blockStrokeColor:"black",blockStrokeWidth:"1",blockFillColor:"#efefef"},J=l(({packet:t}={})=>{const e=m(q,t);return`
	.packetByte {
		font-size: ${e.byteFontSize};
	}
	.packetByte.start {
		fill: ${e.startByteColor};
	}
	.packetByte.end {
		fill: ${e.endByteColor};
	}
	.packetLabel {
		fill: ${e.labelColor};
		font-size: ${e.labelFontSize};
	}
	.packetTitle {
		fill: ${e.titleColor};
		font-size: ${e.titleFontSize};
	}
	.packetBlock {
		stroke: ${e.blockStrokeColor};
		stroke-width: ${e.blockStrokeWidth};
		fill: ${e.blockFillColor};
	}
	`},"styles"),nt={parser:R,db:u,renderer:j,styles:J};export{nt as diagram};
