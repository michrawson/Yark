/**************************************************
 * PROJECT YARK

/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

package pig_udf;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

import java.io.IOException;

public class CustomDateConvert extends EvalFunc<String> {
    public String exec(Tuple input) throws IOException {
        if (input == null || input.size() == 0) {
            return null;
        }
        try {
            String[] arr = ((String) input.get(0)).split("/");
            if (arr.length != 3) {
                return null;
            }
            return Integer.toString((Integer.parseInt(arr[2]) * 100 * 100) +
                    (Integer.parseInt(arr[0]) * 100) +
                    Integer.parseInt(arr[1]));
        } catch (Exception e) {
            throw new IOException("Caught exception processing input row ", e);
        }
    }
}
