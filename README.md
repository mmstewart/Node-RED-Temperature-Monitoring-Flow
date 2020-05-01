<h1 align=center> Node-RED Temperature Monitoring Flow </h1>

**This flow is recommeded for people who are using AVTECH Room Alert 3E.**

This flow is used to monitor the temperature using AVTECH Room Alert Monitor. In this flow, the user is able to receive email alerts if the temperature is above the temperature threshold. In the debug console, it ouputs a decimal value that indicated the temperature of the Room Alert Monitor (e.g. 7318 = 73.18 in Fahrenheit).

![Capture](https://user-images.githubusercontent.com/36175538/80829611-18ce5580-8bad-11ea-8ef6-7504031d0b94.PNG)

The user has to incoorporate their information in the **snmp subtree** and **email** node in order for the flow to work.

## Nodes

Nodes used:

* [Email](https://flows.nodered.org/node/node-red-node-email)

* [SNMP](https://flows.nodered.org/node/node-red-node-snmp)

## Author

* **Marcus Stewart** - [MMStewart](https://github.com/mmstewart)

## License

Copyright (c) 2020<!--- -(Future Years) --> Marcus Stewart, see Git history

MIT licensed, see [LICENSE](LICENSE) file.


