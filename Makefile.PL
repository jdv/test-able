use inc::Module::Install;
  
# Define metadata
all_from       'lib/Test/Able.pm';
  
# Specific dependencies
requires       'Moose'         => '0.61';

WriteAll;
