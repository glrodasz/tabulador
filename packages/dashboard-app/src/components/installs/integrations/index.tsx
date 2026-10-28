import { Button } from "@/components/ui/button";
import { useStatusCheck } from "@/hooks/store";
import { InstallKey } from "@/types/preferences";
import { Install } from "@tab/api-bindings";
import { ReactNode, useEffect, useState } from "react";

type Integration = {
  id: string;
  title: string;
  background?: {
    color: string;
    image: string;
  };
  description?: string;
  installKey?: InstallKey;
};

const installActionLabels: Record<InstallKey, string> = {
  dotfiles: "Install shell integrations",
  accessibility: "Enable accessibility",
  inputMethod: "Install input method",
};

// Terminals that rely on another component (e.g. the input method) show an
// install button until that component is installed, then the regular toggle.
function RequiresInstall({
  installKey,
  children,
}: {
  installKey: InstallKey;
  children: ReactNode;
}) {
  const [isInstalled, refreshStatus] = useStatusCheck(installKey);
  const [installing, setInstalling] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    refreshStatus();
  }, [refreshStatus]);

  function install() {
    setInstalling(true);
    setError(null);
    Install.install(installKey)
      .then(() => refreshStatus())
      .catch((e) => {
        console.error(e);
        setError(e instanceof Error ? e.message : String(e));
      })
      .finally(() => setInstalling(false));
  }

  if (isInstalled !== false) return <>{children}</>;

  return (
    <>
      <Button onClick={install} disabled={installing} variant={"default"}>
        {installing ? "Installing..." : installActionLabels[installKey]}
      </Button>
      {installKey === "inputMethod" && (
        <p className="text-xs text-black/50 dark:text-white/50 text-center -mt-2">
          Restart the terminal after installing.
        </p>
      )}
      {error && (
        <p className="text-xs text-red-600 dark:text-red-400 text-center -mt-2">
          {error}
        </p>
      )}
    </>
  );
}

export default function IntegrationCard({
  integration,
  enabled,
  toggleSwitch,
}: {
  integration: Integration;
  enabled: boolean;
  toggleSwitch: () => void;
}) {
  const integrationId = integration.id.split(".")[1];

  const toggle =
    enabled === true ? (
      <Button
        onClick={toggleSwitch}
        variant={"outline"}
        className="group text-black/50 hover:text-black"
      >
        <span className="inline-block group-hover:hidden">Enabled</span>
        <span className="hidden group-hover:inline-block">Disable</span>
      </Button>
    ) : (
      <Button onClick={toggleSwitch} variant={"default"}>
        Enable
      </Button>
    );

  return (
    <div className="flex flex-col relative overflow-hidden rounded-lg p-4 pt-6 gap-4 max-w-xs border border-black/10 dark:border-white/10 col-span-1">
      <div
        style={{
          backgroundImage: `url(${`/images/integrations/bg/${integrationId}.svg`})`,
        }}
        className="absolute left-0 right-0 bottom-1/2 w-full h-full bg-no-repeat bg-cover"
      />
      <div className="flex flex-col relative z-10 items-center text-center">
        <h3 className="text-white font-heading text-xl font-bold">
          {integration.title}
        </h3>
        <img
          className="h-40 w-40"
          src={`/images/integrations/icons/${integrationId}.png`}
        />
      </div>
      <p className="text-black/50 dark:text-white/50 self-center text-center flex-auto">
        {integration.description}
      </p>
      {integration.installKey ? (
        <RequiresInstall installKey={integration.installKey}>
          {toggle}
        </RequiresInstall>
      ) : (
        toggle
      )}
    </div>
  );
}
