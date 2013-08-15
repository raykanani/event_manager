require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "885db71fd32a41be8dbba443cefadee2"

#turns nil into 00000
#adds 0's to zipcodes < 5 digits
#slices zipcodes > 5 digits
def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

#method accepts a single zip code as a parameter and 
#returns a legislator data
def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

#saves the HTML letter to a file base on id of attendee
def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

#lets user know event manager is running
puts "EventManager Initialized."

#opens and reads CSV file for data
#removes headers from dataset
#turns header data to symbol
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

#sets variable template_letter to HTML file in root
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

#assign an ID for the attendee
#Create an output folder for each individual email
#Save each form letter to a file base on the id of the attendee
contents.each do |row|
	id = row[0]
	name = row[:first_name]

	zipcode = clean_zipcode(row[:zipcode])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id, form_letter)
end

