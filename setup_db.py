# creates the database in sqlite3 and adds data into it

import sqlite3
import os

if os.path.exists('db.sqlite'):
  os.remove('db.sqlite') # remove the database if it already exists

conn = sqlite3.connect('db.sqlite') # connect to the database
cursor = conn.cursor()

# create the flights table
cursor.execute('''
  CREATE TABLE flights (
    id INTEGER PRIMARY KEY,
    origin TEXT,
    destination TEXT,
    from_time TEXT,
    to_time TEXT,
    layover TEXT,
    price INTEGER,
    airline TEXT
  )
  ''')

# create the hotels table
cursor.execute('''
  CREATE TABLE hotels (
    id INTEGER PRIMARY KEY,
    city TEXT,
    name TEXT,
    quality TEXT,
    price DOUBLE,
    all_inclusive BOOLEAN
  )
  ''')

# insert data into the flights table, all flights are from 01/08/26 to 01/14/26
flights = [
  
  # flights to cancun
  ('SMF', 'CUN', '5:15AM', '4:51PM', 'Houston (IAH)', 438, 'United'), #sac to cancun
  ('SFO', 'CUN', '11:01PM', '5:50PM', None, 401, 'United'), # sf to cancun
  
  # flights to hawaii
  ('SMF', 'OGG', '9:13AM', '1:35PM', None, 278, 'Hawaiian'), # sac to kahului
  ('SFO', 'OGG', '7:00AM', '11:50PM', None, 198, 'Hawaiian'), # sf to kahului

  #flights to New York (JFK)
  ('SMF', 'JFK', '7:10AM', '3:45PM', None, 365, 'Delta'), # sac to nyc (1 stop)
  ('SFO', 'JFK', '9:00PM', '5:40PM', None, 342, 'United'), # sf to nyc (1 stop)

  #flights to Las Vegas (LAS)
  ('SMF', 'LAS', '6:16AM', '7:45PM', None, 120, 'Frontier'), # sac to las vegas 
  ('SFO', 'LAS', '10:30AM', '12:05PM', None, 129, 'Southwest'), # sf to las vegas 

  #flights to Miami (MIA)
  ('DEN', 'MIA', '8:00AM', '1:30PM', None, 310, 'American'), # denver to miami
  ('SFO', 'MIA', '11:45PM', '9:10AM', 'Atlanta (ATL)', 289, 'United'), # sf to miami with layover in Atlanta (2 stops)

  #flights to Tokyo (NRT)
  ('SFO', 'NRT', '5:30AM', '10:30PM', None, 845, 'Japan Airlines'), #sf to tokyo
  ('SMF', 'NRT', '6:30AM', '11:30PM', None, 890, 'Japan Airlines'), #sac to tokyo 

  #flights to Italy (FCO / MXP)
  ('SFO', 'FCO', '3:20PM', '12:10PM', 'Paris (CDG)', 915, 'Air France'), #sf to rome italy)
  ('LAS', 'MXP', '1:45PM', '11:30PM', 'London (LHR)', 1020, 'British Airways') # las vegas to milan italy 
  
]

# insert date into the hotels table
hotels = [

  ('Cancun', 'Hotel Xcaret', '5', 7314.40, True),
  ('Cancun', 'Hotel Riu Palace', '5', 2008.50, True),
  ('Maui', 'The Ritz-Carlton', '4.6', 4929, False),
  ('Maui', 'Four Seasons Resort', '4.7', 5663, False),
  ('New York', 'The Plaza Hotel', '4.7', 5290.90, False),
  ('New York', 'The Ritz-Carlton New York', '4.8', 5585.40, False),
  ('Las Vegas', 'The Venetian', '4.7', 3450, False),
  ('Las Vegas', 'Bellagio Hotel & Casino', '4.6', 5120.80, True),
  ('Miami', 'Fontainebleau Miami Beach', '4.5', 3675.89, False), 
  ('Miami', 'South Seas Resort', '4.6', 3890.90, True),
  ('Tokyo', 'Park Hyatt Tokyo', '4.7', 5340.20, False),
  ('Tokyo', 'Hotel New Otani', '4.6', 4890.50, False),
  ('Rome', 'The St. Regis Rome', '4.6', 4990.90, False),
  ('Rome', 'Rome Imperial Resort', '4.8', 6850, True),
  ('Milan', 'Grand Milano Palace Resort', '5', 7420.50, True),
  ('Milan', 'Duomo Elite Palace Resort', '5', 8420.75, True)
  
]

# insert flights into database
cursor.executemany("INSERT INTO flights (origin, destination, from_time, to_time, layover, price, airline) VALUES (?, ?, ?, ?, ?, ?, ?)", flights)

# insert hotels into database  
cursor.executemany("INSERT INTO hotels (city, name, quality, price, all_inclusive) VALUES (?, ?, ?, ?, ?)", hotels)

conn.commit()
conn.close()