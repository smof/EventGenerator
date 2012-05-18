#Simon Moffatt May 2012
#creates event files in different formats
#requires an ID file and Transactions file to be presented

#requires
require 'rubygems'
require 'date'
require 'csv'

#Globals and constants#######################################################################
IDENTITIES="ids.csv" #one user id and their corresponding ip address eg "smof,10.1.3.3"
EVENTS_PER_USER=10 #events spread across the entire date range randomly
TRANSACTIONS="transactions.csv" #one transaction per line
RESOURCE="PIX" #name of resource
START_DATE="2012/04/01" #YY/MM/DD
END_DATE="2012/04/07" #YY/MM/DD
TYPE="name_value" #options include: syslog, tab, name_value 
#non-configurable
OUTPUT_FILE="#{RESOURCE}_generated_events_#{TYPE}.dat"
CONSTRUCTED_EVENTS=[] #where the final events are pumped before output
#Globals and constants#######################################################################

def read_ids

  puts "Reading userids file..."

  #iterate over csv of identies and ip's, each row is passed to row[] and each field in row passed to generate_event
  CSV.foreach(IDENTITIES,{:col_sep => ",", :row_sep => "\n"}) do |row|
    
    generate_events(row[0],row[1])
        
  end

  puts "Reading userids file...FINISHED"

  #push events back out to new data file
  #write_events
  
end


def read_transactions
  
  puts "Reading transactions file..."

  @transactions =[]
  CSV.foreach(TRANSACTIONS) do |row|
    
    @transactions << row #push transaction pool into an array
    
  end

  puts "Reading transactions file...FINISHED"	   

  #read the id data file
# ' read_ids

end


#pulls out a date from specified date range.  returns DD/MM/YY format 
def get_date
  
  #array of all dates in range
  date_range = (Date.parse(START_DATE)..Date.parse(END_DATE)).to_a
  #pulls out a random date based on the Kernel randomizer going now higher than the array length
  date_range[Kernel.rand(date_range.length-1)].to_s
        
end

#creates a random time.  returns HH:MM:ss
def get_time
  
      #this is a bit nasty
     "#{Kernel.rand(24)}:#{Kernel.rand(60)}:#{Kernel.rand(60)}"
  
end

#randomly pulls out a transaction from the pumped in list of transactions via csv file
def get_transaction

  @transactions[Kernel.rand(@transactions.length-1)].to_s # @transactions global set in read_transactions

end


#creates a bunch events for a particular user
def generate_events(user,ip)

  puts "Generating Events..."

  1.upto(EVENTS_PER_USER) {
      
    #pushes a newly created event, formats it according and adds to global CONSTRUCTED_EVENTS array  
    CONSTRUCTED_EVENTS << construct_event(get_date, get_time, user, ip, get_transaction) 
    
  }

  puts "Generating Events...FINISHED"
    
end


#constructs the particular event data based on the required format
def construct_event(date, time, user, ip, transaction)
      
    if TYPE == "csv"
      
      csv(date, time, user, ip, transaction)
      
    elsif TYPE == "tab"
      
      tab(date, time, user, ip, transaction)
        
    elsif TYPE == "name_value"
      
      name_value(date, time, user, ip, transaction)
      
    else
      
      puts "Invalid format type entered"
      exit
      
    end
        
end


def syslog
  
end



def name_value(date, time, userid, src, transaction)
  #date=01/04/05,time=12:14:00, etc
  name_value_event="date=#{date}, time=#{time}, userid=#{userid}, src=#{src}, evt=#{transaction}"
  
end


def csv(date, time, userid, src, transaction)
  
  #01/04/05, 12:14:00, smof, 192.168.5.10, web login successful
  csv_event="#{date}, #{time}, #{userid}, #{src}, #{transaction}"
  
end


def tab(date, time, userid, src, transaction)
  
  #01/04/05 12:14:00  smof  192.168.5.10  web login successful
  csv_event="#{date}\t#{time}\t#{userid}\t#{src}\t#{transaction}"
  
end



#writes out to new events file specific for that resource
def write_events
  
  puts "Writing Events..."

  new_events_file = File.open(OUTPUT_FILE, 'w')
  CONSTRUCTED_EVENTS.each do |event| new_events_file.puts event end #basic puts but driven to open file
  new_events_file.close #closes

  puts "Writing Events...FINISHED"

end






#Run Through

puts "Starting event generator #{Time.now}"
puts "###############################################################################"
read_transactions
read_ids
write_events
puts "###############################################################################"
puts "Ended event generator #{Time.now}"
