package bioinfo.exon;
import java.io.*;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
/**
 * 逐个染色体统计的，可以大概15s。因为内存不够用，无法分析全部的。
 * 
 * */
public class ExonLength2 {
	static String fileName="D:\\coding\\Java\\CCDS.20160908.txt";
	
	public static void main(String[] args) throws IOException, InterruptedException {
		String[] chrs=getChrs();
		Arrays.sort(chrs);
		int exonTotalLength=0;
		for (int i = 0; i < chrs.length; i++) {
			int length=calcCDSbyChr(chrs[i]);
			exonTotalLength += length;
		}
		System.out.println("总长度："+exonTotalLength);
	}
	
	//从文件总获取染色体列表
	private static String[] getChrs() throws IOException {
		BufferedReader reader = new BufferedReader(new FileReader(fileName));
		String currentString = null;
		int lineNumber = 0;//行号
		
		HashSet<String> chrs=new HashSet<String>();
		
		//一次读一行，读入null时文件结束
		while ((currentString = reader.readLine()) != null) {
			//当前行号
			lineNumber++; //if(lineNumber>22000) break;
			if(lineNumber>1){
				currentString=currentString.replace("[", "");
				currentString=currentString.replace("]", "");
				String[] arr=currentString.split("[\\t]+");//tab separate string
				String chr=arr[0]; 
				chrs.add(chr);
			}
		}
		return chrs.toArray(new String[chrs.size()]);
	}
	
	//按照染色体计算cds长度
	static int calcCDSbyChr(String targetChr) throws IOException{
		BufferedReader reader = new BufferedReader(new FileReader(fileName));
		String currentString = null;
		int lineNumber = 0;//行号
		
		HashSet<String> hsAll=new HashSet<String>();
		int counter=0;//计数器
		
		//一次读一行，读入null时文件结束
		while ((currentString = reader.readLine()) != null) {
			//当前行号
			lineNumber++; //if(lineNumber>22000) break;
			
			//正则表达式分割
			if(lineNumber>1){
				currentString=currentString.replace("[", "");
				currentString=currentString.replace("]", "");
				String[] arr=currentString.split("[\\t]+");//tab separate string
				String chr=arr[0]; 
				String ccds=arr[9];
				
				if(!chr.equals(targetChr)){
					continue;
				}else{
					counter++;
				}
				
				HashSet<String> hs=	getSet(chr,ccds);//从每一行的chr和ccd获得ccd长度
				hsAll.addAll(hs);
			}
		}
		
		System.out.println("chr"+targetChr+"共"+counter+"/"+lineNumber+"行, 独特位点个数："+hsAll.size());
		//close file
		reader.close();
		return hsAll.size();
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
