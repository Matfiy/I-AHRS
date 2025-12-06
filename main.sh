#!/bin/bash

# --- 1. HANDLING FILES & DIRECTORIES ---
# Check if receipts folder exists, if not create it
if [ ! -d "receipts" ]; then
    mkdir receipts
fi

# copy css file for html
cp style.css receipts/

# initialize database
python3 setup_db.py > /dev/null

# function to validate input using Regex
validate_input() {
  if [[ ! "$1" =~ ^[a-zA-Z]+$ ]]; then
    echo "Error: Input must contain letters only."
    exit 1
  fi
}

# function to search flights (AWK Integration)
search_flights() {

  read -p "Enter Arrival Airport Code (e.g., CUN, OGG, JFK, LAS, NRT, FCO, MXP, MIA): " dest_code
  echo "" # spacing

  # validate input
  validate_input "$dest_code"

  echo "Searching flights to $dest_code..."
  echo ""
  sleep 2
  
  echo "Available Flights for 01/08/26 - 01/14/26"
  echo "------------------------------------------------------------------------------"
  echo -e "Flight #\t\tOrigin\tDest\tDeparture Time\tReturn Time\t\tPrice"
  echo "------------------------------------------------------------------------------"

  # call Python to get data, pipe to AWK to format it nicely
   python3 db_query.py "flight" "$dest_code" | awk -F'|' '{printf "%-14s %-7s %-7s %-15s %-15s $%s\n", $1, $2, $3, $4, $5, $7}'

   echo ""
  
}

# function to search hotels (AWK Integration)
search_hotels() {

  # default city name (to combat errors)
  city_name=""

  if [ -z "$dest_code" ]; then
    read -p "Enter City/Island Name (e.g., Maui, Cancun, New York, Las Vegas, Tokyo, Rome, Milano, Miami): " city_name
  elif [ "$dest_code" == 'CUN' ]; then
    city_name="Cancun"
  elif [ "$dest_code" == 'OGG' ]; then
    city_name="Maui"
  elif [ "$dest_code" == 'JFK' ]; then
    city_name="New York"
  elif [ "$dest_code" == 'LAS' ]; then
    city_name='Las Vegas'
  elif [ "$dest_code" == 'NRT' ]; then 
    city_name='Tokyo'
  elif [ "$dest_code" == 'FCO' ]; then
    city_name='Rome'
  elif [ "$dest_code" == 'MXP' ]; then
    city_name='Milano' 
  elif [ "$dest_code" == 'MIA' ]; then
    city_name='Miami'
  else 
    read -p "Enter City/Island Name (e.g., Maui, Cancun, New York, Las Vegas, Tokyo, Rome, Milano, Miami): " city_name
  fi

  # validate input
  validate_input "$city_name"

  echo "Searching hotels in $city_name..."
  echo ""
  sleep 2

  echo "Available Hotels for 01/08/26 - 01/14/26"
  echo "-----------------------------------------------------------------------------------------------"
  echo -e "ID\t\tName\t\t\t\t\tCity/Island\t\tRating\t\tAll-Inclusive\t\tPrice"
  echo "-----------------------------------------------------------------------------------------------"

  # call Python to get data, pipe to AWK to format it nicely
  python3 db_query.py "hotel" "$city_name" | awk -F'|' '{printf "%-6s %-23s %-15s %-11s %-20s $%s/ week\n", $1, $3, $2, $4, $6, $5}'

  echo ""

}

# function to search both flights and hotels (AWK Integration)
search_bundles() {

  search_flights
  search_hotels

  generate_receipt

}

# function to generate receipt (PERL Integration)
generate_receipt() {

  # list to store all traveler names
  traveler_names=()

  read -p "How many travelers are there? " num_travelers

  read -p "Enter your name: " traveler_name
  traveler_names+=("$traveler_name")

  if [ $num_travelers -gt 1 ]; then
    for ((i=1; i<=(num_travelers-1); i++)); do
      read -p "Enter Traveler #$i Name: " name
      traveler_names+=("$name")
    done
  fi

  # turn array into a string
  all_travelers_string=$(IFS=,; echo "${traveler_names[*]}")

  # --- 4. PERL INTEGRATION ---
  echo ""
  echo "Generating Receipt..."
  sleep 2 # Command 6

  # Call Perl to generate HTML receipt
  perl receipt_gen.pl "$all_travelers_string" "$booking_detail" "$total_price"

  # Change permission of the receipt so it's read-only for group/others
  chmod 644 "receipts/booking_$traveler_name.html" # Command 7

  # open the created receipt in browser
  # xdg-open "receipts/booking_$traveler_name.html"

  cd receipts
  python3 -m http.server 8000

  echo "Booking Complete! Check the receipts folder."

}

#  === main program ===


clear  # Command 1
echo " === Welcome to I-AHRS System ==="
echo "Today is: $(date)" # Command 2
echo "" # spacing

# prompt user choice
echo "What would you like to book today?"
echo "1. Flight Only"
echo "2. Hotel Only"
echo "3. Flight + Hotel Bundle"
read -p "Enter your choice: " choice
echo "" # spacing

booking_detail=""
total_price=0

# flight only option
if [ "$choice" == "1" ] || [ "$choice" == "Flight only" ]; then
    search_flights
    read -p "Enter the ID of the flight you want: " flight_id
    echo ""
    booking_detail="Flight ID: $flight_id"

    # fetch full flight details
    details=$(python3 db_query.py "flight_id" "$flight_id")
    booking_detail="$details"

    # get price and set total
    total_price=$(python3 db_query.py "flight_price" "$flight_id")
    
    generate_receipt

# hotel only option
elif [ "$choice" == "2" ]; then
    search_hotels
    read -p "Enter the ID of the flight you want: " hotel_id
    echo ""

    # fetch full hotel details
    details=$(python3 db_query.py "hotel_id" "$hotel_id")
    booking_detail="$details"

    # get price and set total
    total_price=$(python3 db_query.py "hotel_price" "$hotel_id")
    
    generate_receipt

# bundle option
elif [ "$choice" == "3" ]; then

    # search flights first
    search_flights
    read -p "Enter the ID of the flight you want: " flight_id
    echo ""

    # fetch full flight details
    flight_info=$(python3 db_query.py "flight_id" "$flight_id")
    flight_cost=$(python3 db_query.py "flight_price" "$flight_id")

    # make sure that the cost is something, not nothing
    if [ -z "$flight_cost" ]; then
      flight_cost=0;
    fi
    
    # search hotels next
    search_hotels
    read -p "Enter the ID of the flight you want: " hotel_id
    echo ""

    # fetch full hotel details
    hotel_info=$(python3 db_query.py "hotel_id" "$hotel_id")
    hotel_cost=$(python3 db_query.py "hotel_price" "$hotel_id")

    # make sure that the cost is something, not nothing
    if [ -z "$hotel_cost" ]; then
      hotel_cost=0;
    fi

    booking_detail="$flight_info <br> $hotel_info"

    # calculate total price
    total_price=$(awk "BEGIN{print $flight_cost + $hotel_cost}")

    generate_receipt
    
else
    echo "Invalid Selection"
    exit 1
fi

