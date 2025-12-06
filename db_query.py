# used to select flights/hotels from the database

# Developers: Eric Kalinovskiy & Matfiy Gritsyuk

import sqlite3
import sys 

table_type = sys.argv[1]
search_term = sys.argv[2] 

conn = sqlite3.connect('db.sqlite')
cursor = conn.cursor()


# search logic
if table_type == 'flight':

  # search by destination city
  cursor.execute("SELECT * FROM flights WHERE destination=?", (search_term,))

elif table_type == 'hotel':

  # search by city
   cursor.execute("SELECT * FROM hotels WHERE city=?", (search_term,))

elif table_type == 'flight_id':
  cursor.execute("SELECT * FROM flights WHERE id=?", (search_term,))

elif table_type == 'hotel_id':
  cursor.execute("SELECT * FROM hotels WHERE id=?", (search_term,))

elif table_type == 'flight_price':
  cursor.execute("SELECT * FROM flights WHERE id=?", (search_term,))

elif table_type == 'hotel_price':
  cursor.execute("SELECT * FROM hotels WHERE id=?", (search_term,))

rows = cursor.fetchall()
for row in rows:

  # covert the row to a list so that we can modify the values (for the boolean)
  row_list = list(row)

  # standard output for flight search
  if table_type == 'flight':
    print(f"{row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} | {row[6]}")

  # standard output for hotel search   
  elif table_type == 'hotel':
      if row_list[5] == 1 or row_list[5] == 'True':
        row_list[5] = 'Yes'
      else:
        row_list[5] = 'No'
        
      # print the row using th updated list
      print(f"{row_list[0]} | {row_list[1]} | {row_list[2]} | {row_list[3]} | {row_list[4]} | {row_list[5]}")

  # flight format for reciept
  elif table_type == 'flight_id':
      # "Airline Flight: Origin -> Dest (Time) - $Price"
      print(f"{row_list[7]} Flight: {row_list[1]} ➡️ {row_list[2]} ({row_list[3]} to {row_list[4]}) - Price: ${row_list[6]}")

  # hotel format for reciept
  elif table_type == 'hotel_id':
      # "Hotel Name (City) - Rating - $Price"
      print(f"Hotel: {row_list[2]} ({row_list[1]}) - {row_list[3]} ⭐ - Price: ${row_list[4]}")

  # get flight price for total price
  elif table_type == 'flight_price':
    print(str(row_list[6]).strip())

  # get hotel price for total price
  elif table_type == 'hotel_price':
    print(str(row_list[4]).strip())
    
    

conn.close()