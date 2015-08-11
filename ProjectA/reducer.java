import java.util.Iterator;
import java.io.IOException;

import org.apache.hadoop.io.DoubleWritable;

import java.util.Arrays;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class reducer
        extends Reducer<Text, Text, Text, Text> {
    @Override
    public void reduce(Text key, Iterable<Text> values,
                       Context context)
            throws IOException, InterruptedException {

        Iterator<Text> iter = values.iterator();
        context.write(key, iter.next());
    }
}
