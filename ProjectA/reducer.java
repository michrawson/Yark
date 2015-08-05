import java.io.IOException;
import org.apache.hadoop.io.DoubleWritable;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
public class reducer
extends Reducer<Text,DoubleWritable, Text, DoubleWritable> {
@Override
public void reduce(Text key, Iterable<DoubleWritable> values,
Context context)
throws IOException, InterruptedException {

double sum=0.0;
for (DoubleWritable value : values) {
        sum=sum+value.get();
     }
//	str = value.toSitring();
 //   System.out.println("Key:" + key.toString() + " Val:" + str );
//	if (str.contains(","))
//		{line = str.split(",");
 //       	PR += Double.parseDouble(line[1]);}
  //    		else
   //   		{output =  value.toString() ;}
//			}
				
context.write(key,new DoubleWritable(sum) );
}

}
