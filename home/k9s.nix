{ pkgs, pkgs-unstable, ... }:

{
  # Docker Desktop exposes a broken kubectl shim earlier in PATH under WSL.
  home.sessionVariablesExtra = ''
    export PATH="${pkgs.kubectl}/bin:$PATH"
  '';

  programs.k9s = {
    enable = true;
    package = pkgs-unstable.k9s;
    views = {
      "v1/pods" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/services" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/configmaps" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/secrets" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/serviceaccounts" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/persistentvolumeclaims" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/events" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "v1/endpoints" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "apps/v1/deployments" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "apps/v1/replicasets" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "apps/v1/statefulsets" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "apps/v1/daemonsets" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "batch/v1/jobs" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "batch/v1/cronjobs" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "networking.k8s.io/v1/ingresses" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "networking.k8s.io/v1/networkpolicies" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "rbac.authorization.k8s.io/v1/roles" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
      "rbac.authorization.k8s.io/v1/rolebindings" = {
        "columns" = [ ];
        "sortColumn" = "NAMESPACE:asc";
      };
    };
  };
}
