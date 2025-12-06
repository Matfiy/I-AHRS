#!/usr/bin/perl
# takes the final booking info and creates a web-viewable reciept

use strict;
use warnings;

# get arguments from BASH
my $traveler_string = $ARGV[0];
my $details = $ARGV[1];
my $total_price = $ARGV[2];

# use he first name in the list for file name
my @travelers = split(',', $traveler_string);
my $main_traveler = $travelers[0];

my $filename = "receipts/booking_$main_traveler.html";

# generating html
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

# link html to the css style sheet we copied into reciepts (for easier access)
print $fh "<html><head><title>Booking Receipt</title>";
print $fh "<link rel='stylesheet' type='text/css' href='style.css'>";
print $fh "</head><body>";

# header section and general receipt container section start
print $fh "<div class='receipt-container'>";
print $fh "  <div class ='header'>";
print $fh "    <h1>SwiftBook Systems Receipt</h1><p>Official Confirmation</p>";
print $fh "  </div>";

# customer that booked section
print $fh "  <div class='section-title'>Primary Traveler/Customer That Booked</div>";
print $fh "  <div class='info-block'><strong>$main_traveler</strong></div>";

# all other guests section
print $fh "  <div class='section-title'>All Guests</div>";
print $fh "  <div class='info-block'><ul>";
foreach my $name (@travelers) {
    print $fh "    <li>$name</li>";
}
print $fh "  </ul></div>";

# actual flight + hotel details section
print $fh "  <div class='section-title'>Itinerary Details</div>";
print $fh "  <div class='info-block'>$details</div>";

# total price section
print $fh "  <div class='section-title'>Total Amount Due</div>";
print $fh "  <div class='info-block' style='background: #e8f4ff; border: 2px solid #005a9c; color: #005a9c; font-size: 24px; font-weight: bold;'>";
print $fh "    \$$total_price";
print $fh "  </div>";

# footer
print $fh "  <div class='footer'><p>Thank you for choosing SwiftBook Systems.</p></div>";
print $fh "</div>";

print $fh "</body></html>";
close $fh;

# for terminal
print "Receipt generated at $filename\n";