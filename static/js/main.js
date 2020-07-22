var aColor=['#ca70e8','#f08d49','#7ec699','#cc99cd','#f8c555'];
window.onload=function(){
	//随机颜色
	var oStyle=document.createElement('style')
	var i=parseInt(Math.random()*100)%(aColor.length)
	oStyle.innerHTML="pre{color:"+aColor[i]+";}"
	document.body.append(oStyle);
	
	//add number for pre lines
	aPre=document.getElementsByTagName('pre');
	for(var j=0; j<aPre.length; j++){
		var oPre=aPre[j];
		var aText=oPre.innerText.split('\n');
		oPre.innerHTML="";
		for(i in aText){
			var text=aText[i]
			oSpan=document.createElement('span')
			oSpan.innerHTML=text;
			oSpan.append(document.createElement('br'))
			//
			if(i==aText.length-1 && text==''){
				break;
			}
			oPre.append(oSpan)
		}
	}
	
}