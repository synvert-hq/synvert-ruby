---
layout: page
title: Terms
---

### Snippet

Snippet is a piece of code to define what code need to convert and how
to convert the code.

### Rewriter

Rewriter is the top level namespace in a snippet.

One rewriter checks if the gem version matches, e.g. we can say the
rewriter only works if factory\_girl gem is greater than or equal to
2.0.0.

One rewriter contains one or many instances.

### Instance

Instance is an execution unit, it finds specified ast nodes, checks
if the nodes match some conditions, then add, replace or remove code.

One instance can contains any scopes or conditions.

### Scope

Scope just likes its name, different scope points to different
current node.

One scope defines some rules, it finds new nodes and changes
current node to matching node.

### Condition

Condition is used to check if the node matches the rules, condition
won't change the node scope.

### Action

Action does some real action, e.g. add / replace / remove code.
