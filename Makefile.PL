use inc::Module::Install;
  
# Define metadata
all_from       'lib/Test/Able.pm';
  
# Specific dependencies
requires       'Moose'         => '0.61';
requires       'Sub::Identify' => '0.03';

WriteAll;
