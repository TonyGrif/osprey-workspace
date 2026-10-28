The agent is build on two components: coding-agent harness and MCP tools. 
# Coding-Agent Harness
These tools allow the LLM agent to act as an AI agent, one that can make plans and pursues tasks without micromanaging from human operators. For Osprey, it seems like Claude Code is the default choice.
# MCP (Model-Context-Protocal) Tools
These are the interface between the agent and the tech infrastructure. These allow the agent to read/write control systems, query archivers, read logs, etc. It defines what tools the agent has access to, what the tool can do, and how to use it.

Agent = reasoning layer; tools = execution layer
# References
- https://als-apg.github.io/osprey/getting-started/conceptual-tutorial.html
- https://en.wikipedia.org/wiki/Agent_harness