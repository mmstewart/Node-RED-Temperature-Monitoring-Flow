<h1 align=center> Node-RED Temperature Monitoring Flow </h1>

**This flow is recommeded for people who are using AVTECH Room Alert 3E.**

This flow is used to monitor the temperature using AVTECH Room Alert Monitor. In this flow, the user is able to receive email alerts if the temperature is above the temperature threshold. In the debug console, it ouputs a decimal value that indicated the temperature of the Room Alert Monitor (e.g. 7163 = 71.63 in Fahrenheit).

The user has incoorporate their information in the **snmp subtree** and **email** node.

The default value of the temperature threshold is 8060.

## Nodes

Nodes used:

* [Email](https://flows.nodered.org/node/node-red-node-email)

* [SNMP](https://flows.nodered.org/node/node-red-node-snmp)

## Author

* **Marcus Stewart** - [MMStewart](https://github.com/mmstewart)

## License

Copyright (c) 2020<!--- -(Future Years) --> Marcus Stewart, see Git history

MIT licensed, see [LICENSE](LICENSE) file.


