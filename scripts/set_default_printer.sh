#!/bin/bash

# Ensure cups packages are installed.
packages=("cups" "cups-pdf" "cups-client")

echo "Checking for required packages"

# Enable universe repo for cups-pdf availability.
sudo apt-add-repository -y universe 2>/dev/null
sudo apt-get update -qq

for package in "${packages[@]}"; do
  if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
    echo "$package is already installed."
  else
    echo "$package is not installed. Installing..."
    sudo apt-get install -y "$package" || echo "Warning: Failed to install $package, skipping."
  fi
done

echo "Starting CUPS service"

# GitHub Codespaces doesn't use systemd, so we need to start cups manually.
sudo /etc/init.d/cups start

echo "Setting default printer to PDF_Printer"

# Add PDF printer.
sudo lpadmin -p PDF_Printer -v cups-pdf:/ -E -m raw

# Enable the printer.
sudo cupsenable PDF_Printer

# Accept jobs for the printer.
sudo cupsaccept PDF_Printer

# Set the default printer.
sudo lpadmin -d PDF_Printer

# Check that the printer is set as default
default_printer=$(lpstat -d | awk '{print $4}')
if [ "$default_printer" == "PDF_Printer" ]; then
  echo "Default printer set to PDF_Printer"
else
  echo "Failed to set default printer."
fi
