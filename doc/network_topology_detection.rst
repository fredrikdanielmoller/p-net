Network topology detection
==========================


LLDP
----
Link Layer Discovery Protocol (LLDP) is used to find information on the closest
neighbours on an Ethernet network. Each IO-device, IO-controller and (managed)
switch send out frames containing its name and the port name, for each of their
Ethernet ports.

LLDP packets should be sent every 5 seconds, and have a time-to-live value of 20 seconds.

Managed switches filter LLDP frames, and send its own LLDP frames.
That way everyone can know what is their closest neighbour. Only LLDP frames from
the closest neighbour is received on each port, thanks to the filtering done by
the switch.


SNMP
----
It is possible to ask an IO-Controller or IO-device (conformance class B or
higher) about its neighbours, using the Simple Network Management Protocol (SNMP).

SNMP agents collect information on individual devices, and the SNMP manager
retrieves information from them.

Some of the information can also be queried via the Profinet DCE/RPC protocol.

SNMP versions:

* v1 Mandatory for Profinet IO-devices and IO-Controllers
* v2c Supports 64-bit statistical counters
* v3 Encrypted


Monitor incoming LLDP frames on Linux
-------------------------------------
Install the ``lldpd`` daemon::

   $ sudo apt install lldpd

It will start to collect information automatically, but also start sending
LLDP packets every 30 seconds.

Show neighbour information::

   $ lldpcli show neighbors
   -------------------------------------------------------------------------------
   LLDP neighbors:
   -------------------------------------------------------------------------------
   Interface:    enp0s31f6, via: LLDP, RID: 1, Time: 0 day, 00:00:26
   Chassis:
      ChassisID:    local b
      SysName:      sysName Not Set
      SysDescr:     Siemens, SIMATIC NET, SCALANCE X204IRT, 6GK5 204-0BA00-2BA3, HW: Version 9, FW: Version V05.04.02, SVPL6147920
      MgmtIP:       192.168.0.99
      Capability:   Station, on
   Port:
      PortID:       local port-003
      PortDescr:    Siemens, SIMATIC NET, Ethernet Port, X1 P3
      TTL:          20
   Unknown TLVs:
      TLV:          OUI: 00,0E,CF, SubType: 1, Len: 20 00,00,01,BC,00,00,00,00,00,00,04,63,00,00,00,00,00,00,00,00
      TLV:          OUI: 00,0E,CF, SubType: 2, Len: 4 00,00,00,00
      TLV:          OUI: 00,0E,CF, SubType: 5, Len: 6 20,87,56,FF,AA,83
   -------------------------------------------------------------------------------

To stop the daemon (to avoid sending additional LLDP packets)::

   sudo service lldpd stop


SNMP agents
------------
Linux uses net-snmp as agent, see http://www.net-snmp.org/
The package name on Debian/Ubuntu is ``snmpd``.

To install it on for example a Raspberry Pi::

   sudo apt install -y snmpd

Include the ``snmpd`` daemon in a Yocto build by using the ``net-snmp`` recipe.


SNMPwalk tool for querying SNMP agents
--------------------------------------
To install ``snmpwalk`` and standard description files on Ubuntu::

   sudo apt install snmp snmp-mibs-downloader

Use ``snmpwalk`` to read all info from a device. This is the result when
querying a Siemens Profinet-enabled switch::

   $ snmpwalk -v2c -c public 192.168.0.99
   iso.3.6.1.2.1.1.1.0 = STRING: "Siemens, SIMATIC NET, SCALANCE X204IRT, 6GK5 204-0BA00-2BA3, HW: Version 9, FW: Version V05.04.02, SVPL6147920"
   iso.3.6.1.2.1.1.2.0 = OID: iso.3.6.1.4.1.4196.1.1.5.2.5
   iso.3.6.1.2.1.1.3.0 = Timeticks: (602966) 1:40:29.66
   iso.3.6.1.2.1.1.4.0 = STRING: "sysContact Not Set"
   iso.3.6.1.2.1.1.5.0 = STRING: "sysName Not Set"
   iso.3.6.1.2.1.1.6.0 = STRING: "sysLocation Not Set"
   iso.3.6.1.2.1.1.7.0 = INTEGER: 67
   iso.3.6.1.2.1.2.1.0 = INTEGER: 5
   iso.3.6.1.2.1.2.2.1.1.1 = INTEGER: 1
   iso.3.6.1.2.1.2.2.1.1.2 = INTEGER: 2
   iso.3.6.1.2.1.2.2.1.1.3 = INTEGER: 3
   iso.3.6.1.2.1.2.2.1.1.4 = INTEGER: 4
   iso.3.6.1.2.1.2.2.1.1.1000 = INTEGER: 1000
   iso.3.6.1.2.1.2.2.1.2.1 = STRING: "Siemens, SIMATIC NET, Ethernet Port, X1 P1"
   iso.3.6.1.2.1.2.2.1.2.2 = STRING: "Siemens, SIMATIC NET, Ethernet Port, X1 P2"
   iso.3.6.1.2.1.2.2.1.2.3 = STRING: "Siemens, SIMATIC NET, Ethernet Port, X1 P3"
   iso.3.6.1.2.1.2.2.1.2.4 = STRING: "Siemens, SIMATIC NET, Ethernet Port, X1 P4"
   iso.3.6.1.2.1.2.2.1.2.1000 = STRING: "Siemens, SIMATIC NET, internal, X1"
   iso.3.6.1.2.1.2.2.1.3.1 = INTEGER: 6
   iso.3.6.1.2.1.2.2.1.3.2 = INTEGER: 6
   iso.3.6.1.2.1.2.2.1.3.3 = INTEGER: 6
   iso.3.6.1.2.1.2.2.1.3.4 = INTEGER: 6
   iso.3.6.1.2.1.2.2.1.3.1000 = INTEGER: 6
   iso.3.6.1.2.1.2.2.1.4.1 = INTEGER: 1500
   iso.3.6.1.2.1.2.2.1.4.2 = INTEGER: 1500
   iso.3.6.1.2.1.2.2.1.4.3 = INTEGER: 1500
   iso.3.6.1.2.1.2.2.1.4.4 = INTEGER: 1500
   iso.3.6.1.2.1.2.2.1.4.1000 = INTEGER: 1500
   iso.3.6.1.2.1.2.2.1.5.1 = Gauge32: 100000000
   iso.3.6.1.2.1.2.2.1.5.2 = Gauge32: 100000000
   iso.3.6.1.2.1.2.2.1.5.3 = Gauge32: 100000000
   iso.3.6.1.2.1.2.2.1.5.4 = Gauge32: 10000000
   iso.3.6.1.2.1.2.2.1.5.1000 = Gauge32: 0
   iso.3.6.1.2.1.2.2.1.6.1 = Hex-STRING: 20 87 56 FF AA 84
   iso.3.6.1.2.1.2.2.1.6.2 = Hex-STRING: 20 87 56 FF AA 85
   iso.3.6.1.2.1.2.2.1.6.3 = Hex-STRING: 20 87 56 FF AA 86
   iso.3.6.1.2.1.2.2.1.6.4 = Hex-STRING: 20 87 56 FF AA 87
   iso.3.6.1.2.1.2.2.1.6.1000 = Hex-STRING: 20 87 56 FF AA 83
   iso.3.6.1.2.1.2.2.1.7.1 = INTEGER: 1
   iso.3.6.1.2.1.2.2.1.7.2 = INTEGER: 1
   (etc)

