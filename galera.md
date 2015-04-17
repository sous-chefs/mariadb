Galera
======

Recipe
------

  To use Galera, you must use the galera recipe, instead of the server one. Until version 10.1, there's different binary version for standard server and galera's one. As soon as the 10.1 will be stable, we will work on a new unified recipe.

Initial Setup
-------------

  There's one point very important with Galera Cluster, which is not fully industrialized by this cookbook: the first node. In a Galera Cluster, you have to had a specific configuration for the first start. the `wsrep_cluster_address` must contain only `gcom://`, with no other node inside. The problem will be the same, if you had to stop the whole cluster, and then need to restart it. (If you have an idea on how to automate it, please feel free to create an issue, or make a PR).

  As of today, when i create a new cluster on production, i first provision one node on my Chef Server. So the configuration `wsrep_cluster_address` remains empty of other nodes. After a successfull converge step, and after verifying that the node is OK, i add the other nodes into Chef Server.

  
Load Balancing
--------------

If your application is not built with the risk of having some request rejected (Which is the case for almost 90% of applications), you need to have two Load Balancer in fact:
* One load-balancer to set the write on 1 node only
* One load-balancer to have all nodes executing reads.

A typical case of what is involved here is described on this blog post:
http://severalnines.com/blog/avoiding-deadlocks-galera-set-haproxy-single-node-writes-and-multi-node-reads

I personnaly use HAProxy to do the job, like Several Nine do.
