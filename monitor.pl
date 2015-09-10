#!/usr/bin/perl

use POSIX qw(strftime);


# Notes
# 1. mem calculation are made in k-bytes

my $temp_dir = "/tmp";
my $proc_name = "java -X";
my $dest_path = "/home/root";

my @record = ("", "", "", "", "");

sub ExecToStringArray {
  my $command = @_[0];

  system("$command > $temp_dir/perl_data.txt");
  open( $l, "$temp_dir/perl_data.txt" ) || die "Error : $!";
  my @lines = <$l>;
  close( $l );
  return @lines;
}

sub GetProcId {
  my @lines = ExecToStringArray("top -b -n1 -d2 | grep '$proc_name'");
  my @values = split(' ',$lines[0]);

  my $proc_id = $values[0];
  $record[1] = $proc_id;
}

sub GetCPU {   
  my @lines = ();
  my @values = ();
                                                                                                                                                         
  @lines = ExecToStringArray("top -b -n1 -d2 | grep '$proc_name'");                                                                                                           
  @values = split(' ',$lines[0]);                                                                                                                                             
  my $cpu_usage1 = substr($values[6], 0, -1);

  @lines = ExecToStringArray("top -b -n1 -d2 | grep '$proc_name'");                                                                                                           
  @values = split(' ',$lines[0]);                                                                                                                                             
  my $cpu_usage2 = substr($values[6], 0, -1); 

  @lines = ExecToStringArray("top -b -n1 -d2 | grep '$proc_name'");                                                                                                           
  @values = split(' ',$lines[0]);                                                                                                                                             
  my $cpu_usage3 = substr($values[6],0,-1);
                                                                                                                                                  
                                                                                                                                                    
  if($cpu_usage1 >= $cpu_usage2 && $cpu_usage1 >= $cpu_usage3 ) {
    $record[2] = $cpu_usage1;
  } 

  if ($cpu_usage2 >= $cpu_usage1 && $cpu_usage2 >= $cpu_usage3 )  {
    $record[2] = $cpu_usage2;
  }

  if ($cpu_usage3 >= $cpu_usage1 && $cpu_usage3 >= $cpu_usage2 )  {                                                                                                              
    $record[2] = $cpu_usage3;                                                                                                                                                    
  }                                                                                                                                                                              

}                                                                                                                                                                                

sub GetUsedMemPages {
  my $proc_id = $record[1];
  my @lines = ExecToStringArray("cat /proc/$proc_id/stat");
  my @values = split(' ', $lines[0] ); 
  my $mem_pages = $values[23];
  $record[3] = $mem_pages * 4; # in linux each page has 4k
}

sub GetMemUsedOtherPrograms {
  my $proc_id = $record[1];
  my @lines = ExecToStringArray("top -b -n1 | head -n 1");
  my @values = split(' ', $lines[0] );
  my $total_mem_used = substr($values[1], 0, -1);
  #print "other mem = $total_mem_used\n";          
  $record[4] = $total_mem_used;  
}



GetProcId();
GetCPU();
GetUsedMemPages();
GetMemUsedOtherPrograms();

#print "record: \n";
#print "time: $record[0]\n";
#print "proc id: $record[1]\n";
#print "cpu usage: $record[2]\n";
#print "mem usage: $record[3]\n";
#print "total mem used: $record[4]\n";

$record[0] = strftime "%Y-%m-%d %H:%M:%S", localtime;

# skip process id
system("echo '$record[0] $record[2] $record[3] $record[4]' >> $dest_path/trace.txt");
