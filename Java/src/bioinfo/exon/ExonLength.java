package bioinfo.exon;
import java.io.*;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
//全部塞入内存不够。
public class ExonLength {

	public static void main(String[] args) throws IOException, InterruptedException {
		//System.out.println(Integer.MAX_VALUE);//2147483647=2,147,483,647
		String fileName="D:\\coding\\Java\\CCDS.20160908.txt";
		BufferedReader reader = new BufferedReader(new FileReader(fileName));
		String currentString = null;
		int lineNumber = 0;//行号
		
		HashMap<String,HashSet<String>> map=new HashMap<String,HashSet<String>>(); 
		HashSet<String> hsAll=new HashSet<String>();
		
		//一次读一行，读入null时文件结束
		while ((currentString = reader.readLine()) != null) {
			//当前行号
			lineNumber++; if(lineNumber>2000) break;
			
			//正则表达式分割
			if(lineNumber>1000){
				currentString=currentString.replace("[", "");
				currentString=currentString.replace("]", "");
				String[] arr=currentString.split("[\\t]+");//tab separate string
				String chr=arr[0];
				String ccds=arr[9];
				HashSet<String> hs=	getSet(chr,ccds);//从每一行的chr和ccd获得ccd长度
				
				if(map.containsKey(chr)){
					hs.addAll(map.get(chr));
				}
				map.put(chr, hs);
				if(lineNumber%100==0)System.out.println("chr"+chr+" size: "+map.get(chr).size());
				//printHashSet(hs);
				//System.out.println(getSet(getChrCCD(arr)).size());
			}
			if(lineNumber>-1){
				//System.out.println("lineNumber " + lineNumber + ": " + currentString);
			}
			
		}
		System.out.println(hsAll.size());
		//close file
		reader.close();
	}
	
	
	//输入chr和ccd数组
	//返回有多少键值对： chr-坐标
	static HashSet<String> getSet(String chr,String ccd){
		//新建一个集合，分别塞进这些数
		HashSet<String> hs=new HashSet<String>();
		//String chr=arr[0]; String ccd=arr[1];
		if(!ccd.equals("-")){
			String[] arr2=ccd.split("[,\\s]+");//用,分割
			for (int i = 0; i < arr2.length; i++) {
				String[] arr3=arr2[i].split("[-]+");//用-分割
				int start=Integer.parseInt(arr3[0]);
				int end=Integer.parseInt(arr3[1]);
				for(int n=start;n<=end;n++){
					hs.add(chr +"-"+ n);
				}
			}
		}
		return hs;
	}
	
	//打印hashset
	static void printHashSet(HashSet<String> hs){
		//
		for (Iterator iterator = hs.iterator(); iterator.hasNext();) {
			String str = (String) iterator.next();
			System.out.println(str);
			
		}
	}
	
	//打印数组
	static void printArr(String[] arr){
		//System.out.print("[");
		String comma=", ";
		for (int i = 0; i < arr.length; i++) {
			if(i==arr.length-1) comma="";
			System.out.print(i+"="+arr[i]+comma);
		}
		//System.out.println("]");
		System.out.println();
	}

}
