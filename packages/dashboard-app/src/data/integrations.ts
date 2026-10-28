import { PRODUCT_NAME } from "@/lib/constants";

const integrationOptions = [
  {
    title: "Integrations",
    properties: [
      {
        id: "integrations.terminal.disabled",
        title: "Terminal",
        description: `Add ${PRODUCT_NAME} to Terminal.app`,

        type: "boolean",
        default: false,
        inverted: true,
      },
      {
        id: "integrations.hyper.disabled",
        title: "Hyper",
        description: `Add ${PRODUCT_NAME} to Hyper`,
        type: "boolean",
        default: false,
        inverted: true,
      },
      {
        id: "integrations.vscode.disabled",
        title: "VS Code Terminal",
        description: `Add ${PRODUCT_NAME} to VS Code's built-in terminal`,
        type: "boolean",
        default: false,
        inverted: true,
      },
      {
        id: "integrations.iterm.disabled",
        title: "iTerm 2",
        description: `Add ${PRODUCT_NAME} to iTerm 2`,
        type: "boolean",
        default: false,
        inverted: true,
      },
      {
        id: "integrations.ghostty.disabled",
        title: "Ghostty",
        description: `Add ${PRODUCT_NAME} to Ghostty`,
        type: "boolean",
        default: false,
        inverted: true,
        installKey: "inputMethod" as const,
      },
      {
        id: "integrations.kitty.disabled",
        title: "Kitty",
        description: `Add ${PRODUCT_NAME} to Kitty`,
        type: "boolean",
        default: false,
        inverted: true,
        installKey: "inputMethod" as const,
      },
      {
        id: "integrations.wezterm.disabled",
        title: "WezTerm",
        description: `Add ${PRODUCT_NAME} to WezTerm`,
        type: "boolean",
        default: false,
        inverted: true,
        installKey: "inputMethod" as const,
      },
      {
        id: "integrations.alacritty.disabled",
        title: "Alacritty",
        description: `Add ${PRODUCT_NAME} to Alacritty`,
        type: "boolean",
        default: false,
        inverted: true,
        installKey: "inputMethod" as const,
      },
    ],
  },
  // {
  //   title: "Experimental",
  //   properties: [
  //     {
  //       id: "qterm.csi-u.enabled",
  //       title: "CSI u Intercept Mode (experimental)",
  //       description:
  //         "Enable the experimental CSI u integration. This mode allows you to use more modifier keys for keybindings. It however may modify the behavior of keys you press, if you experience issues, please report them to us.",
  //       type: "boolean",
  //       default: false,
  //     },
  //   ],
  // },
];

export default integrationOptions;
