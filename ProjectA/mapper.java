import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class mapper
        extends Mapper<LongWritable, Text, Text, Text> {
    @Override
    public void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        String str = value.toString().replace("\"", "");
        String[] flds = str.split(",");
        if (!flds[0].equals("Source Country") && flds.length == 10757) {
            int index = 0;
            for (int i = 0; i < 5; i++) {
                index = str.indexOf(",", index + 1);
            }
            String val = str.substring(index + 1); // get the measures only
            context.write(new Text(String.valueOf(flds[2]) + "_" + flds[3] + "_" + flds[4]), new Text(val));
        }
    }
}
