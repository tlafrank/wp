For the host only network interface, replace the `dhcp: true` line with:
`addresses:`
` - 192.168.10.20/24`
or similar.

Run `sudo netplan generate` followed by `sudo netplan apply` to have the changes persist.
