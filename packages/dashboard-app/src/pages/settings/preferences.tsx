import { UserPrefView } from "@/components/preference/list";
import { Button } from "@/components/ui/button";
import settings from "@/data/preferences";
import { Native } from "@tab/api-bindings";
import { PRODUCT_NAME } from "@/lib/constants";

export default function Page() {
  return (
    <>
      <UserPrefView array={settings} />
      <section className={`py-4 gap-4`}>
        <h2
          id={`subhead-licenses`}
          className="font-bold text-medium text-zinc-400 leading-none mt-2"
        >
          Licenses
        </h2>
        <Button
          variant="link"
          className="px-0 text-blue-500 hover:underline decoration-1 underline-offset-1 hover:text-blue-800 hover:underline-offset-4 transition-all duration-100 text-sm"
          onClick={() => {
            Native.open(
              `file:///Applications/${PRODUCT_NAME}.app/Contents/Resources/dashboard/license/NOTICE.txt`,
            );
          }}
        >
          View licenses
        </Button>
      </section>
    </>
  );
}