Use the command line argument ``-v`` for the SNMP version to use, and ``-c``
for the "community string" which is a password.
The default community string for devices is often "public".

The values in the left column are the OID (Object Identifier) values.
For example ``1.3.6.1.2.1.2.2.1.6.3`` is used for the MAC address of the third
interface of the device. It can be interpreted as:

* 1 = iso
* 3 = identified-organization
* 6 = dod (US department of defence)
* 1 = internet
* 2 = mgmt
* 1 = mib-2
* 2 = interfaces
* 2 = ifTable
* 1 = ifEntry
* 6 = ifPhysAddress
* 3 = Third interface

To convert the digits to human readable text, a MIB (Management Information
Base) text file is used.

The example OID is defined in the ``IF-MIB``, which describes interface
information. The text is from :rfc:`2863`,
and typically installed in ``/var/lib/snmp/mibs/ietf/IF-MIB`` on Linux::

   ifPhysAddress OBJECT-TYPE
      SYNTAX      PhysAddress
      MAX-ACCESS  read-only
      STATUS      current
      DESCRIPTION
               "The interface's address at its protocol sub-layer.  For
               example, for an 802.x interface, this object normally
               contains a MAC address.  The interface's media-specific MIB
               must define the bit and byte ordering and the format of the
               value of this object.  For interfaces which do not have such
               an address (e.g., a serial line), this object should contain
               an octet string of zero length."
      ::= { ifEntry 6 }

Add the ``-m ALL`` flag to ``snmpwalk`` to use the installed MIB files. The
example line will then display as::

   IF-MIB::ifPhysAddress.3 = STRING: 20:87:56:ff:aa:86

instead of the previous::

   iso.3.6.1.2.1.2.2.1.6.3 = Hex-STRING: 20 87 56 FF AA 86

Supported SNMP OIDs
-------------------

These values can be written via SNMP, and should be stored persistently:

* sysContact
* sysName
* sysLocation


Network topology tools
----------------------

* libreNMS: https://www.librenms.org/
* Icinga: https://icinga.com
* Zabbix: https://www.zabbix.com/
* nmap: https://nmap.org/
* OpenNMS: https://www.opennms.com/
* Cacti: https://www.cacti.net/


