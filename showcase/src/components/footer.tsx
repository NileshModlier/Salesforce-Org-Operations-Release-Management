import { author } from "@/lib/site";

const links = [
  { label: "GitHub", href: author.github },
  { label: "Case Study", href: "#problem" },
  { label: "Architecture", href: "#architecture" },
  { label: "LinkedIn", href: author.linkedin },
];

export function Footer() {
  return (
    <footer className="border-t border-white/10 px-5 py-10 sm:px-8">
      <div className="mx-auto flex max-w-6xl flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-sm text-muted">Author</p>
          <p className="mt-1 text-lg font-semibold text-white">{author.name}</p>
          <p className="mt-2 max-w-md text-sm leading-6 text-muted">
            Salesforce Org Operations & Release Management. A portfolio case study, not a product.
          </p>
        </div>
        <ul className="flex flex-wrap gap-4 text-sm">
          {links.map((link) => (
            <li key={link.label}>
              <a
                href={link.href}
                className="text-muted transition hover:text-white"
                {...(link.href.startsWith("http")
                  ? { target: "_blank", rel: "noreferrer" }
                  : {})}
              >
                {link.label}
              </a>
            </li>
          ))}
        </ul>
      </div>
    </footer>
  );
}
