# OS Configuration Pre-Requisites:

* BigBang can work with selinux enforcing, but it requires additional OS configuration. 
* The following OS configuration settings are usually required to make BigBang work:
  * `sudo sysctl -w vm.max_map_count=262144`    #(ECK crash loops without this)
  * `sudo setenforce 0`   #(Istio init-container crash loops without this if selinux is enabled) (WIP to remove this requirement in the future/consider disabling it a soft requirement)