file1 = "barcodes_awk1.txt"
file2 = "barcodes_awk2.txt"
file3 = "barcodes_awk3.txt"

x1 = open(file1, "r")
x2 = open(file2, "r")
x3 = open(file3, "r")

bc_dict= {}

x1.readline()
x2.readline()
x3.readline()

for line in x1:
	line = line.strip("\n").split("\t")
	if line[0] in bc_dict.keys():
		bc_dict[line[0]] += 1
	else:
		bc_dict[line[0]] = 1
	
print("Step 1 Complete")

for line in x2:
	line = line.strip("\n").split("\t")
	if line[0] in bc_dict.keys():
                bc_dict[line[0]] += 1
        else:
                bc_dict[line[0]] = 1

print("Step 2 Complete")

for line in x3:
	line = line.strip("\n").split("\t")	
	if line[0] in bc_dict.keys():
                bc_dict[line[0]] += 1
        else:
                bc_dict[line[0]] = 1

print("Step 3 Complete")

y = open("whitelist2.txt", "w")

#print(counts_dict)

for key in bc_dict:
	if bc_dict.key() > 15000:
		y.write(key + "\n")

x1.close()
x2.close()
x3.close()
y.close()
