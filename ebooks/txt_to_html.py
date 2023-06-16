# -*- coding: utf-8 -*-

# import sys 
# import re

# it will retrieve input file from "input" folder, and output to "output" folder  
def txt_to_html (input_file_name, english_practice=False): 
    input_file = open("input/" + input_file_name + ".txt", "r", encoding='utf-8') 
    output_file_name = "output/" + input_file_name + ".html"
    
    template_html_part1 = open("html template//part1.html", "r", encoding='utf-8') 
    template_html_part2 = open("html template//part2.html", "r", encoding='utf-8') 
    
    
    output_file = open(output_file_name, "w", encoding='utf-8') 
    
    lines = template_html_part1.readlines() 
    for line in lines: 
        output_file.write(line) 
    
    output_file.write("\n") 
    lines = input_file.readlines() 
    for line in lines: 
        line = str(line).strip() 
        if len(line) == 0: continue 
        if line == "……": continue 
        
        line = line.replace("\"", "\\\"") 
        line = "\t\tcontent.push(\"" + str(line)  + "\"); \n" 
        # print(line)
        output_file.write(line)
    
    
    lines = template_html_part2.readlines() 
    for line in lines: 
        output_file.write(line) 
    
    input_file.close() 
    template_html_part1.close() 
    template_html_part2.close() 
    output_file.close()
    
    print(output_file_name, "complete") 

# This is for English listening practice, it repeats each line twice 
def repeat_sections_in_file(input_file_name): 
    # Open the input file and read the text
    with open("input/" + input_file_name + ".txt", 'r', encoding='utf-8') as file:
        text = file.read()
    
    output_file_name = "input/" + input_file_name + "_repeated.txt"
    
    # Split the text by empty lines (sections)
    sections = text.strip().split('\n\n')

    # Repeat each section twice
    repeated_sections = [section + '\n' + section for section in sections]

    # Join all the repeated sections into a single string
    output_text = '\n\n'.join(repeated_sections)

    # Write the output text to the output file
    with open(output_file_name, 'w', encoding='utf-8') as file:
        file.write(output_text)


#======================================================================
# Novels 
#======================================================================
# txt_to_html("input/liu_cixin.txt", "output/liu_cixin.html") 
# txt_to_html("input/west_military.txt", "output/west_military.html") 
# txt_to_html("input/story_of_civilization.txt", "output/story_of_civilization.html") 


# txt_to_html("input/best_rest.txt", "output/best_rest.html") 
# txt_to_html("input/predictably_irrational.txt", "output/predictably_irrational.html") 

# txt_to_html("input/the_end_of_history_and_the_last_man.txt", "output/the_end_of_history_and_the_last_man.html") 
# txt_to_html("input/poor_economics.txt", "output/poor_economics.html") 

# txt_to_html("input/low_desire_society.txt", "output/low_desire_society.html") 

# txt_to_html("input/egypt_4000_years.txt", "output/egypt_4000_years.html") 
# txt_to_html("input/egypt_revolutionary_archaeology.txt", "output/egypt_revolutionary_archaeology.html") 


# txt_to_html("input/fang_long_3_books.txt", "output/fang_long_3_books.html") 

# txt_to_html("input/great_books_translation.txt", "output/great_books_translation.html") 

#======================================================================
# English Listening Practice  
#======================================================================
# repeat_sections_in_file("english_ancient_egypt")
# txt_to_html("english_ancient_egypt_repeated") 

# repeat_sections_in_file("english_ramesses_ii")
# txt_to_html("english_ramesses_ii" + "_repeated") 

txt_to_html("english_vocab_list") 



