%%
clear; close all; clc

prot = 'A';
prot = char(prot);

%%
aa_string = "";
num_recorder = zeros(1, length(prot));

for i=1:length(prot)
    if upper(prot(i)) == 'A'
        aa_string = aa_string + "Alenine ";
        num_recorder(1, i) = 1;
    elseif upper(prot(i)) == 'G'
        aa_string = aa_string + "Glycine ";
        num_recorder(1, i) = 2;
    elseif upper(prot(i)) == 'I'
        aa_string = aa_string + "Isoleucine ";
        num_recorder(1, i) = 3;
    elseif upper(prot(i)) == 'L'
        aa_string = aa_string + "Leucine ";
        num_recorder(1, i) = 4;
    elseif upper(prot(i)) == 'P'
        aa_string = aa_string + "Proline ";
        num_recorder(1, i) = 5;
    elseif upper(prot(i)) == 'V'
        aa_string = aa_string + "Valine ";
        num_recorder(1, i) = 6;
    elseif upper(prot(i)) == 'F'
        aa_string = aa_string + "Phenylalenine ";
        num_recorder(1, i) = 7;
    elseif upper(prot(i)) == 'W'
        aa_string = aa_string + "Tryptophan ";
        num_recorder(1, i) = 8;
    elseif upper(prot(i)) == 'Y'
        aa_string = aa_string + "Tyrosine ";
        num_recorder(1, i) = 9;
    elseif upper(prot(i)) == 'D'
        aa_string = aa_string + "Aspartic Acid ";
        num_recorder(1, i) = 10;
    elseif upper(prot(i)) == 'E'
        aa_string = aa_string + "Glutamic Acid ";
        num_recorder(1, i) = 11;
    elseif upper(prot(i)) == 'R'
        aa_string = aa_string + "Arginine ";
        num_recorder(1, i) = 12;
    elseif upper(prot(i)) == 'H'
        aa_string = aa_string + "Histidine ";
        num_recorder(1, i) = 13;
    elseif upper(prot(i)) == 'K'
        aa_string = aa_string + "Lysine ";
        num_recorder(1, i) = 14;
    elseif upper(prot(i)) == 'S'
        aa_string = aa_string + "Serine ";
        num_recorder(1, i) = 15;
    elseif upper(prot(i)) == 'T'
        aa_string = aa_string + "Threonine ";
        num_recorder(1, i) = 16;
    elseif upper(prot(i)) == 'C'
        aa_string = aa_string + "Cysteine ";
        num_recorder(1, i) = 17;
    elseif upper(prot(i)) == 'M'
        aa_string = aa_string + "Methionine ";
        num_recorder(1, i) = 18;
    elseif upper(prot(i)) == 'N'
        aa_string = aa_string + "Aspargine ";
        num_recorder(1, i) = 19;
    elseif upper(prot(i)) == 'Q'
        aa_string = aa_string + "Glutamine ";
        num_recorder(1, i) = 20;
    else 
        aa_string = aa_string + "??? ";
        num_recorder(1, i) = -1;
    end
end

disp(aa_string)