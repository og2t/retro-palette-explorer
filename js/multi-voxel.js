var MultiVoxel,bind=function(t,i){return function(){return t.apply(i,arguments)}};MultiVoxel=function(){function t(t,i,e,s){var r,l,h,a,o,n,d;this.canvas=t;this.cols=e!=null?e:40;this.rows=s!=null?s:25;this.clear=bind(this.clear,this);this.cells=this.rows*this.cols;this.lh=Utils.getArray(this.cells);this.cr=Utils.getArray(this.cells);this.ll=Utils.getArray(this.cells);this.mapping=new Array(this.cells);for(h=a=0,d=this.cells;0<=d?a<d:a>d;h=0<=d?++a:--a){this.mapping[h]={lh:null,cr:null,ll:null}}this.image=new Image;this.image.onload=i;this.image.src="assets/iso-blocks.png";this.context=this.canvas.getContext("2d");l=window.devicePixelRatio||1;r=this.context.backingStorePixelRatio||1;this.ratio=l/r;n=this.canvas.width;o=this.canvas.height;this.canvas.width=n*this.ratio;this.canvas.height=o*this.ratio;this.canvas.style.width=n+"px";this.canvas.style.height=o+"px";return}t.prototype.clear=function(t){var i,e,s;if(t==null){t=0}for(i=e=0,s=this.cells;0<=s?e<s:e>s;i=0<=s?++e:--e){this.lh[i]=t;this.cr[i]=t;this.ll[i]=t}};t.prototype.drawVoxel=function(t,i,e,s,r,l){this.drawTop(t,i,e,1,l);this.drawTop(t,i,e,0,l);this.drawSide(t,i,r,1,l);this.drawSide(t,i,s,0,l)};t.prototype.drawTop=function(t,i,e,s,r){var l,h,a,o;l=i*this.cols;o=t+s;h=l+o;a=l+o+40;if((t&1)===0){this.cr[h]=e;this.mapping[h].cr={read:r,side:"T"}}else{this.ll[h]=e;this.lh[a]=e;this.mapping[h].ll={read:r,side:"T"};this.mapping[a].lh={read:r,side:"T"}}};t.prototype.drawSide=function(t,i,e,s,r){var l,h,a,o,n;l=i*this.cols;n=t+s;h=l+n;a=l+n+40;o=l+n+80;if((t&1)===0){this.ll[h]=e;this.lh[a]=e;this.cr[a]=e;this.mapping[h].ll={read:r,side:s?"R":"L"};this.mapping[a].lh={read:r,side:s?"R":"L"};this.mapping[a].cr={read:r,side:s?"R":"L"}}else{this.ll[a]=e;this.cr[a]=e;this.lh[o]=e;this.mapping[a].ll={read:r,side:s?"R":"L"};this.mapping[a].cr={read:r,side:s?"R":"L"};this.mapping[o].lh={read:r,side:s?"R":"L"}}};t.prototype.toWord=function(t,i){if(i==null){i=0}return("0000"+(parseInt(t)+i).toString(16)).substr(-4)};t.prototype.getByWriteSideAndNibble=function(t,i,e){var s,r,l,h,a;a=this.writes;for(s=r=0,l=a.length;r<l;s=++r){h=a[s];if(h.write===t&&h.side===i&&h.cell===e){return this.writes.splice(s,1)[0]}}};t.prototype.printAddr=function(){var t,i,e,s,r,l,h,a,o,n,d,c,g,p,w,f,u,m,x,v,y;y=0;e={};g={};s={};f=0;y=0;this.writes=[];u=this.mapping;for(v=l=0,d=u.length;l<d;v=++l){p=u[v];if(p.cr!=null){this.writes.push({cell:"C",write:v,read:p.cr.read,side:p.cr.side,ram:"C"})}if(p.lh!=null){this.writes.push({cell:"H",write:v,read:p.lh.read,side:p.lh.side,ram:"S"})}if(p.ll!=null){this.writes.push({cell:"L",write:v,read:p.ll.read,side:p.ll.side,ram:"S"})}}this.writes.sort(Utils.dynamicMultiSort("read","side","cell","write"));n=null;m=this.writes;for(h=0,c=m.length;h<c;h++){p=m[h];if(p.read!==n){console.log("----------------------------------------------")}console.log("read:","$"+this.toWord(p.read),"  side:",p.side,"  write:","$"+this.toWord(p.write),"  cell:",p.cell);n=p.read}this.written={};for(r=a=0,x=this.cells;0<=x?a<x:a>x;r=0<=x?++a:--a){this.written[r]=false}o={side:null,read:null};i="";i+="routine:\nldy offset\n";while(this.writes.length>0){p=this.writes.shift();t="";w="";if(p.side!==o.side||p.read!==o.read){if(p.read!==o.read){w+="ldx texture + $"+this.toWord(p.read)+",y\n"}console.log("%c read:  $"+this.toWord(p.read)+" side: "+p.side+" ","background: #060; color: #fff");w+="lda "+p.side.toLowerCase()+"LUT,x\n";console.log(w);f++}y++;o=p;console.log("%c write: $"+this.toWord(p.write)+" cell: "+p.cell+" ","background: #a00; color: #fff");if(p.cell==="C"){t+="sta $d800   + $"+this.toWord(p.write)+"\n"}if(p.cell==="H"){t+="sta screen1 + $"+this.toWord(p.write)+"\n"}if(p.cell==="L"){t+="sta screen2 + $"+this.toWord(p.write)+"\n"}i+=w;i+=t;console.log(t)}i+="rts\n";console.log("Reads:",f);console.log("Writes:",y);FileSaver.saveAsTextFile(i)};t.prototype.render=function(){var t,i,e,s,r,l,h,a,o,n,d,c,g,p,w,f,u,m;m=8;d=8;i=8;t=8;p=0*8;o=1*8;c=2*8;w=3*8;n=4*8;u=5*8;this.context.save();this.context.imageSmoothingEnabled=false;this.context.scale(this.ratio,this.ratio);for(r=l=0,h=this.cells;0<=h?l<h:l>h;r=0<=h?++l:--l){e=r%this.cols*8;s=Math.floor(r/40)*8;g=this.lh[r]*8;a=this.cr[r]*8;f=this.ll[r]*8;if(r%2===0){this.context.drawImage(this.image,g,p,m,d,e,s,i,t);this.context.drawImage(this.image,a,o,m,d,e,s,i,t);this.context.drawImage(this.image,f,c,m,d,e,s,i,t)}else{this.context.drawImage(this.image,g,w,m,d,e,s,i,t);this.context.drawImage(this.image,a,n,m,d,e,s,i,t);this.context.drawImage(this.image,f,u,m,d,e,s,i,t)}}this.context.restore()};return t}();