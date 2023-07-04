#!/usr/bin/expect

set timeout 20
set username "admin"
set password "admin"

spawn asadmin change-admin-password --user $username

expect "Enter the admin password>"
send "\r"
expect "Enter the new admin password>"
send "$password\r"
expect "Enter the new admin password again>"
send "$password\r"

expect eof