Full SNMP readout example
-------------------------
Here is the full data from the Siemens switch, when using the MIBs::

   $ snmpwalk -v2c -c public 192.168.0.99 -m ALL
   SNMPv2-MIB::sysDescr.0 = STRING: Siemens, SIMATIC NET, SCALANCE X204IRT, 6GK5 204-0BA00-2BA3, HW: Version 9, FW: Version V05.04.02, SVPL6147920
   SNMPv2-MIB::sysObjectID.0 = OID: SNMPv2-SMI::enterprises.4196.1.1.5.2.5
   DISMAN-EXPRESSION-MIB::sysUpTimeInstance = Timeticks: (756575) 2:06:05.75
   SNMPv2-MIB::sysContact.0 = STRING: sysContact Not Set
   SNMPv2-MIB::sysName.0 = STRING: sysName Not Set
   SNMPv2-MIB::sysLocation.0 = STRING: sysLocation Not Set
   SNMPv2-MIB::sysServices.0 = INTEGER: 67
   IF-MIB::ifNumber.0 = INTEGER: 5
   IF-MIB::ifIndex.1 = INTEGER: 1
   IF-MIB::ifIndex.2 = INTEGER: 2
   IF-MIB::ifIndex.3 = INTEGER: 3
   IF-MIB::ifIndex.4 = INTEGER: 4
   IF-MIB::ifIndex.1000 = INTEGER: 1000
   IF-MIB::ifDescr.1 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P1
   IF-MIB::ifDescr.2 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P2
   IF-MIB::ifDescr.3 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P3
   IF-MIB::ifDescr.4 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P4
   IF-MIB::ifDescr.1000 = STRING: Siemens, SIMATIC NET, internal, X1
   IF-MIB::ifType.1 = INTEGER: ethernetCsmacd(6)
   IF-MIB::ifType.2 = INTEGER: ethernetCsmacd(6)
   IF-MIB::ifType.3 = INTEGER: ethernetCsmacd(6)
   IF-MIB::ifType.4 = INTEGER: ethernetCsmacd(6)
   IF-MIB::ifType.1000 = INTEGER: ethernetCsmacd(6)
   IF-MIB::ifMtu.1 = INTEGER: 1500
   IF-MIB::ifMtu.2 = INTEGER: 1500
   IF-MIB::ifMtu.3 = INTEGER: 1500
   IF-MIB::ifMtu.4 = INTEGER: 1500
   IF-MIB::ifMtu.1000 = INTEGER: 1500
   IF-MIB::ifSpeed.1 = Gauge32: 10000000
   IF-MIB::ifSpeed.2 = Gauge32: 100000000
   IF-MIB::ifSpeed.3 = Gauge32: 100000000
   IF-MIB::ifSpeed.4 = Gauge32: 10000000
   IF-MIB::ifSpeed.1000 = Gauge32: 0
   IF-MIB::ifPhysAddress.1 = STRING: 20:87:56:ff:aa:84
   IF-MIB::ifPhysAddress.2 = STRING: 20:87:56:ff:aa:85
   IF-MIB::ifPhysAddress.3 = STRING: 20:87:56:ff:aa:86
   IF-MIB::ifPhysAddress.4 = STRING: 20:87:56:ff:aa:87
   IF-MIB::ifPhysAddress.1000 = STRING: 20:87:56:ff:aa:83
   IF-MIB::ifAdminStatus.1 = INTEGER: up(1)
   IF-MIB::ifAdminStatus.2 = INTEGER: up(1)
   IF-MIB::ifAdminStatus.3 = INTEGER: up(1)
   IF-MIB::ifAdminStatus.4 = INTEGER: up(1)
   IF-MIB::ifAdminStatus.1000 = INTEGER: up(1)
   IF-MIB::ifOperStatus.1 = INTEGER: up(1)
   IF-MIB::ifOperStatus.2 = INTEGER: up(1)
   IF-MIB::ifOperStatus.3 = INTEGER: up(1)
   IF-MIB::ifOperStatus.4 = INTEGER: down(2)
   IF-MIB::ifOperStatus.1000 = INTEGER: up(1)
   IF-MIB::ifLastChange.1 = Timeticks: (616788) 1:42:47.88
   IF-MIB::ifLastChange.2 = Timeticks: (436359) 1:12:43.59
   IF-MIB::ifLastChange.3 = Timeticks: (1094) 0:00:10.94
   IF-MIB::ifLastChange.4 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifLastChange.1000 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifInOctets.1 = Counter32: 908950
   IF-MIB::ifInOctets.2 = Counter32: 214915
   IF-MIB::ifInOctets.3 = Counter32: 576327
   IF-MIB::ifInOctets.4 = Counter32: 0
   IF-MIB::ifInOctets.1000 = Counter32: 0
   IF-MIB::ifInUcastPkts.1 = Counter32: 911
   IF-MIB::ifInUcastPkts.2 = Counter32: 308
   IF-MIB::ifInUcastPkts.3 = Counter32: 6185
   IF-MIB::ifInUcastPkts.4 = Counter32: 0
   IF-MIB::ifInUcastPkts.1000 = Counter32: 0
   IF-MIB::ifInNUcastPkts.1 = Counter32: 7840
   IF-MIB::ifInNUcastPkts.2 = Counter32: 1521
   IF-MIB::ifInNUcastPkts.3 = Counter32: 99
   IF-MIB::ifInNUcastPkts.4 = Counter32: 0
   IF-MIB::ifInNUcastPkts.1000 = Counter32: 0
   IF-MIB::ifInDiscards.1 = Counter32: 0
   IF-MIB::ifInDiscards.2 = Counter32: 0
   IF-MIB::ifInDiscards.3 = Counter32: 0
   IF-MIB::ifInDiscards.4 = Counter32: 0
   IF-MIB::ifInDiscards.1000 = Counter32: 0
   IF-MIB::ifInErrors.1 = Counter32: 0
   IF-MIB::ifInErrors.2 = Counter32: 0
   IF-MIB::ifInErrors.3 = Counter32: 0
   IF-MIB::ifInErrors.4 = Counter32: 0
   IF-MIB::ifInErrors.1000 = Counter32: 0
   IF-MIB::ifInUnknownProtos.1 = Counter32: 492
   IF-MIB::ifInUnknownProtos.2 = Counter32: 19
   IF-MIB::ifInUnknownProtos.3 = Counter32: 21
   IF-MIB::ifInUnknownProtos.4 = Counter32: 0
   IF-MIB::ifInUnknownProtos.1000 = Counter32: 0
   IF-MIB::ifOutOctets.1 = Counter32: 1516306
   IF-MIB::ifOutOctets.2 = Counter32: 596825
   IF-MIB::ifOutOctets.3 = Counter32: 2244836
   IF-MIB::ifOutOctets.4 = Counter32: 0
   IF-MIB::ifOutOctets.1000 = Counter32: 0
   IF-MIB::ifOutUcastPkts.1 = Counter32: 5835
   IF-MIB::ifOutUcastPkts.2 = Counter32: 385
   IF-MIB::ifOutUcastPkts.3 = Counter32: 6649
   IF-MIB::ifOutUcastPkts.4 = Counter32: 0
   IF-MIB::ifOutUcastPkts.1000 = Counter32: 0
   IF-MIB::ifOutNUcastPkts.1 = Counter32: 7470
   IF-MIB::ifOutNUcastPkts.2 = Counter32: 5352
   IF-MIB::ifOutNUcastPkts.3 = Counter32: 15626
   IF-MIB::ifOutNUcastPkts.4 = Counter32: 0
   IF-MIB::ifOutNUcastPkts.1000 = Counter32: 0
   IF-MIB::ifOutDiscards.1 = Counter32: 0
   IF-MIB::ifOutDiscards.2 = Counter32: 0
   IF-MIB::ifOutDiscards.3 = Counter32: 0
   IF-MIB::ifOutDiscards.4 = Counter32: 0
   IF-MIB::ifOutDiscards.1000 = Counter32: 0
   IF-MIB::ifOutErrors.1 = Counter32: 0
   IF-MIB::ifOutErrors.2 = Counter32: 0
   IF-MIB::ifOutErrors.3 = Counter32: 0
   IF-MIB::ifOutErrors.4 = Counter32: 0
   IF-MIB::ifOutErrors.1000 = Counter32: 0
   IF-MIB::ifOutQLen.1 = Gauge32: 0
   IF-MIB::ifOutQLen.2 = Gauge32: 0
   IF-MIB::ifOutQLen.3 = Gauge32: 0
   IF-MIB::ifOutQLen.4 = Gauge32: 0
   IF-MIB::ifOutQLen.1000 = Gauge32: 15
   IF-MIB::ifSpecific.1 = OID: SNMPv2-SMI::zeroDotZero
   IF-MIB::ifSpecific.2 = OID: SNMPv2-SMI::zeroDotZero
   IF-MIB::ifSpecific.3 = OID: SNMPv2-SMI::zeroDotZero
   IF-MIB::ifSpecific.4 = OID: SNMPv2-SMI::zeroDotZero
   IF-MIB::ifSpecific.1000 = OID: SNMPv2-SMI::zeroDotZero
   RFC1213-MIB::ipForwarding.0 = INTEGER: not-forwarding(2)
   RFC1213-MIB::ipDefaultTTL.0 = INTEGER: 64
   RFC1213-MIB::ipInReceives.0 = Counter32: 13017
   RFC1213-MIB::ipInHdrErrors.0 = Counter32: 0
   RFC1213-MIB::ipInAddrErrors.0 = Counter32: 0
   RFC1213-MIB::ipForwDatagrams.0 = Counter32: 0
   RFC1213-MIB::ipInUnknownProtos.0 = Counter32: 0
   RFC1213-MIB::ipInDiscards.0 = Counter32: 0
   RFC1213-MIB::ipInDelivers.0 = Counter32: 13023
   RFC1213-MIB::ipOutRequests.0 = Counter32: 13014
   RFC1213-MIB::ipOutDiscards.0 = Counter32: 0
   RFC1213-MIB::ipOutNoRoutes.0 = Counter32: 0
   RFC1213-MIB::ipReasmTimeout.0 = INTEGER: 60
   RFC1213-MIB::ipReasmReqds.0 = Counter32: 0
   RFC1213-MIB::ipReasmOKs.0 = Counter32: 0
   RFC1213-MIB::ipReasmFails.0 = Counter32: 0
   RFC1213-MIB::ipFragOKs.0 = Counter32: 0
   RFC1213-MIB::ipFragFails.0 = Counter32: 0
   RFC1213-MIB::ipFragCreates.0 = Counter32: 0
   RFC1213-MIB::ipAdEntAddr.192.168.0.99 = IpAddress: 192.168.0.99
   RFC1213-MIB::ipAdEntIfIndex.192.168.0.99 = INTEGER: 1000
   RFC1213-MIB::ipAdEntNetMask.192.168.0.99 = IpAddress: 255.255.255.0
   RFC1213-MIB::ipAdEntBcastAddr.192.168.0.99 = INTEGER: 1
   RFC1213-MIB::ipAdEntReasmMaxSize.192.168.0.99 = INTEGER: 65535
   RFC1213-MIB::ipRouteDest.127.0.0.1 = IpAddress: 127.0.0.1
   RFC1213-MIB::ipRouteDest.192.168.0.0 = IpAddress: 192.168.0.0
   RFC1213-MIB::ipRouteIfIndex.127.0.0.1 = INTEGER: 65535
   RFC1213-MIB::ipRouteIfIndex.192.168.0.0 = INTEGER: 65535
   RFC1213-MIB::ipRouteMetric1.127.0.0.1 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric1.192.168.0.0 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric2.127.0.0.1 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric2.192.168.0.0 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric3.127.0.0.1 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric3.192.168.0.0 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric4.127.0.0.1 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric4.192.168.0.0 = INTEGER: 0
   RFC1213-MIB::ipRouteNextHop.127.0.0.1 = IpAddress: 127.0.0.1
   RFC1213-MIB::ipRouteNextHop.192.168.0.0 = IpAddress: 192.168.0.99
   RFC1213-MIB::ipRouteType.127.0.0.1 = INTEGER: direct(3)
   RFC1213-MIB::ipRouteType.192.168.0.0 = INTEGER: direct(3)
   RFC1213-MIB::ipRouteProto.127.0.0.1 = INTEGER: local(2)
   RFC1213-MIB::ipRouteProto.192.168.0.0 = INTEGER: local(2)
   RFC1213-MIB::ipRouteAge.127.0.0.1 = INTEGER: 7563
   RFC1213-MIB::ipRouteAge.192.168.0.0 = INTEGER: 7562
   RFC1213-MIB::ipRouteMask.127.0.0.1 = IpAddress: 255.255.255.255
   RFC1213-MIB::ipRouteMask.192.168.0.0 = IpAddress: 255.255.255.0
   RFC1213-MIB::ipRouteMetric5.127.0.0.1 = INTEGER: 0
   RFC1213-MIB::ipRouteMetric5.192.168.0.0 = INTEGER: 0
   RFC1213-MIB::ipRouteInfo.127.0.0.1 = OID: SNMPv2-SMI::zeroDotZero
   RFC1213-MIB::ipRouteInfo.192.168.0.0 = OID: SNMPv2-SMI::zeroDotZero
   RFC1213-MIB::ipNetToMediaIfIndex.8.192.168.0.25 = INTEGER: 8
   RFC1213-MIB::ipNetToMediaIfIndex.8.192.168.0.50 = INTEGER: 8
   RFC1213-MIB::ipNetToMediaPhysAddress.8.192.168.0.25 = Hex-STRING: 1C 39 47 CD D4 EB
   RFC1213-MIB::ipNetToMediaPhysAddress.8.192.168.0.50 = Hex-STRING: 54 EE 75 FF 95 A6
   RFC1213-MIB::ipNetToMediaNetAddress.8.192.168.0.25 = IpAddress: 192.168.0.25
   RFC1213-MIB::ipNetToMediaNetAddress.8.192.168.0.50 = IpAddress: 192.168.0.50
   RFC1213-MIB::ipNetToMediaType.8.192.168.0.25 = INTEGER: invalid(2)
   RFC1213-MIB::ipNetToMediaType.8.192.168.0.50 = INTEGER: dynamic(3)
   RFC1213-MIB::ipRoutingDiscards.0 = Counter32: 0
   RFC1213-MIB::icmpInMsgs.0 = Counter32: 0
   RFC1213-MIB::icmpInErrors.0 = Counter32: 0
   RFC1213-MIB::icmpInDestUnreachs.0 = Counter32: 0
   RFC1213-MIB::icmpInTimeExcds.0 = Counter32: 0
   RFC1213-MIB::icmpInParmProbs.0 = Counter32: 0
   RFC1213-MIB::icmpInSrcQuenchs.0 = Counter32: 0
   RFC1213-MIB::icmpInRedirects.0 = Counter32: 0
   RFC1213-MIB::icmpInEchos.0 = Counter32: 0
   RFC1213-MIB::icmpInEchoReps.0 = Counter32: 0
   RFC1213-MIB::icmpInTimestamps.0 = Counter32: 0
   RFC1213-MIB::icmpInTimestampReps.0 = Counter32: 0
   RFC1213-MIB::icmpInAddrMasks.0 = Counter32: 0
   RFC1213-MIB::icmpInAddrMaskReps.0 = Counter32: 0
   RFC1213-MIB::icmpOutMsgs.0 = Counter32: 0
   RFC1213-MIB::icmpOutErrors.0 = Counter32: 0
   RFC1213-MIB::icmpOutDestUnreachs.0 = Counter32: 0
   RFC1213-MIB::icmpOutTimeExcds.0 = Counter32: 0
   RFC1213-MIB::icmpOutParmProbs.0 = Counter32: 0
   RFC1213-MIB::icmpOutSrcQuenchs.0 = Counter32: 0
   RFC1213-MIB::icmpOutRedirects.0 = Counter32: 0
   RFC1213-MIB::icmpOutEchos.0 = Counter32: 0
   RFC1213-MIB::icmpOutEchoReps.0 = Counter32: 0
   RFC1213-MIB::icmpOutTimestamps.0 = Counter32: 0
   RFC1213-MIB::icmpOutTimestampReps.0 = Counter32: 0
   RFC1213-MIB::icmpOutAddrMasks.0 = Counter32: 0
   RFC1213-MIB::icmpOutAddrMaskReps.0 = Counter32: 0
   RFC1213-MIB::tcpRtoAlgorithm.0 = INTEGER: vanj(4)
   RFC1213-MIB::tcpRtoMin.0 = INTEGER: 50000
   RFC1213-MIB::tcpRtoMax.0 = INTEGER: 3200000
   RFC1213-MIB::tcpMaxConn.0 = INTEGER: -1
   RFC1213-MIB::tcpActiveOpens.0 = Counter32: 0
   RFC1213-MIB::tcpPassiveOpens.0 = Counter32: 0
   RFC1213-MIB::tcpAttemptFails.0 = Counter32: 0
   RFC1213-MIB::tcpEstabResets.0 = Counter32: 0
   RFC1213-MIB::tcpCurrEstab.0 = Gauge32: 0
   RFC1213-MIB::tcpInSegs.0 = Counter32: 0
   RFC1213-MIB::tcpOutSegs.0 = Counter32: 0
   RFC1213-MIB::tcpRetransSegs.0 = Counter32: 0
   RFC1213-MIB::tcpConnState.0.0.0.0.22.0.0.0.0.0 = INTEGER: listen(2)
   RFC1213-MIB::tcpConnState.0.0.0.0.23.0.0.0.0.0 = INTEGER: listen(2)
   RFC1213-MIB::tcpConnState.0.0.0.0.80.0.0.0.0.0 = INTEGER: listen(2)
   RFC1213-MIB::tcpConnState.0.0.0.0.84.0.0.0.0.0 = INTEGER: listen(2)
   RFC1213-MIB::tcpConnState.0.0.0.0.443.0.0.0.0.0 = INTEGER: listen(2)
   RFC1213-MIB::tcpConnLocalAddress.0.0.0.0.22.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnLocalAddress.0.0.0.0.23.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnLocalAddress.0.0.0.0.80.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnLocalAddress.0.0.0.0.84.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnLocalAddress.0.0.0.0.443.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnLocalPort.0.0.0.0.22.0.0.0.0.0 = INTEGER: 22
   RFC1213-MIB::tcpConnLocalPort.0.0.0.0.23.0.0.0.0.0 = INTEGER: 23
   RFC1213-MIB::tcpConnLocalPort.0.0.0.0.80.0.0.0.0.0 = INTEGER: 80
   RFC1213-MIB::tcpConnLocalPort.0.0.0.0.84.0.0.0.0.0 = INTEGER: 84
   RFC1213-MIB::tcpConnLocalPort.0.0.0.0.443.0.0.0.0.0 = INTEGER: 443
   RFC1213-MIB::tcpConnRemAddress.0.0.0.0.22.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnRemAddress.0.0.0.0.23.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnRemAddress.0.0.0.0.80.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnRemAddress.0.0.0.0.84.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnRemAddress.0.0.0.0.443.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::tcpConnRemPort.0.0.0.0.22.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::tcpConnRemPort.0.0.0.0.23.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::tcpConnRemPort.0.0.0.0.80.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::tcpConnRemPort.0.0.0.0.84.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::tcpConnRemPort.0.0.0.0.443.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::tcpInErrs.0 = Counter32: 0
   RFC1213-MIB::tcpOutRsts.0 = Counter32: 0
   RFC1213-MIB::udpInDatagrams.0 = Counter32: 13139
   RFC1213-MIB::udpNoPorts.0 = Counter32: 0
   RFC1213-MIB::udpInErrors.0 = Counter32: 0
   RFC1213-MIB::udpOutDatagrams.0 = Counter32: 13132
   RFC1213-MIB::udpLocalAddress.0.0.0.0.0 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.0.0.0.0.68 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.0.0.0.0.161 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.0.0.0.0.34964 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.0.0.0.0.49152 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.0.0.0.0.49153 = IpAddress: 0.0.0.0
   RFC1213-MIB::udpLocalAddress.127.0.0.1.12345 = IpAddress: 127.0.0.1
   RFC1213-MIB::udpLocalAddress.127.0.0.1.12346 = IpAddress: 127.0.0.1
   RFC1213-MIB::udpLocalPort.0.0.0.0.0 = INTEGER: 0
   RFC1213-MIB::udpLocalPort.0.0.0.0.68 = INTEGER: 68
   RFC1213-MIB::udpLocalPort.0.0.0.0.161 = INTEGER: 161
   RFC1213-MIB::udpLocalPort.0.0.0.0.34964 = INTEGER: 34964
   RFC1213-MIB::udpLocalPort.0.0.0.0.49152 = INTEGER: 49152
   RFC1213-MIB::udpLocalPort.0.0.0.0.49153 = INTEGER: 49153
   RFC1213-MIB::udpLocalPort.127.0.0.1.12345 = INTEGER: 12345
   RFC1213-MIB::udpLocalPort.127.0.0.1.12346 = INTEGER: 12346
   SNMPv2-MIB::snmpInPkts.0 = Counter32: 5616
   SNMPv2-MIB::snmpOutPkts.0 = Counter32: 5607
   SNMPv2-MIB::snmpInBadVersions.0 = Counter32: 0
   SNMPv2-MIB::snmpInBadCommunityNames.0 = Counter32: 9
   SNMPv2-MIB::snmpInBadCommunityUses.0 = Counter32: 0
   SNMPv2-MIB::snmpInASNParseErrs.0 = Counter32: 0
   SNMPv2-MIB::snmpInTooBigs.0 = Counter32: 0
   SNMPv2-MIB::snmpInNoSuchNames.0 = Counter32: 0
   SNMPv2-MIB::snmpInBadValues.0 = Counter32: 0
   SNMPv2-MIB::snmpInReadOnlys.0 = Counter32: 0
   SNMPv2-MIB::snmpInGenErrs.0 = Counter32: 0
   SNMPv2-MIB::snmpInTotalReqVars.0 = Counter32: 5616
   SNMPv2-MIB::snmpInTotalSetVars.0 = Counter32: 0
   SNMPv2-MIB::snmpInGetRequests.0 = Counter32: 5
   SNMPv2-MIB::snmpInGetNexts.0 = Counter32: 5615
   SNMPv2-MIB::snmpInSetRequests.0 = Counter32: 0
   SNMPv2-MIB::snmpInGetResponses.0 = Counter32: 0
   SNMPv2-MIB::snmpInTraps.0 = Counter32: 0
   SNMPv2-MIB::snmpOutTooBigs.0 = Counter32: 0
   SNMPv2-MIB::snmpOutNoSuchNames.0 = Counter32: 0
   SNMPv2-MIB::snmpOutBadValues.0 = Counter32: 0
   SNMPv2-MIB::snmpOutGenErrs.0 = Counter32: 0
   SNMPv2-MIB::snmpOutGetRequests.0 = Counter32: 0
   SNMPv2-MIB::snmpOutGetNexts.0 = Counter32: 0
   SNMPv2-MIB::snmpOutSetRequests.0 = Counter32: 0
   SNMPv2-MIB::snmpOutGetResponses.0 = Counter32: 5630
   SNMPv2-MIB::snmpOutTraps.0 = Counter32: 0
   SNMPv2-MIB::snmpEnableAuthenTraps.0 = INTEGER: disabled(2)
   SNMPv2-MIB::snmpSilentDrops.0 = Counter32: 0
   SNMPv2-MIB::snmpProxyDrops.0 = Counter32: 0
   RMON2-MIB::netDefaultGateway.0 = IpAddress: 0.0.0.0
   BRIDGE-MIB::dot1dBaseBridgeAddress.0 = STRING: 20:87:56:ff:aa:84
   BRIDGE-MIB::dot1dBaseNumPorts.0 = INTEGER: 4 ports
   BRIDGE-MIB::dot1dBaseType.0 = INTEGER: transparent-only(2)
   BRIDGE-MIB::dot1dBasePort.1 = INTEGER: 1
   BRIDGE-MIB::dot1dBasePort.2 = INTEGER: 2
   BRIDGE-MIB::dot1dBasePort.3 = INTEGER: 3
   BRIDGE-MIB::dot1dBasePort.4 = INTEGER: 4
   BRIDGE-MIB::dot1dBasePortIfIndex.1 = INTEGER: 1
   BRIDGE-MIB::dot1dBasePortIfIndex.2 = INTEGER: 2
   BRIDGE-MIB::dot1dBasePortIfIndex.3 = INTEGER: 3
   BRIDGE-MIB::dot1dBasePortIfIndex.4 = INTEGER: 4
   BRIDGE-MIB::dot1dBasePortCircuit.1 = OID: SNMPv2-SMI::zeroDotZero
   BRIDGE-MIB::dot1dBasePortCircuit.2 = OID: SNMPv2-SMI::zeroDotZero
   BRIDGE-MIB::dot1dBasePortCircuit.3 = OID: SNMPv2-SMI::zeroDotZero
   BRIDGE-MIB::dot1dBasePortCircuit.4 = OID: SNMPv2-SMI::zeroDotZero
   BRIDGE-MIB::dot1dBasePortDelayExceededDiscards.1 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortDelayExceededDiscards.2 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortDelayExceededDiscards.3 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortDelayExceededDiscards.4 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortMtuExceededDiscards.1 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortMtuExceededDiscards.2 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortMtuExceededDiscards.3 = Counter32: 0
   BRIDGE-MIB::dot1dBasePortMtuExceededDiscards.4 = Counter32: 0
   BRIDGE-MIB::dot1dTpLearnedEntryDiscards.0 = Counter32: 0
   BRIDGE-MIB::dot1dTpAgingTime.0 = INTEGER: 30 seconds
   BRIDGE-MIB::dot1dTpFdbAddress.'T.u...' = STRING: 54:ee:75:ff:95:a6
   BRIDGE-MIB::dot1dTpFdbAddress.'.'....' = STRING: b8:27:eb:a4:b5:ee
   BRIDGE-MIB::dot1dTpFdbPort.'T.u...' = INTEGER: 3
   BRIDGE-MIB::dot1dTpFdbPort.'.'....' = INTEGER: 2
   BRIDGE-MIB::dot1dTpFdbStatus.'T.u...' = INTEGER: learned(3)
   BRIDGE-MIB::dot1dTpFdbStatus.'.'....' = INTEGER: learned(3)
   BRIDGE-MIB::dot1dTpPort.1 = INTEGER: 1
   BRIDGE-MIB::dot1dTpPort.2 = INTEGER: 2
   BRIDGE-MIB::dot1dTpPort.3 = INTEGER: 3
   BRIDGE-MIB::dot1dTpPort.4 = INTEGER: 4
   BRIDGE-MIB::dot1dTpPortMaxInfo.1 = INTEGER: 1486 bytes
   BRIDGE-MIB::dot1dTpPortMaxInfo.2 = INTEGER: 1486 bytes
   BRIDGE-MIB::dot1dTpPortMaxInfo.3 = INTEGER: 1486 bytes
   BRIDGE-MIB::dot1dTpPortMaxInfo.4 = INTEGER: 1486 bytes
   BRIDGE-MIB::dot1dTpPortInFrames.1 = Counter32: 8751 frames
   BRIDGE-MIB::dot1dTpPortInFrames.2 = Counter32: 1830 frames
   BRIDGE-MIB::dot1dTpPortInFrames.3 = Counter32: 6546 frames
   BRIDGE-MIB::dot1dTpPortInFrames.4 = Counter32: 0 frames
   BRIDGE-MIB::dot1dTpPortOutFrames.1 = Counter32: 13306 frames
   BRIDGE-MIB::dot1dTpPortOutFrames.2 = Counter32: 5738 frames
   BRIDGE-MIB::dot1dTpPortOutFrames.3 = Counter32: 22510 frames
   BRIDGE-MIB::dot1dTpPortOutFrames.4 = Counter32: 0 frames
   BRIDGE-MIB::dot1dTpPortInDiscards.1 = Counter32: 0 frames
   BRIDGE-MIB::dot1dTpPortInDiscards.2 = Counter32: 0 frames
   BRIDGE-MIB::dot1dTpPortInDiscards.3 = Counter32: 0 frames
   BRIDGE-MIB::dot1dTpPortInDiscards.4 = Counter32: 0 frames
   IF-MIB::ifName.1 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P1
   IF-MIB::ifName.2 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P2
   IF-MIB::ifName.3 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P3
   IF-MIB::ifName.4 = STRING: Siemens, SIMATIC NET, Ethernet Port, X1 P4
   IF-MIB::ifName.1000 = STRING: Siemens, SIMATIC NET, internal, X1
   IF-MIB::ifInMulticastPkts.1 = Counter32: 6744
   IF-MIB::ifInMulticastPkts.2 = Counter32: 1299
   IF-MIB::ifInMulticastPkts.3 = Counter32: 91
   IF-MIB::ifInMulticastPkts.4 = Counter32: 0
   IF-MIB::ifInMulticastPkts.1000 = Counter32: 0
   IF-MIB::ifInBroadcastPkts.1 = Counter32: 1096
   IF-MIB::ifInBroadcastPkts.2 = Counter32: 223
   IF-MIB::ifInBroadcastPkts.3 = Counter32: 8
   IF-MIB::ifInBroadcastPkts.4 = Counter32: 0
   IF-MIB::ifInBroadcastPkts.1000 = Counter32: 0
   IF-MIB::ifOutMulticastPkts.1 = Counter32: 7239
   IF-MIB::ifOutMulticastPkts.2 = Counter32: 5046
   IF-MIB::ifOutMulticastPkts.3 = Counter32: 14309
   IF-MIB::ifOutMulticastPkts.4 = Counter32: 0
   IF-MIB::ifOutMulticastPkts.1000 = Counter32: 0
   IF-MIB::ifOutBroadcastPkts.1 = Counter32: 232
   IF-MIB::ifOutBroadcastPkts.2 = Counter32: 307
   IF-MIB::ifOutBroadcastPkts.3 = Counter32: 1320
   IF-MIB::ifOutBroadcastPkts.4 = Counter32: 0
   IF-MIB::ifOutBroadcastPkts.1000 = Counter32: 0
   IF-MIB::ifHCInOctets.1 = Counter64: 908950
   IF-MIB::ifHCInOctets.2 = Counter64: 214979
   IF-MIB::ifHCInOctets.3 = Counter64: 605526
   IF-MIB::ifHCInOctets.4 = Counter64: 0
   IF-MIB::ifHCInOctets.1000 = Counter64: 0
   IF-MIB::ifHCInUcastPkts.1 = Counter64: 911
   IF-MIB::ifHCInUcastPkts.2 = Counter64: 308
   IF-MIB::ifHCInUcastPkts.3 = Counter64: 6501
   IF-MIB::ifHCInUcastPkts.4 = Counter64: 0
   IF-MIB::ifHCInUcastPkts.1000 = Counter64: 0
   IF-MIB::ifHCInMulticastPkts.1 = Counter64: 6744
   IF-MIB::ifHCInMulticastPkts.2 = Counter64: 1299
   IF-MIB::ifHCInMulticastPkts.3 = Counter64: 91
   IF-MIB::ifHCInMulticastPkts.4 = Counter64: 0
   IF-MIB::ifHCInMulticastPkts.1000 = Counter64: 0
   IF-MIB::ifHCInBroadcastPkts.1 = Counter64: 1096
   IF-MIB::ifHCInBroadcastPkts.2 = Counter64: 223
   IF-MIB::ifHCInBroadcastPkts.3 = Counter64: 8
   IF-MIB::ifHCInBroadcastPkts.4 = Counter64: 0
   IF-MIB::ifHCInBroadcastPkts.1000 = Counter64: 0
   IF-MIB::ifHCOutOctets.1 = Counter64: 1516677
   IF-MIB::ifHCOutOctets.2 = Counter64: 597260
   IF-MIB::ifHCOutOctets.3 = Counter64: 2274335
   IF-MIB::ifHCOutOctets.4 = Counter64: 0
   IF-MIB::ifHCOutOctets.1000 = Counter64: 0
   IF-MIB::ifHCOutUcastPkts.1 = Counter64: 5835
   IF-MIB::ifHCOutUcastPkts.2 = Counter64: 385
   IF-MIB::ifHCOutUcastPkts.3 = Counter64: 6955
   IF-MIB::ifHCOutUcastPkts.4 = Counter64: 0
   IF-MIB::ifHCOutUcastPkts.1000 = Counter64: 0
   IF-MIB::ifHCOutMulticastPkts.1 = Counter64: 7239
   IF-MIB::ifHCOutMulticastPkts.2 = Counter64: 5046
   IF-MIB::ifHCOutMulticastPkts.3 = Counter64: 14309
   IF-MIB::ifHCOutMulticastPkts.4 = Counter64: 0
   IF-MIB::ifHCOutMulticastPkts.1000 = Counter64: 0
   IF-MIB::ifHCOutBroadcastPkts.1 = Counter64: 232
   IF-MIB::ifHCOutBroadcastPkts.2 = Counter64: 307
   IF-MIB::ifHCOutBroadcastPkts.3 = Counter64: 1320
   IF-MIB::ifHCOutBroadcastPkts.4 = Counter64: 0
   IF-MIB::ifHCOutBroadcastPkts.1000 = Counter64: 0
   IF-MIB::ifLinkUpDownTrapEnable.1 = INTEGER: disabled(2)
   IF-MIB::ifLinkUpDownTrapEnable.2 = INTEGER: disabled(2)
   IF-MIB::ifLinkUpDownTrapEnable.3 = INTEGER: disabled(2)
   IF-MIB::ifLinkUpDownTrapEnable.4 = INTEGER: disabled(2)
   IF-MIB::ifLinkUpDownTrapEnable.1000 = INTEGER: disabled(2)
   IF-MIB::ifHighSpeed.1 = Gauge32: 10000000
   IF-MIB::ifHighSpeed.2 = Gauge32: 100000000
   IF-MIB::ifHighSpeed.3 = Gauge32: 100000000
   IF-MIB::ifHighSpeed.4 = Gauge32: 10000000
   IF-MIB::ifHighSpeed.1000 = Gauge32: 0
   IF-MIB::ifPromiscuousMode.1 = INTEGER: false(2)
   IF-MIB::ifPromiscuousMode.2 = INTEGER: false(2)
   IF-MIB::ifPromiscuousMode.3 = INTEGER: false(2)
   IF-MIB::ifPromiscuousMode.4 = INTEGER: false(2)
   IF-MIB::ifPromiscuousMode.1000 = INTEGER: false(2)
   IF-MIB::ifConnectorPresent.1 = INTEGER: true(1)
   IF-MIB::ifConnectorPresent.2 = INTEGER: true(1)
   IF-MIB::ifConnectorPresent.3 = INTEGER: true(1)
   IF-MIB::ifConnectorPresent.4 = INTEGER: true(1)
   IF-MIB::ifConnectorPresent.1000 = INTEGER: false(2)
   IF-MIB::ifAlias.1 = STRING:
   IF-MIB::ifAlias.2 = STRING:
   IF-MIB::ifAlias.3 = STRING:
   IF-MIB::ifAlias.4 = STRING:
   IF-MIB::ifAlias.1000 = STRING:
   IF-MIB::ifCounterDiscontinuityTime.1 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifCounterDiscontinuityTime.2 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifCounterDiscontinuityTime.3 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifCounterDiscontinuityTime.4 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifCounterDiscontinuityTime.1000 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifStackStatus.0.1000 = INTEGER: active(1)
   IF-MIB::ifStackStatus.1.0 = INTEGER: active(1)
   IF-MIB::ifStackStatus.2.0 = INTEGER: active(1)
   IF-MIB::ifStackStatus.3.0 = INTEGER: active(1)
   IF-MIB::ifStackStatus.4.0 = INTEGER: active(1)
   IF-MIB::ifStackStatus.1000.1 = INTEGER: active(1)
   IF-MIB::ifStackStatus.1000.2 = INTEGER: active(1)
   IF-MIB::ifStackStatus.1000.3 = INTEGER: active(1)
   IF-MIB::ifStackStatus.1000.4 = INTEGER: active(1)
   IF-MIB::ifRcvAddressStatus.1000 = INTEGER: active(1)
   IF-MIB::ifRcvAddressType.1000 = INTEGER: nonVolatile(3)
   IF-MIB::ifTableLastChange.0 = Timeticks: (0) 0:00:00.00
   IF-MIB::ifStackLastChange.0 = Timeticks: (0) 0:00:00.00
