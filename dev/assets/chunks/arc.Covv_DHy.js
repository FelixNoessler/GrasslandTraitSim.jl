import{w as ln,c as M}from"./line.DYQfzRr6.js";import{I as rn,K as y,L as on,M as W,N as I,O as _,P as un,Q as an,R as B,S as t,T as sn,V as tn,W as fn}from"../app.DgAvETTl.js";function cn(l){return l.innerRadius}function yn(l){return l.outerRadius}function gn(l){return l.startAngle}function mn(l){return l.endAngle}function pn(l){return l&&l.padAngle}function dn(l,h,q,O,v,R,N,r){var D=q-l,i=O-h,n=N-v,m=r-R,u=m*D-n*i;if(!(u*u<y))return u=(n*(h-R)-m*(l-v))/u,[l+u*D,h+u*i]}function U(l,h,q,O,v,R,N){var r=l-q,D=h-O,i=(N?R:-R)/B(r*r+D*D),n=i*D,m=-i*r,u=l+n,s=h+m,f=q+n,c=O+m,Q=(u+f)/2,o=(s+c)/2,p=f-u,g=c-s,A=p*p+g*g,T=v-R,P=u*c-f*s,E=(g<0?-1:1)*B(fn(0,T*T*A-P*P)),K=(P*g-p*E)/A,L=(-P*p-g*E)/A,w=(P*g+p*E)/A,d=(-P*p+g*E)/A,x=K-Q,e=L-o,a=w-Q,V=d-o;return x*x+e*e>a*a+V*V&&(K=w,L=d),{cx:K,cy:L,x01:-n,y01:-m,x11:K*(v/T-1),y11:L*(v/T-1)}}function vn(){var l=cn,h=yn,q=M(0),O=null,v=gn,R=mn,N=pn,r=null,D=ln(i);function i(){var n,m,u=+l.apply(this,arguments),s=+h.apply(this,arguments),f=v.apply(this,arguments)-rn,c=R.apply(this,arguments)-rn,Q=un(c-f),o=c>f;if(r||(r=n=D()),s<u&&(m=s,s=u,u=m),!(s>y))r.moveTo(0,0);else if(Q>on-y)r.moveTo(s*W(f),s*I(f)),r.arc(0,0,s,f,c,!o),u>y&&(r.moveTo(u*W(c),u*I(c)),r.arc(0,0,u,c,f,o));else{var p=f,g=c,A=f,T=c,P=Q,E=Q,K=N.apply(this,arguments)/2,L=K>y&&(O?+O.apply(this,arguments):B(u*u+s*s)),w=_(un(s-u)/2,+q.apply(this,arguments)),d=w,x=w,e,a;if(L>y){var V=sn(L/u*I(K)),C=sn(L/s*I(K));(P-=V*2)>y?(V*=o?1:-1,A+=V,T-=V):(P=0,A=T=(f+c)/2),(E-=C*2)>y?(C*=o?1:-1,p+=C,g-=C):(E=0,p=g=(f+c)/2)}var j=s*W(p),z=s*I(p),F=u*W(T),G=u*I(T);if(w>y){var H=s*W(g),J=s*I(g),X=u*W(A),Y=u*I(A),S;if(Q<an)if(S=dn(j,z,X,Y,H,J,F,G)){var Z=j-S[0],$=z-S[1],k=H-S[0],b=J-S[1],nn=1/I(tn((Z*k+$*b)/(B(Z*Z+$*$)*B(k*k+b*b)))/2),en=B(S[0]*S[0]+S[1]*S[1]);d=_(w,(u-en)/(nn-1)),x=_(w,(s-en)/(nn+1))}else d=x=0}E>y?x>y?(e=U(X,Y,j,z,s,x,o),a=U(H,J,F,G,s,x,o),r.moveTo(e.cx+e.x01,e.cy+e.y01),x<w?r.arc(e.cx,e.cy,x,t(e.y01,e.x01),t(a.y01,a.x01),!o):(r.arc(e.cx,e.cy,x,t(e.y01,e.x01),t(e.y11,e.x11),!o),r.arc(0,0,s,t(e.cy+e.y11,e.cx+e.x11),t(a.cy+a.y11,a.cx+a.x11),!o),r.arc(a.cx,a.cy,x,t(a.y11,a.x11),t(a.y01,a.x01),!o))):(r.moveTo(j,z),r.arc(0,0,s,p,g,!o)):r.moveTo(j,z),!(u>y)||!(P>y)?r.lineTo(F,G):d>y?(e=U(F,G,H,J,u,-d,o),a=U(j,z,X,Y,u,-d,o),r.lineTo(e.cx+e.x01,e.cy+e.y01),d<w?r.arc(e.cx,e.cy,d,t(e.y01,e.x01),t(a.y01,a.x01),!o):(r.arc(e.cx,e.cy,d,t(e.y01,e.x01),t(e.y11,e.x11),!o),r.arc(0,0,u,t(e.cy+e.y11,e.cx+e.x11),t(a.cy+a.y11,a.cx+a.x11),o),r.arc(a.cx,a.cy,d,t(a.y11,a.x11),t(a.y01,a.x01),!o))):r.arc(0,0,u,T,A,o)}if(r.closePath(),n)return r=null,n+""||null}return i.centroid=function(){var n=(+l.apply(this,arguments)+ +h.apply(this,arguments))/2,m=(+v.apply(this,arguments)+ +R.apply(this,arguments))/2-an/2;return[W(m)*n,I(m)*n]},i.innerRadius=function(n){return arguments.length?(l=typeof n=="function"?n:M(+n),i):l},i.outerRadius=function(n){return arguments.length?(h=typeof n=="function"?n:M(+n),i):h},i.cornerRadius=function(n){return arguments.length?(q=typeof n=="function"?n:M(+n),i):q},i.padRadius=function(n){return arguments.length?(O=n==null?null:typeof n=="function"?n:M(+n),i):O},i.startAngle=function(n){return arguments.length?(v=typeof n=="function"?n:M(+n),i):v},i.endAngle=function(n){return arguments.length?(R=typeof n=="function"?n:M(+n),i):R},i.padAngle=function(n){return arguments.length?(N=typeof n=="function"?n:M(+n),i):N},i.context=function(n){return arguments.length?(r=n??null,i):r},i}export{vn as d};
