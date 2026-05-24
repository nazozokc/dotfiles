{ ... }:
{
  # ===== Docker CLI config =====
  programs.docker-cli = {
    enable = true;
    configDir = ".docker";
    settings = {
      detachKeys = "ctrl-\\,ctrl-\\";
      credsStore = "pass";
      experimental = "enabled";
      features = {
        buildkit = true;
      };
      aliases = {
        "docker:docker-compose" = "compose";
      };
    };
  };

  # ===== Lazydocker config =====
  home.file.".config/lazydocker/config.yml".text = ''
    gui:
      language: "ja"
      theme:
        activeBorderColor:
          - "#98bb6c"
          - "bold"
        inactiveBorderColor:
          - "#54546D"
        selectedLineBgColor:
          - "#2D4F67"
        optionsTextColor:
          - "#7e9cd8"
      returnImmediately: false
      wrapMainPanel: true
      skipDiscardStatus: false
      skipUntrustedCert: false
      commandLogSize: 8
      splitDiff: "vertical"
    logs:
      timestamps: false
      since: "60m"
      tail: ""
      command: ""
    refresher:
      refreshInterval: 300
      fetchContainerStats: false
    commandTemplates:
      dockerCompose: "docker compose"
      restartService: "{{ .DockerCompose }} restart {{ .Service.Name }}"
      startService: "{{ .DockerCompose }} start {{ .Service.Name }}"
      upService: "{{ .DockerCompose }} up -d {{ .Service.Name }}"
      viewCreds: ""
    customCommands:
      containers:
        - name: "View logs (follow)"
          attach: true
          command: "docker logs -f {{ .Container.ID }}"
          servicePatterns: []
        - name: "Inspect container"
          attach: true
          command: "docker inspect {{ .Container.ID }} | jq ."
          servicePatterns: []
        - name: "Top processes"
          attach: true
          command: "docker top {{ .Container.ID }}"
          servicePatterns: []
        - name: "Remove container"
          confirm: true
          command: "docker rm -f {{ .Container.ID }}"
          servicePatterns: []
      images:
        - name: "Remove image"
          confirm: true
          command: "docker rmi {{ .Image.ID }}"
          servicePatterns: []
        - name: "Inspect image"
          attach: true
          command: "docker inspect {{ .Image.ID }} | jq ."
          servicePatterns: []
      volumes:
        - name: "Remove volume"
          confirm: true
          command: "docker volume rm {{ .Volume.Name }}"
          servicePatterns: []
  '';
}
