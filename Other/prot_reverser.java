import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.ArrayList;
import java.io.FileWriter;
import java.io.IOException;

public class prot_reverser{
     public static void main(String []args){
        try {
	    Scanner input = new Scanner(System.in);
	    System.out.println("Enter the name/path to the file: ");
	    String input_file = input.next();

            File fasta = new File(input_file);
            ArrayList<String> all_seqs = new ArrayList<String>();
            Scanner reader = new Scanner(fasta);
            String current_seq = "";

            while (reader.hasNextLine()) {
                String line = reader.nextLine();

		// If the line doesn't start with '>', then add the 
		// string to the end of the current_sequence. 

                if (!(line.charAt(0) == '>')) { 
                    current_seq = current_seq.concat(line);
                }

		// Use the reverser function to reverse the sequence.
		// Add the reversed sequence to the list of sequences.
		// Then reset the current sequence. 

                else {
                    all_seqs.add(reverser(current_seq));
		    current_seq = "";
                }
            }

	    all_seqs.add(reverser(current_seq));
	    
            reader.close();
            FileWriter writer = new FileWriter("dummy_reversed.fasta");
            int idx = 1;

            // The 0th element is going to be an empty string because of
            // the file starting with a '>' character.
	    all_seqs.remove(0);

            for (String sequence: all_seqs) {
                String seq_idx = Integer.toString(idx);
                writer.write(">REV_" + 
                ("00000" + seq_idx).substring(seq_idx.length()) + " reversed\n");
                writer.write(sequence + "\n\n");
                idx++;
            }
	    writer.close();            
        }
        catch (FileNotFoundException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
        catch (IOException f) {
            System.out.println("An error occurred.");
            f.printStackTrace();
        }
    }

    public static String reverser(String sequence) {
	String rev_seq = "";
	Integer rev_seq_pos = 0;
	for (int i = sequence.length() - 1; i > -1; i--) {
	    rev_seq = rev_seq + sequence.charAt(i);
	    rev_seq_pos++;

	    // Make it so that the sequence wraps 
	    // every 60 characters. 

	    if (rev_seq_pos == 60) {
	        rev_seq = rev_seq + "\n";
		rev_seq_pos = 0;
	    }
	}
	return rev_seq;
    }
}
