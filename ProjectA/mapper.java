import java.io.IOException;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.LongWritable;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class mapper
extends Mapper<LongWritable, Text, Text, DoubleWritable> {
@Override
public void map(LongWritable key, Text value, Context context)
throws IOException, InterruptedException {

   String[] flds = value.toString().split(",");
      double sum=0.0;
  // double PR = Double.parseDouble(pages[pages.length-1])/numLinks;
       for (int i=6;i<flds.length-1;i++){ //
             if (! flds[0].equals("Source Country"))
	      sum = sum + Double.parseDouble(flds[i]);
                //  context.write(new Text (pages[i]),new Text(outKey +  "," + String.valueOf(PR)));
               //   System.out.println( pages[i] + " " + outKey + "," + String.valueOf(PR) );
     
           }

           context.write(new Text(flds[0]),    new DoubleWritable(sum));




     //  pages[pages.length-1]="";  //set PR to empty to distinguish the original line from the rest

  //     context.write(new Text(pages[0]),    new Text(join(pages,' ',1, pages.length-1 )));
//       System.out.println( pages[0] + " " + join(pages,' ',1, pages.length-1 ));
           }


String join (String[] pages, char separator)
{
	return join(pages,separator, 0, pages.length);
}
 String join (String[] pages, char separator, int start, int end )
 {
	 String retStr="";
	 for (int i = start; i<end; i++)
	 {
		 retStr += pages[i] + separator; 
	 }
	 retStr = retStr.substring(0, retStr.length()-1);
	return retStr;
 }
       }
     




