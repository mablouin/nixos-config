{ config, pkgs, lib, ... }:

{
  programs.k9s = {
    enable = true;
    views = {
      "views" = {
        "v1/pods" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/services" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/configmaps" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/secrets" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/serviceaccounts" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/persistentvolumeclaims" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/events" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "v1/endpoints" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "apps/v1/deployments" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "apps/v1/replicasets" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "apps/v1/statefulsets" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "apps/v1/daemonsets" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "batch/v1/jobs" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "batch/v1/cronjobs" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "networking.k8s.io/v1/ingresses" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "networking.k8s.io/v1/networkpolicies" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "rbac.authorization.k8s.io/v1/roles" = {
          "sortColumn" = "NAMESPACE:asc";
        };
        "rbac.authorization.k8s.io/v1/rolebindings" = {
          "sortColumn" = "NAMESPACE:asc";
        };
      };
    };
  };
}
